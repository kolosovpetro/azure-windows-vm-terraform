data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "public" {
  location = var.resource_group_location
  name     = "${var.resource_group_name}-${var.prefix}"
}

module "network" {
  source                  = "./modules/network"
  nsg_name                = "${var.nsg_name}-${var.prefix}"
  resource_group_location = azurerm_resource_group.public.location
  resource_group_name     = azurerm_resource_group.public.name
  subnet_name             = "${var.subnet_name}-${var.prefix}"
  vnet_name               = "${var.vnet_name}-${var.prefix}"

  depends_on = [
    azurerm_resource_group.public
  ]
}

module "storage" {
  source                                = "./modules/storage"
  custom_script_extension_absolute_path = var.custom_script_extension_absolute_path
  custom_script_extension_file_name     = var.custom_script_extension_file_name
  storage_account_name                  = "${var.storage_account_name}${var.prefix}"
  storage_account_replication           = var.storage_account_replication
  storage_account_tier                  = var.storage_account_tier
  storage_container_name                = "${var.storage_container_name}${var.prefix}"
  storage_location                      = azurerm_resource_group.public.location
  storage_resource_group_name           = azurerm_resource_group.public.name

  depends_on = [
    azurerm_resource_group.public
  ]
}

module "virtual_machine" {
  source                            = "./modules/vm"
  ip_configuration_name             = var.ip_configuration_name
  network_interface_name            = "${var.network_interface_name}-${var.prefix}"
  network_security_group_id         = module.network.network_security_group_id
  os_profile_admin_password         = var.os_profile_admin_password
  os_profile_admin_username         = var.os_profile_admin_username
  os_profile_computer_name          = var.os_profile_computer_name
  public_ip_name                    = "${var.public_ip_name}-${var.prefix}"
  resource_group_location           = azurerm_resource_group.public.location
  resource_group_name               = azurerm_resource_group.public.name
  storage_image_reference_offer     = var.storage_image_reference_offer
  storage_image_reference_publisher = var.storage_image_reference_publisher
  storage_image_reference_sku       = var.storage_image_reference_sku
  storage_image_reference_version   = var.storage_image_reference_version
  storage_os_disk_caching           = var.storage_os_disk_caching
  storage_os_disk_create_option     = var.storage_os_disk_create_option
  storage_os_disk_managed_disk_type = var.storage_os_disk_managed_disk_type
  storage_os_disk_name              = "${var.storage_os_disk_name}-${var.prefix}"
  subnet_id                         = module.network.subnet_id
  vm_name                           = "${var.vm_name}-${var.prefix}"
  vm_size                           = var.vm_size
}

module "key_vault" {
  source                 = "./modules/keyvault"
  kv_location            = azurerm_resource_group.public.location
  kv_name                = "${var.kv_name}-${var.prefix}"
  kv_resource_group_name = azurerm_resource_group.public.name
  object_id              = data.azurerm_client_config.current.object_id
  tenant_id              = data.azurerm_client_config.current.tenant_id
}

#resource "azurerm_virtual_machine_extension" "public" {
#  name                 = "${var.os_profile_computer_name}1"
#  virtual_machine_id   = module.virtual_machine.vm_id
#  publisher            = "Microsoft.Compute"
#  type                 = "CustomScriptExtension"
#  type_handler_version = "1.10"
#
#  depends_on = [
#    module.virtual_machine,
#    module.storage
#  ]
#
#  settings = <<SETTINGS
#        {
#            "fileUris": [
#                "${module.storage.blob_url}"
#                ],
#            "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File ${var.custom_script_extension_file_name}"
#        }
#    SETTINGS
#}