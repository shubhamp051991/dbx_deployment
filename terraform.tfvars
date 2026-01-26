# ========================================
# Example Configuration - Full Deployment Mode
# Multiple Workspaces Support
# ========================================

deployment_mode = "workspace_only"

# ========================================
# GCP Configuration
# ========================================

google_project = "gcp-sandbox-field-eng"
google_region  = "us-east1"

# ========================================
# Databricks Configuration
# ========================================

databricks_account_id = "f187f55a-9d3d-463b-aa1a-d55818b704c9"

# Optional: Set if not using environment variables
# databricks_client_id     = "your-client-id"
# databricks_client_secret = "your-client-secret"

# ========================================
# Workspaces Configuration
# Define multiple workspaces here
# ========================================

workspaces = {
  "workspace1" = {
    workspace_name                       = "dperez-dev-workspace"
    project_id                           = "gcp-sandbox-field-eng"
    region                               = "us-east1"
    vpc_name                             = "dperez-consul-proj"
    subnet_name                          = "dperez-subnet-1"
    subnet_region                        = "us-east1" 
    workspace_service_account_email      = "iac-databricks-workspace@gcp-sandbox-field-eng.iam.gserviceaccount.com"  # REQUIRED in workspace_only mode
    enable_secure_cluster_connectivity   = true

    # Workspace Admins - Users/Groups/Service Principals with ADMIN permissions
    workspace_admins = [
      {
        principal_name = "danilo.deoliveiraperez@databricks.com"
        type           = "user"
      },
      {
        principal_name = "data-engineering-team"
        type           = "group"
      }
    ]
    
    workspace_users = [
      {
        principal_name = "data-engineering-users"
        type           = "group"
      }
    ]
  }
}

# ========================================
# Network Configuration (Shared across workspaces in full mode)
# ========================================

vpc_name                = "databricks-infra-vpc"
subnet_name             = "databricks-subnet"
subnet_primary_ip_range = "10.0.0.0/16"

# ========================================
# Security Configuration
# ========================================

enable_private_google_access       = true
enable_secure_cluster_connectivity = true
enable_vpc_firewall_rules          = true
allowed_ip_ranges                  = ["0.0.0.0/0"]  # CHANGE THIS for production!

# ========================================
# IAM Configuration
# ========================================

enable_bigquery_access = true

# ========================================
# Resource Naming and Tagging
# ========================================

resource_prefix = "databricks"

tags = {
  terraform   = "true"
  project     = "databricks"
  cost_center = "data-platform"
}
