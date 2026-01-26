output "vpc_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.databricks_vpc.id
}

output "vpc_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.databricks_vpc.name
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = google_compute_subnetwork.databricks_subnet.id
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = google_compute_subnetwork.databricks_subnet.name
}

