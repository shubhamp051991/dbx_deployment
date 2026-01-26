# ========================================
# Deployment Mode
# ========================================

variable "deployment_mode" {
  description = "Deployment mode: 'full' creates all GCP infrastructure + workspace, 'workspace_only' creates only workspace using existing infrastructure"
  type        = string
  default     = "full"
  validation {
    condition     = contains(["full", "workspace_only"], var.deployment_mode)
    error_message = "deployment_mode must be either 'full' or 'workspace_only'"
  }
}

# ========================================
# GCP Configuration
# ========================================

variable "google_project" {
  description = "GCP Project ID where resources will be created"
  type        = string
}

variable "google_region" {
  description = "GCP region for resources (e.g., us-central1, us-west1)"
  type        = string
  default     = "us-central1"
}

# ========================================
# Databricks Account Configuration
# ========================================

variable "databricks_account_id" {
  description = "Databricks Account ID (found in Accounts Console)"
  type        = string
  sensitive   = true
}

variable "workspaces" {
  description = "Map of Databricks workspaces to create"
  type = map(object({
    workspace_name                       = string
    project_id                           = optional(string)
    region                               = optional(string)
    vpc_name                             = optional(string)
    subnet_name                          = optional(string)
    subnet_region                        = optional(string)
    vpc_host_project_id                  = optional(string)  # For Shared VPC: project ID where VPC resides
    workspace_service_account_email      = optional(string)  # Kept for documentation/reference
    cluster_service_account_email        = optional(string)  # Kept for documentation/reference
    enable_secure_cluster_connectivity   = optional(bool, true)
    
    # GCP Private Service Connect configuration (workspace_only mode only)
    enable_private_service_connect = optional(bool, false)
    private_service_connect = optional(object({

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
    }))
    
    # Workspace assignments - Users, Groups, and Service Principals
    workspace_admins = optional(list(object({
      principal_name = string
      type           = string
    })), [])
    
    workspace_users = optional(list(object({
      principal_name = string
      type           = string
    })), [])
  }))
  
  default = {
    "workspace1" = {
      workspace_name = "my-databricks-workspace"
    }
  }
}

variable "databricks_workspace_url" {
  description = "Databricks workspace URL (will be set after workspace creation)"
  type        = string
  default     = ""
}

variable "databricks_client_id" {
  description = "Databricks OAuth Client ID (Service Principal)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "databricks_client_secret" {
  description = "Databricks OAuth Client Secret (Service Principal)"
  type        = string
  default     = ""
  sensitive   = true
}

# ========================================
# Network Configuration (Full Mode)
# ========================================

variable "vpc_name" {
  description = "Name for the VPC network (used when deployment_mode = 'full')"
  type        = string
  default     = "databricks-vpc"
}

variable "subnet_name" {
  description = "Name for the subnet (used when deployment_mode = 'full')"
  type        = string
  default     = "databricks-subnet"
}

variable "subnet_primary_ip_range" {
  description = "Primary IP CIDR range for the subnet (for GCE cluster instances)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_private_google_access" {
  description = "Enable Private Google Access for the subnet"
  type        = bool
  default     = true
}

variable "enable_secure_cluster_connectivity" {
  description = "Enable Secure Cluster Connectivity (No Public IPs on clusters)"
  type        = bool
  default     = true
}

variable "enable_vpc_firewall_rules" {
  description = "Enable VPC firewall rules (only applies when deployment_mode = 'full')"
  type        = bool
  default     = true
}

variable "allowed_ip_ranges" {
  description = "List of IP CIDR ranges allowed to access Databricks workspace"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# ========================================
# Existing Infrastructure (Workspace-Only Mode)
# ========================================

variable "existing_vpc_name" {
  description = "Existing VPC network name (required when deployment_mode = 'workspace_only')"
  type        = string
  default     = ""
}

variable "existing_subnet_name" {
  description = "Existing subnet name (required when deployment_mode = 'workspace_only')"
  type        = string
  default     = ""
}

variable "existing_workspace_service_account_email" {
  description = "Email of existing workspace service account (required when deployment_mode = 'workspace_only')"
  type        = string
  default     = ""
}

variable "existing_cluster_service_account_email" {
  description = "Email of existing cluster service account (optional)"
  type        = string
  default     = ""
}

# ========================================
# Additional Configuration
# ========================================

variable "resource_prefix" {
  description = "Prefix to be added to resource names"
  type        = string
  default     = "dperez"
}

variable "enable_bigquery_access" {
  description = "Grant BigQuery access to cluster service account"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default = {
    terraform = "true"
    project   = "databricks"
  }
}
