variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "vpc_name" {
  description = "Name for the VPC network"
  type        = string
}

variable "subnet_name" {
  description = "Name for the subnet"
  type        = string
}

variable "subnet_primary_ip_range" {
  description = "Primary IP CIDR range for the subnet"
  type        = string
}

variable "enable_private_google_access" {
  description = "Enable Private Google Access for the subnet"
  type        = bool
  default     = true
}

variable "enable_secure_cluster_connectivity" {
  description = "Enable Secure Cluster Connectivity (creates NAT gateway)"
  type        = bool
  default     = true
}

variable "enable_vpc_firewall_rules" {
  description = "Enable VPC firewall rules"
  type        = bool
  default     = true
}

variable "allowed_ip_ranges" {
  description = "List of IP CIDR ranges allowed to access Databricks"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "resource_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "databricks"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

