variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "resource_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "databricks"
}

variable "enable_bigquery_access" {
  description = "Enable BigQuery access for cluster service account"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

