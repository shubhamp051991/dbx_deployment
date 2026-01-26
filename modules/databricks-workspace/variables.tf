variable "databricks_account_id" {
  description = "Databricks Account ID"
  type        = string
  sensitive   = true
}

variable "workspace_name" {
  description = "Name for the Databricks workspace"
  type        = string
}

variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region for the workspace"
  type        = string
}

variable "vpc_name" {
  description = "VPC network name for the workspace (not full ID, just the name)"
  type        = string
}

variable "subnet_name" {
  description = "Subnet name for the workspace (not full ID, just the name)"
  type        = string
}

variable "subnet_region" {
  description = "GCP region where the subnet is located (can differ from workspace region)"
  type        = string
}

variable "vpc_host_project_id" {
  description = "GCP Project ID where the VPC/subnet is located (for Shared VPC). If not set, defaults to gcp_project_id (same project)"
  type        = string
  default     = null
}

variable "enable_secure_cluster_connectivity" {
  description = "Enable Secure Cluster Connectivity (No Public IPs on GCE clusters)"
  type        = bool
  default     = true
}

variable "deployment_mode" {
  description = "Deployment mode: 'full' or 'workspace_only'"
  type        = string
  default     = "full"
}

variable "enable_private_service_connect" {
  description = "Enable GCP Private Service Connect for backend private link (workspace_only mode only)"
  type        = bool
  default     = false
}

variable "private_service_connect" {
  description = "GCP Private Service Connect configuration (only used when enable_private_service_connect = true)"
  type = object({
    # Relay VPC Endpoint (REQUIRED) - name of GCP PSC forwarding rule
    relay_endpoint_name       = string
    relay_endpoint_project_id = optional(string)
    relay_endpoint_region     = optional(string)
    
    # Workspace VPC Endpoint (OPTIONAL) - name of GCP PSC forwarding rule
    workspace_endpoint_name       = optional(string)
    workspace_endpoint_project_id = optional(string)
    workspace_endpoint_region     = optional(string)
    
    # Private Access Settings
    public_access_enabled = optional(bool, false)
    private_access_level  = optional(string, "ACCOUNT")
  })
  default = null
}

