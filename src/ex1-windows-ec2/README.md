# Creating an EC2 Windows instance and enabling remoting

## Overview

## Creating a security group allowing WinRM access to the remote instance

```powershell
.\create-ec2-securitygroup.ps1 -name <your security group name>
```

## Creating a key pair for accessing the password on the new instance

```powershell
.\create-ec2-keypair.ps1 -name <your key pair name>

This script will generate an ec2 key pair and write a new pem file locally 