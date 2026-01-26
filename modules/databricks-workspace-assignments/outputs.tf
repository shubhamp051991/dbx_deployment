output "admin_assignments" {
  description = "Map of admin permission assignments"
  value = {
    for key, assignment in databricks_mws_permission_assignment.workspace_admins : key => {
      workspace_id = assignment.workspace_id
      principal_id = assignment.principal_id
      permissions  = assignment.permissions
    }
  }
}

output "user_assignments" {
  description = "Map of user permission assignments"
  value = {
    for key, assignment in databricks_mws_permission_assignment.workspace_users : key => {
      workspace_id = assignment.workspace_id
      principal_id = assignment.principal_id
      permissions  = assignment.permissions
    }
  }
}

