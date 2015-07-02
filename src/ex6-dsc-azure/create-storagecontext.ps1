$StorageAccount = 'prognet'
$StorageKey = 'qr14PPdBei5BX8XVcMu7Vrmu+e+rAtT/HN9ezGmzjRU/g+3g+8KmCDAIeYc0vWHRra/f0wFoLWZvP4TtADMRqw=='
$StorageContainer = 'dscarchives'
 
$storageContext = New-AzureStorageContext -StorageAccountName $StorageAccount -StorageAccountKey $StorageKey