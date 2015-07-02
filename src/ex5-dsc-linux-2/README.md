# Powershell DSC and Docker

## Overview
In this excercise, we will use Powershell DSC for LINUX to install docker and link two containers - a database (mongodb) and a web container (pre-packaged boilerplate web application based on the PlatypusTS framework)

Using the scripting module for DSC, we will install docker and set up two containers.

## Execute a DSC script against the instance to configure the OS and install other components

```powershell
.\execute-dsc-script.ps1 -publicDnsName <name of your server> -username "root" -password "P@33w0rd123!"
```

## Get the ip address of the MongoDb container

The following requires logging on to the box to execute at the moment, this step can also be automated. Accessing the  EC2 instance over "ssh" using PUTTY requires creating a PUTTY private key file.

sudo docker inspect --format="{{ .NetworkSettings.IPAddress }}" db

## Execute a DSC script against the instance to configure the OS and install other components

```powershell
.\execute-dsc-script-linked.ps1 -publicDnsName <name of your server> -username "root" -password "P@33w0rd123!" -mongoIp <mongo ip address>
```
