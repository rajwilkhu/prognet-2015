param([Parameter(Mandatory=$true)][string]$publicDNSName,
      [Parameter(Mandatory=$true)][string]$username = "Administrator", 
      [Parameter(Mandatory=$true)][string]$password)

. ./dsc-ex2.ps1

function Create-CredentialObject
{ 
    param([Parameter(Mandatory=$true)][string]$username,
          [Parameter(Mandatory=$true)][string]$password)

    $securepassword = ConvertTo-SecureString $password -AsPlainText -Force
    return New-Object System.Management.Automation.PSCredential ($username, $securepassword)
}

function Run-DscEx2Script
{
    param([Parameter(Mandatory=$true)][string]$publicDNSName,
          [Parameter(Mandatory=$true)][string]$username,
          [Parameter(Mandatory=$true)][string]$password)

    $folder = resolve-path .
    $scriptpath = Join-Path -Path $folder -ChildPath "dsc-ex2.psm1"
    $outpath = Join-Path -Path (Join-Path -Path $folder -ChildPath "config") -ChildPath "dsc-ex2"
    New-Item -Path $outpath -Type directory -Force | Out-Null

    Set-Item WSMan:\localhost\Client\TrustedHosts -Value $publicDNSName -Force

    DscEx2 -ComputerName $publicDNSName -OutputPath $outpath

    $credential = Create-CredentialObject -username $username -password $password
    $cimSession = New-CimSession -ComputerName $publicDNSName -Credential $credential -Authentication Negotiate
    Start-DscConfiguration -Verbose -wait -Path $outpath -Force -CimSession $cimSession
}

Run-DscEx2Script -publicDNSName $publicDNSName -username $username -password $password