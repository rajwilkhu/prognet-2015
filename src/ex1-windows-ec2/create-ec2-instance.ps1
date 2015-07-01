param([Parameter(Mandatory=$true)][string]$name,
      [Parameter(Mandatory=$true)][string]$keyPairName, 
      [Parameter(Mandatory=$true)][string]$securityGroupName)

function Wait-Task ([ScriptBlock] $cmd, [string] $message, [int] $retrySeconds)
{
    $waitMessage = "Waiting for $message to succeed"
    $waitStartTime = Get-Date
    $waitTimedOut = $false
    Write-Verbose "$waitStartTime Wait for $message to succeed in $retrySeconds seconds"
    $timeBetweenRetries = 5

    while ($true)
    {
        try
        {
            $waitSucceeded = $false
            $waitResult = & $cmd 2>$null | select -Last 1 
            if ($? -and $waitResult)
            {
                $waitSucceeded = $true
            }
        }
        catch
        {
            # NOOP
        }

        $waitEndTime = Get-Date
        if ($waitSucceeded)
        {
            $waitResult
            break;
        }
        if (($waitEndTime - $waitStartTime).TotalSeconds -gt $retrySeconds)
        {
            $waitTimedOut = $true
            break
        }
        Sleep -Seconds $timeBetweenRetries
    }

    Write-Progress -Activity $waitMessage -Completed
    if ($waitTimedOut)
    {
        Write-Verbose "$waitEndTime $message [$([int]($waitEndTime-$waitStartTime).TotalSeconds) Seconds - Timeout]; current result is [$waitResult]"
        throw "Timeout - $message after $retrySeconds seconds, Current result=$waitResult"
    }
    else
    {
        Write-Verbose "$waitEndTime Succeeded $message in $([int]($waitEndTime-$waitStartTime).TotalSeconds) seconds."
    }
}

function Test-Pingable
{ 
    param([Parameter(Mandatory=$true)][string]$instanceid,
          [string]$region = 'eu-west-1')
    Set-DefaultAWSRegion $region

    $newInstances = Get-EC2Instance -ProfileName 'prognet' -Filter @{Name = "instance-id"; Values = $instanceid}
    $publicDNSName = $newInstances.Instances[0].PublicDnsName

    Write-Verbose "Test-Pingable: public dns name: $publicDnsName"

    $cmd = { ping $publicDNSName; $LASTEXITCODE -eq 0}
    $newInstances = Wait-Task $cmd "new instance - successful ping" 600

    return $publicDNSName
}

function Get-KeyFile
{ 
    param([string][Parameter (Position=1)]$keyPairName = 'prognet',
          [string]$region='eu-west-1')

    Set-DefaultAWSRegion $region
    $folder = resolve-path .
    $keyfile = Join-Path -Path $folder -ChildPath "$keyPairName.pem"

    if (-not (Test-Path $keyfile -PathType Leaf))
    {
        throw "Get-KeyFile - Keyfile=$keyfile Not Found"
    }

    if (-not (Get-EC2KeyPair -KeyNames $keyPairName -ProfileName 'prognet'))
    {
        $keyfile = $null
        throw "Get-KeyPair - KeyPair with name=$keyPairName not found in Region=$region"
    }

    return $keyfile
}

function Create-CredentialObject
{ 
    param([Parameter(Mandatory=$true)][string]$username,
          [Parameter(Mandatory=$true)][string]$password)

    $securepassword = ConvertTo-SecureString $password -AsPlainText -Force
    return New-Object System.Management.Automation.PSCredential ($username, $securepassword)
}

function Extract-CredentialsIntoFile
{ 
    param([Parameter(Mandatory=$true)][string]$instanceid,
          [Parameter(Mandatory=$true)][string]$publicDNSName,
          [Parameter(Mandatory=$true)][string]$keyPairName,
          [string]$region = 'eu-west-1')
    Set-DefaultAWSRegion $region

    $folder = resolve-path .
    $keyfile = Get-KeyFile -KeyPairName $keyPairName
    $cmd = {Get-EC2PasswordData -InstanceId $instanceid -PemFile $keyfile -Decrypt -ProfileName 'prognet'}
    $password = Wait-Task $cmd "new instance - able to retreive password" 600

    Write-Verbose "Username: Administrator, Password: $password"

    $outputCredentials = New-Object PSObject -Property @{ PublicDnsName=$publicDnsName; Username=$username; Password=$password }
    ($outputCredentials | Convertto-XML -NoTypeInformation).Save((Join-Path -Path $folder -ChildPath "$keyPairName.cxml"))

    return Create-CredentialObject -Username "Administrator" -Password $password
}

function New-WindowsInstance
{
    param (
        [string]$instanceType = 'm3.medium',
        [string]$imageid = 'ami-c1740ab6',
        [string]$region = 'eu-west-1',
        [string]$securityGroupName = 'prognet-sg',
        [string]$keyPairName = 'prognet-k',
        [string]$name = 'prognet-ec2')

    Set-DefaultAWSRegion $region
    $folder = resolve-path .
    $instanceid = $null
    $userdata = @"
<powershell>
Set-ExecutionPolicy RemoteSigned -Force
Enable-NetFirewallRule FPS-ICMP4-ERQ-In
Get-NetFirewallRule -DisplayName 'Remote Desktop*' | Set-NetFirewallRule -enabled true
Set-NetFirewallRule -Name WINRM-HTTP-In-TCP-PUBLIC -RemoteAddress Any
Enable-PSRemoting -Force -SkipNetworkProfileCheck
(Get-WmiObject Win32_TerminalServiceSetting -Namespace root\cimv2\TerminalServices).SetAllowTsConnections(1,1)
(Get-WmiObject -Class 'Win32_TSGeneralSetting' -Namespace root\cimv2\TerminalServices -Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(0)
Restart-Service winrm
</powershell>
"@

    $userdataBase64Encoded = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($userdata))
    $parameters = @{
        ImageId = $imageid
        MinCount = 1
        MaxCount = 1
        InstanceType = $instanceType
        KeyName = $keyPairName
        SecurityGroupIds = (Get-EC2SecurityGroup -GroupNames $securityGroupName -ProfileName 'prognet').GroupId
        UserData = $userdataBase64Encoded
        ProfileName = 'prognet'
        Region = $region
    }

    $startTime = Get-Date

    $newInstances = New-EC2Instance @parameters
    $instance = $newInstances.Instances[0]
    $instanceid = $instance.InstanceId

    Sleep -s 20 # Retry for tags normally needed
    New-EC2Tag -ResourceId $instanceid -ProfileName 'prognet' -Tag @{Key='Name'; Value=$name}

    $cmd = { $(Get-EC2Instance -ProfileName 'prognet' -Filter @{Name = "instance-id"; Values = $instanceid}).Instances[0].State.Name -eq "Running" }
    $newInstances = Wait-Task $cmd "new instance - running state" 450
    $runningTime = Get-Date
    
    $publicDNSName = Test-Pingable -InstanceId $instanceid -Region $region
    $pingTime = Get-Date

    $creds = Extract-CredentialsIntoFile -PublicDnsName $publicDNSName -InstanceId $instanceid -KeyPairName $keyPairName -Region $region
    $passwordTime = Get-Date

    $time = @{
        Running = $runningTime - $startTime
        Ping = $pingTime - $startTime
        Password = $passwordTime - $startTime
    }

    Write-Host $time
}

New-WindowsInstance -name $name -securityGroupName $securityGroupName -keyPairName $keyPairName