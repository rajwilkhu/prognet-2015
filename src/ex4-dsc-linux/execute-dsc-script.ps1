param([Parameter(Mandatory=$true)][string]$publicDNSName,
      [Parameter(Mandatory=$true)][string]$username = "Administrator", 
      [Parameter(Mandatory=$true)][string]$password)

. ./dsc-ex4.ps1

function Create-CredentialObject
{ 
    param([Parameter(Mandatory=$true)][string]$username,
          [Parameter(Mandatory=$true)][string]$password)

    $securepassword = ConvertTo-SecureString $password -AsPlainText -Force
    return New-Object System.Management.Automation.PSCredential ($username, $securepassword)
}

function Run-DscEx4Script
{
    param([Parameter(Mandatory=$true)][string]$publicDNSName,
          [Parameter(Mandatory=$true)][string]$username,
          [Parameter(Mandatory=$true)][string]$password)

    $folder = resolve-path .
    $scriptpath = Join-Path -Path $folder -ChildPath "dsc-ex4.psm1"
    $outpath = Join-Path -Path (Join-Path -Path $folder -ChildPath "config") -ChildPath "dsc-ex4"
    New-Item -Path $outpath -Type directory -Force | Out-Null

    Set-Item WSMan:\localhost\Client\TrustedHosts -Value $publicDNSName -Force

    DscEx4 -ComputerName $publicDNSName -OutputPath $outpath

    $credential = Create-CredentialObject -username $username -password $password

    $options = New-CimSessionOption -UseSsl:$true -SkipCACheck:$true -SkipCNCheck:$true -SkipRevocationCheck:$true
    $cimSession = New-CimSession -ComputerName $publicDNSName -Credential $credential -Port:5986 -Authentication:basic -SessionOption:$options
    Start-DscConfiguration -Verbose -wait -Path $outpath -Force -CimSession $cimSession
}

Run-DscEx4Script -publicDNSName $publicDNSName -username $username -password $password