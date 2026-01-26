output "workspace_id" {
  description = "The ID of the Databricks workspace"
  value       = databricks_mws_workspaces.this.workspace_id
}

output "workspace_name" {
  description = "The name of the Databricks workspace"
  value       = databricks_mws_workspaces.this.workspace_name
}

output "workspace_url" {
  description = "The URL of the Databricks workspace"
  value       = databricks_mws_workspaces.this.workspace_url
}

output "workspace_status" {
  description = "The status of the Databricks workspace"
  value       = databricks_mws_workspaces.this.workspace_status
}

output "network_id" {
  description = "The network ID used by the workspace"
  value       = databricks_mws_networks.this.network_id
}

