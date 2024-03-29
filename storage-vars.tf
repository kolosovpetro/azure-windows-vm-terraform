variable "storage_account_replication" {
  type        = string
  description = "Specifies the replication type for this storage account."
}

variable "storage_account_tier" {
  type        = string
  description = "Specifies the tier to use for this storage account."
}

variable "storage_enabled" {
  type        = bool
  description = "Specifies whether the storage should be enabled or disabled."
}
