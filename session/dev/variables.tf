variable "management_admin_username" {
  description = "Local administrator username for the management VM."
  type        = string
  default     = "rapidadmin"
  nullable    = false

  validation {
    condition = (
      length(var.management_admin_username) >= 1 &&
      length(var.management_admin_username) <= 20 &&
      can(regex("^[A-Za-z][A-Za-z0-9_-]*$", var.management_admin_username))
    )
    error_message = "The management admin username must be 1-20 characters long, start with a letter, and contain only letters, numbers, underscores, or hyphens."
  }
}

variable "management_admin_password" {
  description = "Local administrator password supplied by Azure DevOps."
  type        = string
  sensitive   = true
  nullable    = false

  validation {
    condition = (
      length(var.management_admin_password) >= 12 &&
      can(regex("[A-Z]", var.management_admin_password)) &&
      can(regex("[a-z]", var.management_admin_password)) &&
      can(regex("[0-9]", var.management_admin_password)) &&
      can(regex("[^A-Za-z0-9]", var.management_admin_password))
    )
    error_message = "The management admin password must be at least 12 characters long and contain uppercase letters, lowercase letters, numbers, and special characters."
  }
}

variable "enable_firewall" {
  description = "Deploy the session Firewall and its dependent routing."
  type        = bool
  default     = false
  nullable    = false
}

variable "enable_iaas_app" {
  description = "Deploy the internal Load Balancer and VMSS application tier."
  type        = bool
  default     = false
  nullable    = false
}