data "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  resource_group_name = var.key_vault_RG
}


resource "azurerm_key_vault_key" "kv_name-sto" {
  name         = var.sto-key-name
  key_vault_id = data.azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  
}
resource "azurerm_key_vault_access_policy" "storage" {
  key_vault_id = data.azurerm_key_vault.kv.id
  tenant_id    =   var.tenant_id
  object_id    =   var.object_id 

  key_permissions    = ["Get", "Create", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
}

resource "azurerm_storage_account_customer_managed_key" "example" {
  storage_account_id = var.storage_account_id
  key_vault_id       = data.azurerm_key_vault.kv.id
  key_name           = azurerm_key_vault_key.kv_name-sto.name
}

