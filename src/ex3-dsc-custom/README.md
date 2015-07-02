# Powershell DSC using custom resources

* Create a folder called cProgNet

Navigate into this directory and execute the following command:

```powershell
New-ModuleManifest -Path cPrognet.psd1 -ModuleVersion "1.0.0.0" -Author <your name>
``` 

* Create a sub folder called cWebFeaturesInstaller

By convention all custom resources start with the letter 'c' and all experimental resources start with the letter 'x'

* Create a file called cWebFeaturesInstaller.schema.psm1

and create a DSC configuration as follows:

```powershell
Configuration cWebFeaturesInstaller
{

}
```

* Copy the features from the original file into this file within the configuration

* Open up an x64 Powershell command prompt window and navigate to this dirtectory. Execute the following command:

```powershell
New-ModuleManifest -Path .\cWebFeaturesInstaller.psd1 -RootModule .\cWebFeaturesInstaller.schema.psm1
```

This will generate a module manifest file. You can open up the file and tweak some of the properties.

* Remove the entries from original DSC configuration file and add the following line before Node

```powershell
Import-DscResource -Module cProgNet
```

Add the following line to the original dsc-ex2.ps1 configuration file:

cWebFeaturesInstaller Install-Web-Features { }

* We have to copy the module to the modules location on the local machine:

C:\Program Files\WindowsPowerShell\Modules


* Re-run the script

The MOF file generated is completely different.


### Notes

You can use the Powershell Resource Designer Module to speed up resource creation. You can get this from the following location:

https://gallery.technet.microsoft.com/scriptcenter/xDscResourceDesigne-Module-22eddb29

