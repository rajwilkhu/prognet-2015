<#
.Synopsis
   Execute generated DSC configuration against specified host.
.DESCRIPTION
   This script is used to enact the generated DSC configuration
   on the specified host. It collects the "root" user's credential and
   initates a CIM session. Upon completion, the CIM session is removed.
.PARAMETER Hostname
   The node on which the Docker configuration should be enacted. This parameter
   may be used in conjunction with the ConfigurationData parameter provided that there
   are no duplicate node names.
.PARAMETER ConfigurationData
   The path to the .psd1 configuration data file. CIM sessions will be
   established to all nodes defined in the AllNodes array. This parameter
   may be used in conjunction with the Hostname parameter provided that there
   are no duplicate node names.
.PARAMETER Credential
   The credential used to connect to the target Linux node. If this parameter isn't used,
   you will be prompted to supply a credential.
.EXAMPLE
   .\RunDockerClientConfig.ps1 -Hostname "mgmt01.contoso.com"

   Configures a CIM session to "mgmt01.contoso.com" and executes Start-DscConfiguration.


   .\RunDockerClientConfig.ps1 -ConfigurationData ".\SampleConfigData.psd1"

   Configures a CIM session for each node defined in the AllNodes array in the "SampleConfigData.psd1" file.
.NOTES
   Ensure that the DockerClient.ps1 DSC configuration has been
   executed and a subsequent .mof file has been generated prior to
   running this script.

   Author: Andrew Weiss | Microsoft
           andrew.weiss@microsoft.com
#>

param
(
    [string]$Hostname,
    [string]$ConfigurationData,
    [System.Management.Automation.PSCredential]$Credential

)

if (!$Credential) {
    $cred = Get-Credential -UserName "root" -Message "Enter password"
}

$options = New-CimSessionOption -UseSsl -SkipCACheck -SkipCNCheck -SkipRevocationCheck
if ($ConfigurationData) {
    $data = Invoke-Expression -Command "$(Get-Content -Path $ConfigurationData)"
    $nodes = $data.AllNodes.Nodename
}

if ($Hostname) {
    $nodes += $Hostname
}

$session = New-CimSession -Credential $cred -ComputerName $nodes -Port 5986 -Authentication basic -SessionOption $options -OperationTimeoutSec 600
Start-DscConfiguration -CimSession $session -Path $PSScriptRoot\DockerClient -Verbose -Wait -Force

$session | Remove-CimSession