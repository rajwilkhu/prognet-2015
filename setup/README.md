# Setting up your environment for the sessions

## Prerequisites for AWS

* Install the latest AWS Tools for Powershell from:
   http://aws.amazon.com/powershell/

* Store your credentials to run the scripts in this session

Open up a powershell window and navigate to this directory prognet-2015\src\setup\

Run the following command:
```powershell
.\setup_credentials.ps1 -accessKey <your access key> -secretKey <your secret key>
```

## Prerequisites for Windows Azure

* Install and Configure Azure Powershell

https://azure.microsoft.com/en-us/documentation/articles/powershell-install-configure/#Install

Ideally set up your credentials using Add-AzureAccount. Use Get-AzurePublishSettingsFile and Import-AzurePublishSettingsFile to set up your default subscription

* If you have not got one already, create a new storage account for this session

```powershell
New-AzureStorageAccount -StorageAccountName "prognet" -Location "North Europe"
```

Once set up, you have to link the storage account to your azure subscription (i.e. make it current)

```powershell
Set-AzureSubscription -SubscriptionName "<Your subscription name>" -CurrentStorageAccountName (Get-AzureStorageAccount).Label -PassThru
```

You can verify your setup by executing the following commands:

```powershell
Get-AzureSubscription
Get-AzureStorageAccount
```
You want to make sure that the CurrentStorageAccountName on the Azure Subscription matches the label on the storage account