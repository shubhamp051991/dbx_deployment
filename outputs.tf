# ========================================
# Databricks Workspaces Outputs (Multiple)
# ========================================

output "workspaces" {
  description = "Map of all deployed workspaces with their details"
  value = {
    for key, workspace in module.databricks_workspaces : key => {
      workspace_id     = workspace.workspace_id
      workspace_name   = workspace.workspace_name
      workspace_url    = workspace.workspace_url
      workspace_status = workspace.workspace_status
    }
  }
}

output "workspace_urls" {
  description = "Map of workspace keys to their URLs for easy access"
  value = {
    for key, workspace in module.databricks_workspaces : key => workspace.workspace_url
  }
}

output "workspace_assignments" {
  description = "Map of workspace assignments (admins and users)"
  value = {
    for key, assignments in module.workspace_assignments : key => {
      admins = assignments.admin_assignments
      users  = assignments.user_assignments
    }
  }
}

# ========================================
# GCP Network Outputs
# ========================================

output "vpc_name" {
  description = "The name of the VPC network"
  value       = local.is_full_deployment ? module.gcp_network[0].vpc_name : var.existing_vpc_name
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = local.is_full_deployment ? module.gcp_network[0].subnet_name : var.existing_subnet_name
}

# ========================================
# GCP IAM Outputs
# ========================================

output "workspace_service_account_email" {
  description = "Email address of the Databricks workspace service account"
  value       = local.workspace_sa_email
}

output "cluster_service_account_email" {
  description = "Email address of the Databricks cluster service account"
  value       = local.cluster_sa_email
}

# ========================================
# Deployment Information
# ========================================

output "deployment_mode" {
  description = "The deployment mode used (full or workspace_only)"
  value       = var.deployment_mode
}

output "gcp_project_id" {
  description = "The GCP Project ID where resources are deployed"
  value       = var.google_project
}

output "gcp_region" {
  description = "The GCP region where resources are deployed"
  value       = var.google_region
}

