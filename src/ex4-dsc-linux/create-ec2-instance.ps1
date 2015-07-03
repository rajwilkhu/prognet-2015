param([Parameter(Mandatory=$true)][string]$name,
      [Parameter(Mandatory=$true)][string]$keyPairName, 
      [Parameter(Mandatory=$true)][string]$securityGroupName)
Import-Module "C:\Program Files (x86)\AWS Tools\PowerShell\AWSPowerShell\AWSPowerShell.psd1"

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

    $outputCredentials = New-Object PSObject -Property @{ PublicDnsName=$publicDnsName; Username="Administrator"; Password=$password }
    ($outputCredentials | Convertto-XML -NoTypeInformation).Save((Join-Path -Path $folder -ChildPath "$keyPairName.cxml"))

    return Create-CredentialObject -Username "Administrator" -Password $password
}

function New-LinuxInstance
{
    param (
        [string]$instanceType = 'm3.medium',
        [string]$imageid = 'ami-a10897d6',
        [string]$region = 'eu-west-1',
        [string]$securityGroupName = 'prognet-sg',
        [string]$keyPairName = 'prognet-k',
        [string]$name = 'prognet-ec2')

    Set-DefaultAWSRegion $region
    $folder = resolve-path .
    $instanceid = $null
    $userdata = @"
#!/bin/bash
yum -y groupinstall 'Development Tools'
yum -y install pam-devel
yum -y install openssl-devel
yum -y install python
yum -y install python-devel
mkdir /root/downloads
cd /root/downloads
wget https://collaboration.opengroup.org/omi/documents/30532/omi-1.0.8.tar.gz
tar -xvf omi-1.0.8.tar.gz
cd omi-1.0.8
./configure | tee /tmp/omi-configure.txt
make | tee /tmp/omi-make.txt
make install | tee /tmp/omi-make-install.txt
cd /root/downloads
wget https://github.com/MSFTOSSMgmt/WPSDSCLinux/releases/download/v1.0.0-CTP/PSDSCLinux.tar.gz
tar -xvf PSDSCLinux.tar.gz
cd dsc/
mv * /root/downloads/
cd /root/downloads
make | tee /tmp/dsc-make.txt
make reg | tee /tmp/dsc-make-reg.txt
OMI_HOME=/opt/omi-1.0.8
/opt/omi-1.0.8/bin/omiserver -d
echo 'P@33w0rd123!' | passwd --stdin root
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

    Write-Output $publicDNSName

    $time = @{
        Running = $runningTime - $startTime
        Ping = $pingTime - $startTime
    }

    Write-Host $time
}

New-LinuxInstance -name $name -securityGroupName $securityGroupName -keyPairName $keyPairName