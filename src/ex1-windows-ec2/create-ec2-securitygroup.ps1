param([Parameter(Mandatory=$true)][string]$name)
Import-Module "C:\Program Files (x86)\AWS Tools\PowerShell\AWSPowerShell\AWSPowerShell.psd1"

function New-SecurityGroup
{
    param([string]$name = 'prognet',
          [string]$description = 'Progressive .Net tutorials 2015',
          [string]$region = 'eu-west-1')
    Set-DefaultAWSRegion $region

    $url = "http://checkip.dyndns.com" 
    # Creating a new .Net Object names a System.Net.Webclient
    $webclient = New-Object System.Net.WebClient
    # In this new webdownlader object we are telling $webclient to download the
    # url $url 
    $Ip = $webclient.DownloadString($url)
    # Just a simple text manuplation to get the ipadress form downloaded URL
      # If you want to know what it contain try to see the variable $Ip
    $Ip2 = $Ip.ToString()
    $ip3 = $Ip2.Split(" ")
    $ip4 = $ip3[5]
    $ip5 = $ip4.replace("</body>","")
    $publicIpAddress = $ip5.replace("</html>","").Trim()
    $ipRanges = @("$publicIpAddress/32")

    Write-Host("Setting security group ip access to $ipRanges")
    
    $groupid = New-EC2SecurityGroup $name -Description $description -ProfileName 'prognet'

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