$rgName = "rg-test-vm03";
az group create -n $rgName -l "northeurope";
$vmName = "vm-test03";
$storageAccountName = "stortestvm03";
$containerName = "container-test-vm03";

az vm create `
-n $vmName `
-g $rgName `
--admin-username "razumovsky_r" `
--admin-password "2HiVkwYAx0VKJoAC" `
--nsg-rule "RDP" `
--image "Win2022Datacenter" `
--public-ip-address "$vmName-ip01" `
--public-ip-address-allocation "static" `
--size "Standard_B4ms"

az vm create `
-n $vmName `
-g $rgName `
--admin-username "razumovsky_r" `
--admin-password "2HiVkwYAx0VKJoAC" `
--nsg-rule "RDP" `
--image "Win2022Datacenter" `
--public-ip-sku "Standard" `
--size "Standard_B4ms"

Set-AzVMCustomScriptExtension -ResourceGroupName <resourceGroupName> `
    -VMName $vmName `
    -Location "northeurope" `
    -FileUri <fileUrl> `
    -Run 'myScript.ps1' `
    -Name DemoScriptExtension

az storage account create `
--name $storageAccountName `
--resource-group $rgName `
--location "northeurope" `
--sku "Standard_LRS" `
--kind "StorageV2"

az storage container create `
--name $containerName `
--account-name $storageAccountName `
--public-access "off"

az group delete -n $rgName -y