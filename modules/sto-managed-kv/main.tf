
#---------------------------------------------------------
# Resource Group Creation or selection - Default is "false"
#----------------------------------------------------------
data "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  resource_group_name = var.key_vault_RG
}

data "azurerm_client_config" "sp-data" {}

resource "azurerm_role_assignment" "sto-access" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Account Key Operator Service Role"
  principal_id         = data.azurerm_client_config.sp-data.object_id
}

resource "azurerm_key_vault_managed_storage_account" "dto-kv" {
  name                         = var.storage_account_name
  key_vault_id                 = data.azurerm_key_vault.kv.id
  storage_account_id           = var.storage_account_id
  storage_account_key          = "key1"
  

}
