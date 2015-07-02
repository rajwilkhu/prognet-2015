# prognet-2015
Progressive .NET 2015 Presentation and tutorials

## Overview
At JUST EAT, when we upgrade our platform services within our AWS hosted environment, we don’t just update the package on the instances, we replace the old servers with new ones built from scratch. This is an extension of the phoenix server approach.

During this session, we are going to build instances, configure the OS and deploy code, all using powershell and DSC, just text that lives in a git repo.

We will start by setting up our environments for AWS and Azure (and Windows 10 if you have the latest insider preview installed). The following are the excercices in brief:

1. SetUp
2. Creating an EC2 instance with Windows Server 2012 R2 with WinRM enabled
3) Creating and executing a DSC configuration using built-in resources
4) Creating a custom DSC resource using built-in resources
5) Applying a DSC configuration to a EC2 LINUX instance
6) DSC, Docker and LINUX
7) DSC and Azure VMs
8) Windows 10