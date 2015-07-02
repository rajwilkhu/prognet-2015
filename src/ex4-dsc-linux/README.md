# Creating an EC2 Linux instance and enabling remoting

## Overview

* Copy the pem file from step 1 into this folder..

* Copy and extract the following zip file to C:\Windows\System32\WindowsPowerShell\v1.0\Modules\

https://github.com/MSFTOSSMgmt/WPSDSCLinux/releases/download/V1.0.0-320/nx.zip


## Create an EC2 instance

The userdata in the script has been set to create a LINUX instance with OMI and DSC installed.

```powershell
.\create-ec2-instance.ps1 -name <your instance name> -keyPairName <your key pair name> -securityGroupName <your security group name>
```

## Execute a DSC script against the instance to configure the OS and install other components

```powershell
.\execute-dsc-script.ps1 -publicDnsName <name of your server> -username "root" -password "P@33w0rd123!"
```

### Links

https://prognet.signin.aws.amazon.com/console