# Azure Provider configuration
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}


# this block is required , if you require user managed identtity
resource "azurerm_user_assigned_identity" "example" {
  for_each            = toset(["testuser2"])
  resource_group_name = "terr-import-rg"
  location            = "eastus"
  name                = each.key
}

module "storage" {
  source  = "../../modules/storageaccount"

  resource_group_name   = "terr-import-rg"
  location              = "eastus"
  storage_account_name  = "zmystoragewzx"
  enable_advanced_threat_protection = true

  # Container lists 
  containers_list = [
    { name = "mystore250", access_type = "private" },
    { name = "blobstore251", access_type = "blob" },
    { name = "containter252", access_type = "container" }
  ]

  # SMB file share with quota (GB) to create
  file_shares = [
    { name = "smbfileshare1", quota = 50 },
    { name = "smbfileshare2", quota = 50 }
  ]

  # Storage tables
  tables = ["table1", "table2", "table3"]

  # Storage queues
  queues = ["queue1", "queue2"]

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

module "cus-managed-kv" {
  depends_on = [
    module.storage
  ]
  source  = "../../modules/cus-managed-key" 
  key_vault_name = "tfe-tex1"
  key_vault_RG   = "myResourceGroup"
  sto-key-name = "${module.storage.storage_account_name}-cus-key1"
  tenant_id    =   module.storage.tenant_id
  object_id    =   module.storage.managedidentity
  storage_account_id = module.storage.storage_account_id
   
}
