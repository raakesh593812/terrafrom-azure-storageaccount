variable "key_vault_name" {
  type        = string
}

variable "key_vault_RG" {
    type        = string
}

variable "storage_account_id" {
  description = "The name of the azure storage account id"
  default     = ""
  type        = string
}

variable "storage_account_name" {
   type        = string
} 