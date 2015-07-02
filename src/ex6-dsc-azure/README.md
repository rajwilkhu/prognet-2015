# Powershell DSC and Azure

## Overview

## 

Import-Module "C:\Program Files (x86)\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Azure.psd1"

Get-AzureVMAvailableExtension -Publisher Microsoft.Powershell

Publish-AzureVMDscConfiguration .\dsc-ex6.ps1 -StorageContext $storageContext -ContainerName $StorageContainer