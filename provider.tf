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
  
  # Backend configuration
  # For CI/CD: backend-override.tf is created dynamically by GitHub Actions workflow
  # For local development: uncomment and configure the backend block below
  # 
  # backend "gcs" {
  #   bucket                      = "your-terraform-state-bucket"
  #   prefix                      = "databricks-workspaces"
  #   impersonate_service_account = "your-service-account@project.iam.gserviceaccount.com"
  # }
}

# GCP Provider Configuration
# 
# Authentication Methods:
# 
# 1. CI/CD (GitHub Actions with OIDC/WIF):
#    - Workflow authenticates via Workload Identity Federation
#    - Automatically impersonates the service account
#    - No additional configuration needed
#
# 2. Local Development:
#    a) Application Default Credentials: gcloud auth application-default login
#    b) Service Account Key: Set GOOGLE_CREDENTIALS environment variable
#    c) Service Account Impersonation: Uncomment impersonate_service_account below
#
# For local development with SA impersonation, uncomment the line below:
# provider "google" {
#   project                     = var.google_project
#   region                      = var.google_region
#   impersonate_service_account = "your-service-account@project.iam.gserviceaccount.com"
# }

provider "google" {
  project = var.google_project
  region  = var.google_region
}

# Databricks Provider Configuration for Account-Level Operations
#
# Authentication Methods:
#
# 1. Google Cloud Service Account (RECOMMENDED for this setup):
#    - The Google SA must be added as an account admin in Databricks Accounts Console
#    - Uses Google Cloud authentication automatically (ADC or WIF in CI/CD)
#    - No client_id/client_secret needed
#
# 2. OAuth M2M (Alternative):
#    - Set DATABRICKS_CLIENT_ID and DATABRICKS_CLIENT_SECRET environment variables
#    - Or specify client_id and client_secret explicitly
#
# For this deployment, we're using method #1 (Google SA as account admin)
provider "databricks" {
  alias      = "account"
  host       = "https://accounts.gcp.databricks.com"
  account_id = var.databricks_account_id
  
  # Google Cloud authentication is used automatically
  # The authenticated Google SA must have account admin permissions in Databricks
  
  # Alternative OAuth M2M authentication (uncomment if needed):
  # client_id     = var.databricks_client_id
  # client_secret = var.databricks_client_secret
}

# Databricks Provider Configuration for Workspace-Level Operations
# This provider will be used after the workspace is created
# It uses the workspace host URL for workspace-level resources
provider "databricks" {
  alias = "workspace"
  host  = var.databricks_workspace_url
  
  # Authentication via Google Cloud identity
  # Uses the same authentication as the GCP provider
}

