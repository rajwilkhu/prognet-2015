param([Parameter(Mandatory=$true)][string]$name)
Import-Module "C:\Program Files (x86)\AWS Tools\PowerShell\AWSPowerShell\AWSPowerShell.psd1"

function New-SecurityGroup
{
    param([string]$name = 'prognet',
          [string]$description = 'Progressive .Net tutorials 2015',
          [string]$region = 'eu-west-1')
    Set-DefaultAWSRegion $region

    $groupid = New-EC2SecurityGroup $name -Description $description -ProfileName 'prognet'
    $publicIpAddress = (Invoke-WebRequest ifconfig.me/ip).Content.Trim()
    $ipRanges = @("$publicIpAddress/32")
    $forwardedIpAddress = (Invoke-WebRequest ifconfig.me/forwarded).Content.Trim()
    if ($forwardedIpAddress.length -gt 0)
    {
        $ipRanges = @("$publicIpAddress/32"; "$forwardedIpAddress/32")
    }

    Grant-EC2SecurityGroupIngress -GroupName $name -ProfileName 'prognet' `
                                  -IpPermissions @{IpProtocol = "icmp"; FromPort = -1; ToPort = -1; IpRanges = $ipRanges}
    Grant-EC2SecurityGroupIngress -GroupName $name -ProfileName 'prognet' `
                                  -IpPermissions @{IpProtocol = "tcp"; FromPort = 3389; ToPort = 3389; IpRanges = $ipRanges}
    Grant-EC2SecurityGroupIngress -GroupName $name -ProfileName 'prognet' `
                                  -IpPermissions @{IpProtocol = "udp"; FromPort = 3389; ToPort = 3389; IpRanges = $ipRanges}
    Grant-EC2SecurityGroupIngress -GroupName $name -ProfileName 'prognet' `
                                  -IpPermissions @{IpProtocol = "tcp"; FromPort = 5985; ToPort = 5985; IpRanges = $ipRanges}
    Grant-EC2SecurityGroupIngress -GroupName $name -ProfileName 'prognet' `
                                  -IpPermissions @{IpProtocol = "tcp"; FromPort = 5986; ToPort = 5986; IpRanges = $ipRanges}
}

New-SecurityGroup -name $name