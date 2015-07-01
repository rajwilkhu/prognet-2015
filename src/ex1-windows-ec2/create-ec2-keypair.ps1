param([Parameter(Mandatory=$true)][string]$name)
Import-Module "C:\Program Files (x86)\AWS Tools\PowerShell\AWSPowerShell\AWSPowerShell.psd1"

function New-KeyPair
{
    param([string]$name = 'prognet',
          [string]$region = 'eu-west-1')
    Set-DefaultAWSRegion $region

    $folder = resolve-path .
    $keyfile = Join-Path -Path $folder -ChildPath "$name.pem"
    if (Test-Path $keyfile -PathType Leaf)
    {
        throw "New-KeyPair - $keyfile already exists"
    }

    $keypair = New-EC2KeyPair -KeyName $name -ProfileName 'prognet'

    "$($keypair.KeyMaterial)" | Out-File -Encoding ascii -Filepath $keyfile
    "KeyName: $($keypair.KeyName)" | Out-File -encoding ascii -Filepath $keyfile -Append
    "KeyFingerprint: $($keypair.KeyFingerprint)" | Out-File -Encoding ascii -Filepath $keyfile -Append
}

New-KeyPair -name $name