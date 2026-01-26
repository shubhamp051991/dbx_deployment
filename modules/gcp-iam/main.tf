# Databricks Workspace Service Account
resource "google_service_account" "databricks_workspace_sa" {
  account_id   = "${var.resource_prefix}-db-workspace-sa"
  display_name = "Databricks Workspace Service Account"
  description  = "Service account for Databricks workspace to manage GCP resources"
  project      = var.project_id
}

# IAM Roles for Workspace Service Account
resource "google_project_iam_member" "workspace_sa_compute_admin" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.databricks_workspace_sa.email}"
}

resource "google_project_iam_member" "workspace_sa_network_user" {
  project = var.project_id
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:${google_service_account.databricks_workspace_sa.email}"
}

resource "google_project_iam_member" "workspace_sa_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.databricks_workspace_sa.email}"
}

# Databricks Cluster Service Account
resource "google_service_account" "databricks_cluster_sa" {
  account_id   = "${var.resource_prefix}-cluster-sa"
  display_name = "Databricks Cluster Service Account"
  description  = "Service account for Databricks clusters to access GCP resources"
  project      = var.project_id
}

# Storage Object Admin for cluster SA
resource "google_project_iam_member" "cluster_sa_storage_admin" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.databricks_cluster_sa.email}"
}

# BigQuery access (optional)
resource "google_project_iam_member" "cluster_sa_bigquery_editor" {
  count = var.enable_bigquery_access ? 1 : 0

  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.databricks_cluster_sa.email}"
}

resource "google_project_iam_member" "cluster_sa_bigquery_user" {
  count = var.enable_bigquery_access ? 1 : 0

  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.databricks_cluster_sa.email}"
}

