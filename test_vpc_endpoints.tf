# Test to verify vpc_endpoints logic
output "test_workspace3_psc_enabled" {
  value = lookup(var.workspaces, "workspace3", null) != null ? var.workspaces["workspace3"].enable_private_service_connect : false
}

output "test_workspace3_psc_config" {
  value = lookup(var.workspaces, "workspace3", null) != null ? var.workspaces["workspace3"].private_service_connect : null
}
