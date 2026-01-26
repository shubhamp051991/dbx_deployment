# ========================================
# Local Variables
# ========================================

locals {
  is_full_deployment = var.deployment_mode == "full"
  is_workspace_only  = var.deployment_mode == "workspace_only"

  # Use created or existing VPC/Subnet based on deployment mode
  vpc_name    = local.is_full_deployment ? module.gcp_network[0].vpc_name : var.existing_vpc_name
  subnet_name = local.is_full_deployment ? module.gcp_network[0].subnet_name : var.existing_subnet_name

  # Use created or existing service accounts based on deployment mode
  workspace_sa_email = local.is_full_deployment ? module.gcp_iam[0].workspace_service_account_email : var.existing_workspace_service_account_email
  cluster_sa_email   = local.is_full_deployment ? module.gcp_iam[0].cluster_service_account_email : var.existing_cluster_service_account_email

  # Common tags for all resources
  base_tags = merge(
    {
      terraform       = "true"
      deployment_mode = var.deployment_mode
    },
    var.tags
  )
}

# ========================================
# GCP Network Module (Full Deployment Only)
# ========================================

module "gcp_network" {
  count  = local.is_full_deployment ? 1 : 0
  source = "./modules/gcp-network"

  project_id                         = var.google_project
  region                             = var.google_region
  vpc_name                           = var.vpc_name
  subnet_name                        = var.subnet_name
  subnet_primary_ip_range            = var.subnet_primary_ip_range
  enable_private_google_access       = var.enable_private_google_access
  enable_secure_cluster_connectivity = var.enable_secure_cluster_connectivity
  enable_vpc_firewall_rules          = var.enable_vpc_firewall_rules
  allowed_ip_ranges                  = var.allowed_ip_ranges
  resource_prefix                    = var.resource_prefix
  tags                               = local.base_tags
}

# ========================================
# GCP IAM Module (Full Deployment Only)
# ========================================

module "gcp_iam" {
  count  = local.is_full_deployment ? 1 : 0
  source = "./modules/gcp-iam"

  project_id             = var.google_project
  resource_prefix        = var.resource_prefix
  enable_bigquery_access = var.enable_bigquery_access
  tags                   = local.base_tags
}

# ========================================
# Databricks Workspaces (Multiple via for_each)
# ========================================

module "databricks_workspaces" {
  for_each = var.workspaces
  source   = "./modules/databricks-workspace"

  providers = {
    databricks.account = databricks.account
  }

  databricks_account_id = var.databricks_account_id
  workspace_name        = each.value.workspace_name
  gcp_project_id = coalesce(each.value.project_id, var.google_project)
  gcp_region = coalesce(each.value.region, var.google_region)
  vpc_name            = coalesce(each.value.vpc_name, local.vpc_name)
  subnet_name         = coalesce(each.value.subnet_name, local.subnet_name)
  subnet_region       = coalesce(each.value.subnet_region, each.value.region, var.google_region)
  vpc_host_project_id = each.value.vpc_host_project_id  # For Shared VPC (null = same project as workspace)
  enable_secure_cluster_connectivity = each.value.enable_secure_cluster_connectivity
  
  # GCP Private Service Connect configuration
  deployment_mode                = var.deployment_mode
  enable_private_service_connect = each.value.enable_private_service_connect
  private_service_connect        = each.value.private_service_connect
  
  depends_on = [
    module.gcp_network,
    module.gcp_iam
  ]
}

# ========================================
# Workspace Assignments (Users, Groups, Service Principals)
# ========================================

module "workspace_assignments" {
  for_each = var.workspaces
  source   = "./modules/databricks-workspace-assignments"

  providers = {
    databricks.account = databricks.account
  }

  workspace_id     = module.databricks_workspaces[each.key].workspace_id
  workspace_admins = each.value.workspace_admins
  workspace_users  = each.value.workspace_users

  depends_on = [
    module.databricks_workspaces
  ]
}
