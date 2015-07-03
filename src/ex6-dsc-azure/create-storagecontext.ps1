$StorageAccount = 'prognet'
$StorageKey = '<your storage key>'
$StorageContainer = 'dscarchives'
 
$storageContext = New-AzureStorageContext -StorageAccountName $StorageAccount -StorageAccountKey $StorageKey