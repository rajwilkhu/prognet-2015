$vm = New-AzureVMConfig -Name "prognet-1" -InstanceSize Small -ImageName "3a50f22b388a4ff7ab41029918570fa6__Windows-Server-2012-Essentials-20131018-enus"  

$vm = Add-AzureProvisioningConfig -VM $vm -Windows -AdminUsername "admin_account" -Password "P@33w0rd123!" 

$vm = Set-AzureVMDSCExtension -VM $vm -ConfigurationArchive "Dsc-Ex6.ps1.zip" -ConfigurationName "DscEx6"  

New-AzureVM -VM $vm -Location "North Europe" -ServiceName "prognet-1-svc" -WaitForBoot