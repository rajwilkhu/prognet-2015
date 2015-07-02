# Creating an EC2 Windows instance and enabling remoting

## Overview

In order to apply DSC configurations to a remote EC2 instance, you need to create a security group and set up firewall rules to open up WinRM ports. The following steps guide you through creating a security group, a key pair for decrypting the instance password, and an EC2 instance running Windows Server 2012 R2 with WinRM setup.

## Creating a security group allowing WinRM access to the remote instance

A security group defines inbound and outbound rules for resources within AWS. Ports (5985 and 5986) are required for WinRM. We are going to open up port 3389 for RDP access during this session. To create a security group for this session, please run the following powershell script supplying a name (something that ends in "-sg" which will be needed later on).

```powershell
.\create-ec2-securitygroup.ps1 -name <your security group name>
```

## Creating a key pair for accessing the password on the new instance

A keypair is required to decrypt the EC2 instance Windows password. We will be using the generated key pair to extract the windows password from the instance. Please run the following powershell script supplying a name that ends in "-k", needed in later excercises" 

```powershell
.\create-ec2-keypair.ps1 -name <your key pair name>
```

This script will generate an ec2 key pair and write a new pem file locally.

## Create an EC2 instance

You will need the security group and key pair to create an instance. The script has been setup to pick up a Windows Server 2012 Base AMI as the base image. 

```powershell
.\create-ec2-instance.ps1 -name <your instance name> -keyPairName <your key pair name> -securityGroupName <your security group name>
```

Once run, you should be able to RDP to the instance. You are now ready to start configuring the machine using DSC!

### Links

https://prognet.signin.aws.amazon.com/console