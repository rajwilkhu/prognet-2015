# Powershell DSC using built-in resources

* Start an elevated x64 Powershell session

> DSC Only works within a Powershell x64 environment

* A helper script has been provided that allows you to execute the dsc configuration defined in dsc-ex2.ps1. You can "compile", "send" and ask the remote machine to "evaluate" the configuration using the script.

```powershell
.\execute-dsc-script.ps1 -publicDNSName <dns name of your machine> -username "Administrator" -password <password>
```
> You can find the DNS name of your machine and password in the .cxml file generated in the previous step

## Powershell commands to execute the DSC configuration

```powershell
DscEx2 -ComputerName <dns name of your machine> -OutputPath <where the MOF file was generated>
```

### MOF files

MOF is a DMTF standard currently used by OS WBEM management frameworks such as WMI and OpenWBEM. 