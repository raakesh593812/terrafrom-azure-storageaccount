# Azure Provider configuration
provider "azurerm" {
  features {}
}


# this block is required , if you require user managed identtity
resource "azurerm_user_assigned_identity" "example" {
  for_each            = toset(["testuser21"])
  resource_group_name = "terr-import-rg"
  location            = "eastus"
  name                = each.key
}

module "storage" {
  source  = "../../modules/storageaccount"

  resource_group_name   = "terr-import-rg"
  location              = "eastus"
  storage_account_name  = "zmystorag1xyxz"
  enable_advanced_threat_protection = true

  # Container lists 
  containers_list = [
    { name = "mystore250", access_type = "private" }
  ]

  # SMB file share with quota (GB) to create
  file_shares = [
    { name = "smbfileshare1", quota = 50 },
    { name = "smbfileshare2", quota = 50 }
  ]


  # Configure managed identities to access Azure Storage (Optional)
  # Possible types are `SystemAssigned`, `UserAssigned` and `SystemAssigned, UserAssigned`.
  managed_identity_type = "SystemAssigned, UserAssigned"
  managed_identity_ids  = [for k in azurerm_user_assigned_identity.example : k.id]

  # Lifecycle management for storage account.
  # Must specify the value to each argument and default is `0` 
  lifecycles =   []

  # Adding TAG's to your Azure resources (Required)
  # ProjectName and Env are already declared above, to use them here, create a varible. 
  tags = {
    ProjectName  = "demo-internal"
    Env          = "dev"
    Owner        = "user@example.com"
    BusinessUnit = "CORP"
    ServiceClass = "Gold"
  }
}



# module "storage-kv" {
#  source  = "../../modules/sto-managed-kv"
# storage_account_name  = module.storage.storage_account_name
# key_vault_name = "tfe-tex" 
# key_vault_RG = "myResourceGroup" 
# storage_account_id = module.storage.storage_account_id
#  }
data "azurerm_client_config" "current" {}
resource "azurerm_key_vault_access_policy" "example" {
  key_vault_id = "/subscriptions/7493c606-7d9a-48cb-8bb3-eca30de998c9/resourceGroups/myResourceGroup/providers/Microsoft.KeyVault/vaults/tfe-tex"
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id
       
         key_permissions = [
       "Backup",
       "Create",
       "Decrypt",
       "Delete",
       "Encrypt",
       "Get",
       "Import",
       "List",
       "Purge",
       "Recover",
       "Restore",
       "Sign",
       "UnwrapKey",
       "Update",
       "Verify",
       "WrapKey"
         ]

  secret_permissions = [
      "Get",
      "Delete",
      "Set",
      "Backup",
      "Recover"
    ]
    storage_permissions = [
      "Get",
      "List",
      "Set",
      "SetSAS",
      "GetSAS",
      "DeleteSAS",
      "Update",
      "RegenerateKey"
    ]
}

resource "azurerm_key_vault_managed_storage_account" "example" {
  name                         = "zmystorag1xyxz"
  key_vault_id                 = "/subscriptions/7493c606-7d9a-48cb-8bb3-eca30de998c9/resourceGroups/myResourceGroup/providers/Microsoft.KeyVault/vaults/tfe-tex"
  storage_account_id           = module.storage.storage_account_id
  storage_account_key          = "key1"
  regenerate_key_automatically = false
  regeneration_period          = "P1D"
}