# Azure Provider configuration
provider "azurerm" {
  features {}
  
  subscription_id = "7493c606-7d9a-48cb-8bb3-eca30de998c9" 
 client_id = "550b2c52-7eb5-47af-a23f-4a292bd7c2d6" 
 client_secret = "oYR7Q~IOUkl5IM.XvJQLaFgQPmcotzQ6kb~7g"
 tenant_id =  "9e4857ba-de33-4c52-9c2c-60ace8819252"
}

# this block is required , if you require user managed identtity
# resource "azurerm_user_assigned_identity" "example" {
#   for_each            = toset(["testuser2"])
#   resource_group_name = "terr-import-rg"
#   location            = "eastus"
#   name                = each.key
# }

module "storage" {
  source  = "../../modules/storageaccount"

  resource_group_name   = "terr-import-rg"
  location              = "eastus"
  storage_account_name  = "zmystoragew1x"
  enable_advanced_threat_protection = true

  # Container lists 
  containers_list = [
    { name = "mystore250", access_type = "private" },
    { name = "blobstore251", access_type = "blob" },
    { name = "containter252", access_type = "container" }
  ]

  # SMB file share with quota (GB) to create
  # file_shares = [
  #   { name = "smbfileshare1", quota = 50 },
  #   { name = "smbfileshare2", quota = 50 }
  # ]

  # Storage tables
  #tables = ["table1", "table2", "table3"]

  # Storage queues
  #queues = ["queue1", "queue2"]
  enable_adls =  true
  # Configure managed identities to access Azure Storage (Optional)
  # Possible types are `SystemAssigned`, `UserAssigned` and `SystemAssigned, UserAssigned`.
  managed_identity_type = "SystemAssigned"
  #managed_identity_ids  = [for k in azurerm_user_assigned_identity.example : k.id]

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

