param([Parameter(Mandatory=$true)][string]$accessKey,
      [Parameter(Mandatory=$true)][string]$secretKey)

Import-Module "C:\Program Files (x86)\AWS Tools\PowerShell\AWSPowerShell\AWSPowerShell.psd1"

Set-AWSCredentials -AccessKey $accessKey -SecretKey $secretKey -StoreAs 'prognet'