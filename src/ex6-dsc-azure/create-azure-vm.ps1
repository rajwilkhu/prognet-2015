$vm = New-AzureVMConfig -Name "prognet-1" -InstanceSize Small -ImageName "a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-201407.01-en.us-127GB.vhd"  

$vm = Add-AzureProvisioningConfig -VM $vm -Windows -AdminUsername "admin_account" -Password "P@33w0rd123!" 

$vm = Set-AzureVMDSCExtension -VM $vm -ConfigurationArchive "Dsc-Ex6.ps1.zip" -ConfigurationName "DscEx6"  

New-AzureVM -VM $vm -Location "Northen Europe" -ServiceName "prognet-1-svc" -WaitForBoot