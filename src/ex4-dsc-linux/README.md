# Creating an EC2 Linux instance and enabling remoting

## Overview

* Copy the pem file from step 1 into this folder..

* Copy and extract the following zip file to C:\Windows\System32\WindowsPowerShell\v1.0\Modules\

https://github.com/MSFTOSSMgmt/WPSDSCLinux/releases/download/V1.0.0-320/nx.zip


## Create an EC2 instance

```powershell
.\create-ec2-instance.ps1 -name <your instance name> -keyPairName <your key pair name> -securityGroupName <your security group name>
```

### Links

https://prognet.signin.aws.amazon.com/console