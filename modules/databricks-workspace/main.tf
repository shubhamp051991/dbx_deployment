# ========================================
# GCP Private Service Connect (PSC) Resources
# Only created when enable_private_service_connect = true
# ========================================

# Relay VPC Endpoint (required for PSC)
resource "databricks_mws_vpc_endpoint" "relay" {
  count = var.enable_private_service_connect && var.deployment_mode == "workspace_only" && var.private_service_connect != null ? 1 : 0

  provider = databricks.account
  account_id        = var.databricks_account_id
  vpc_endpoint_name = "${var.workspace_name}-rl-pl"

  gcp_vpc_endpoint_info {
    project_id        = coalesce(try(var.private_service_connect.relay_endpoint_project_id, null), var.gcp_project_id)
    psc_endpoint_name = var.private_service_connect.relay_endpoint_name
    endpoint_region   = coalesce(try(var.private_service_connect.relay_endpoint_region, null), var.gcp_region)
  }
}

# Workspace Backend VPC Endpoint (optional for PSC)
resource "databricks_mws_vpc_endpoint" "workspace" {
  count = var.enable_private_service_connect && var.deployment_mode == "workspace_only" && var.private_service_connect != null && try(var.private_service_connect.workspace_endpoint_name, null) != null ? 1 : 0

  provider = databricks.account
  account_id        = var.databricks_account_id
  vpc_endpoint_name = "${var.workspace_name}-ws-pl"

  gcp_vpc_endpoint_info {
    project_id        = coalesce(try(var.private_service_connect.workspace_endpoint_project_id, null), var.gcp_project_id)
    psc_endpoint_name = var.private_service_connect.workspace_endpoint_name
    endpoint_region   = coalesce(try(var.private_service_connect.workspace_endpoint_region, null), var.gcp_region)
  }
}

# ========================================
# Databricks Network Configuration
# ========================================

resource "databricks_mws_networks" "this" {
  provider = databricks.account

  account_id   = var.databricks_account_id
  network_name = "${var.workspace_name}-network"

  gcp_network_info {
    # For Shared VPC: use vpc_host_project_id if specified, otherwise use workspace project
    network_project_id = coalesce(var.vpc_host_project_id, var.gcp_project_id)
    vpc_id             = var.vpc_name
    subnet_id          = var.subnet_name
    subnet_region      = var.subnet_region
  }

  # Associate VPC endpoints for Private Service Connect
  dynamic "vpc_endpoints" {
    for_each = var.enable_private_service_connect && var.deployment_mode == "workspace_only" && var.private_service_connect != null ? [1] : []
    content {
      dataplane_relay = [databricks_mws_vpc_endpoint.relay[0].vpc_endpoint_id]
      rest_api        = try(var.private_service_connect.workspace_endpoint_name, null) != null ? [databricks_mws_vpc_endpoint.workspace[0].vpc_endpoint_id] : []
    }
  }

  depends_on = [
    databricks_mws_vpc_endpoint.relay,
    databricks_mws_vpc_endpoint.workspace
  ]
}

# ========================================
# Private Access Settings
# ========================================

# Private Access Settings with PSC (when PSC is enabled -> https://docs.databricks.com/gcp/en/security/network/front-end/front-end-private-connect)
resource "databricks_mws_private_access_settings" "psc" {
  count = var.enable_private_service_connect && var.deployment_mode == "workspace_only" && var.private_service_connect != null ? 1 : 0

  provider = databricks.account

  account_id                   = var.databricks_account_id
  private_access_settings_name = "${var.workspace_name}-psc-private-access"
  region                       = var.gcp_region
  
  # Public access configuration
  public_access_enabled = try(var.private_service_connect.public_access_enabled, false)
  
  # Private access level: ACCOUNT or ENDPOINT
  private_access_level = try(var.private_service_connect.private_access_level, "ACCOUNT")
  
  # Allowed VPC endpoint IDs (when private_access_level = ENDPOINT)
  # For GCP PSC, reference the relay and workspace VPC endpoints
  allowed_vpc_endpoint_ids = try(var.private_service_connect.private_access_level, "ACCOUNT") == "ENDPOINT" ? concat(
    [databricks_mws_vpc_endpoint.relay[0].vpc_endpoint_id],
    try(var.private_service_connect.workspace_endpoint_name, null) != null ? [databricks_mws_vpc_endpoint.workspace[0].vpc_endpoint_id] : []
  ) : []

  depends_on = [
    databricks_mws_vpc_endpoint.relay,
    databricks_mws_vpc_endpoint.workspace
  ]
}

# Private Access Settings for Secure Cluster Connectivity only (when PSC is NOT enabled)
resource "databricks_mws_private_access_settings" "standard" {
  count = !var.enable_private_service_connect && var.enable_secure_cluster_connectivity ? 1 : 0

  provider = databricks.account

  account_id                   = var.databricks_account_id
  private_access_settings_name = "${var.workspace_name}-private-access"
  region                       = var.gcp_region
  public_access_enabled        = true
}

# Databricks Workspace
resource "databricks_mws_workspaces" "this" {
  provider = databricks.account

  account_id     = var.databricks_account_id
  workspace_name = var.workspace_name
  location       = var.gcp_region

  cloud_resource_container {
    gcp {
      project_id = var.gcp_project_id
    }
  }
  # Use PSC private access settings if PSC is enabled, otherwise use standard settings
  private_access_settings_id = (
    var.enable_private_service_connect && var.deployment_mode == "workspace_only" && var.private_service_connect != null
      ? databricks_mws_private_access_settings.psc[0].private_access_settings_id 
      : (var.enable_secure_cluster_connectivity ? databricks_mws_private_access_settings.standard[0].private_access_settings_id : null)
  )

  network_id = databricks_mws_networks.this.network_id

  token {}

  depends_on = [
    databricks_mws_networks.this,
    databricks_mws_private_access_settings.psc,
    databricks_mws_private_access_settings.standard
  ]
}

