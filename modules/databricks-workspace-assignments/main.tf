# ========================================
# Workspace Permission Assignments
# Assigns users, groups, and service principals to workspaces
# ========================================

# Data sources to look up principal IDs from names
# Users - lookup by email
data "databricks_user" "admins_users" {
  for_each = { for idx, principal in var.workspace_admins : principal.principal_name => principal if principal.type == "user" }
  provider = databricks.account
  user_name = each.value.principal_name
}

data "databricks_user" "regular_users" {
  for_each = { for idx, principal in var.workspace_users : principal.principal_name => principal if principal.type == "user" }
  provider = databricks.account
  user_name = each.value.principal_name
}

# Groups - lookup by display name
data "databricks_group" "admins_groups" {
  for_each = { for idx, principal in var.workspace_admins : principal.principal_name => principal if principal.type == "group" }
  provider = databricks.account
  display_name = each.value.principal_name
}

data "databricks_group" "regular_groups" {
  for_each = { for idx, principal in var.workspace_users : principal.principal_name => principal if principal.type == "group" }
  provider = databricks.account
  display_name = each.value.principal_name
}

# Service Principals - lookup by application_id
data "databricks_service_principal" "admins_sps" {
  for_each = { for idx, principal in var.workspace_admins : principal.principal_name => principal if principal.type == "service_principal" }
  provider = databricks.account
  application_id = each.value.principal_name
}

data "databricks_service_principal" "regular_sps" {
  for_each = { for idx, principal in var.workspace_users : principal.principal_name => principal if principal.type == "service_principal" }
  provider = databricks.account
  application_id = each.value.principal_name
}

# Local map to combine all principal IDs
locals {
  admin_principals = merge(
    { for k, v in data.databricks_user.admins_users : k => { id = v.id, type = "user" } },
    { for k, v in data.databricks_group.admins_groups : k => { id = v.id, type = "group" } },
    { for k, v in data.databricks_service_principal.admins_sps : k => { id = v.id, type = "service_principal" } }
  )
  
  user_principals = merge(
    { for k, v in data.databricks_user.regular_users : k => { id = v.id, type = "user" } },
    { for k, v in data.databricks_group.regular_groups : k => { id = v.id, type = "group" } },
    { for k, v in data.databricks_service_principal.regular_sps : k => { id = v.id, type = "service_principal" } }
  )
}

# Admin Assignments
resource "databricks_mws_permission_assignment" "workspace_admins" {
  for_each = local.admin_principals

  provider = databricks.account

  workspace_id = var.workspace_id
  principal_id = each.value.id
  permissions  = ["ADMIN"]
}

# User Assignments
resource "databricks_mws_permission_assignment" "workspace_users" {
  for_each = local.user_principals

  provider = databricks.account

  workspace_id = var.workspace_id
  principal_id = each.value.id
  permissions  = ["USER"]
}

