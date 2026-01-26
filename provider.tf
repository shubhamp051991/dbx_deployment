terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.0"
    }
  }
  required_version = ">= 1.0"
}

# GCP Provider Configuration
# Authenticate using one of the following methods:
# 1. Application Default Credentials (ADC) - run: gcloud auth application-default login
# 2. Service Account Key - set GOOGLE_CREDENTIALS environment variable
# 3. Explicitly provide credentials_file or access_token

provider "google" {
  project = var.google_project
  region  = var.google_region
}

# Databricks Provider Configuration for Account-Level Operations
# This provider is used to create and manage the Databricks workspace
# Authenticate using one of the following methods:
# 1. OAuth M2M (Machine-to-Machine) - recommended for production
#    Set DATABRICKS_CLIENT_ID and DATABRICKS_CLIENT_SECRET
# 2. Databricks Account credentials
#    Set DATABRICKS_ACCOUNT_ID, DATABRICKS_CLIENT_ID, DATABRICKS_CLIENT_SECRET
provider "databricks" {
  alias      = "account"
  host       = "https://accounts.gcp.databricks.com"
  account_id = var.databricks_account_id
  
  # Authentication via OAuth M2M (Service Principal)
  # Requires DATABRICKS_CLIENT_ID and DATABRICKS_CLIENT_SECRET environment variables
  # Or you can specify them explicitly:
  # client_id     = var.databricks_client_id
  # client_secret = var.databricks_client_secret
}

# Databricks Provider Configuration for Workspace-Level Operations
# This provider will be used after the workspace is created
# It uses the workspace host URL for workspace-level resources
provider "databricks" {
  alias = "workspace"
  host  = var.databricks_workspace_url
  
  # Authentication can be done via:
  # 1. Google Cloud identity (using gcloud auth application-default login)
  # 2. Personal Access Token (PAT)
  # 3. OAuth M2M
}

