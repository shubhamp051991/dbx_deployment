output "workspace_service_account_email" {
  description = "Email address of the Databricks workspace service account"
  value       = google_service_account.databricks_workspace_sa.email
}

output "workspace_service_account_id" {
  description = "ID of the Databricks workspace service account"
  value       = google_service_account.databricks_workspace_sa.id
}

output "cluster_service_account_email" {
  description = "Email address of the Databricks cluster service account"
  value       = google_service_account.databricks_cluster_sa.email
}

output "cluster_service_account_id" {
  description = "ID of the Databricks cluster service account"
  value       = google_service_account.databricks_cluster_sa.id
}

