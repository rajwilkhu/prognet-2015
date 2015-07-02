# Powershell DSC and Azure

## Overview
Azure provides extensions and an SDK for DSC that allows you to apply a DSC configuration whilst building the VM. In order to do this, you have to push the compiled MOF to blob storage to allow the DSC Extensions to pick them up.

## Running Azure Powershell DSC commands

DSC commands have to be run within an elevated powershell x64 environment. The default shortcut that comes with the Azure powershell environment is x86. Locate Powershell x64 and run as elevated. Import the Azure module:

```powershell
Import-Module "C:\Program Files (x86)\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Azure.psd1"
```

* You can verify that your install of Azure tools includes the DSC extension by executing the following:

```powershell
Get-AzureVMAvailableExtension -Publisher Microsoft.Powershell
```

* Create a storage context using the script in this folder. Get the storage key from the Azure Management console.

```powershell
.\create-storagecontext.ps1
```

Once you have the storage context, run the following command to publish the DSC configuration to blob storage:

```powershell
$StorageContainer = 'dscarchives'
Publish-AzureVMDscConfiguration .\dsc-ex6.ps1 -StorageContext $storageContext -ContainerName $StorageContainer
```

* Generate the VM from the DSC configuration by executing the following powershell script

```powershell
.\create-azure-vm.ps1
```