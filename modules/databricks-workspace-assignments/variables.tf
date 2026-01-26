variable "workspace_id" {
  description = "Databricks workspace ID to assign users/groups to"
  type        = number
}

variable "workspace_admins" {
  description = "List of principals (users/groups/service principals) to assign as workspace admins"
  type = list(object({
    principal_name = string
    type           = string
  }))
  default = []
}

variable "workspace_users" {
  description = "List of principals (users/groups/service principals) to assign as workspace users"
  type = list(object({
    principal_name = string
    type           = string
  }))
  default = []
}

