# VPC Network
resource "google_compute_network" "databricks_vpc" {
  name                    = var.vpc_name
  project                 = var.project_id
  auto_create_subnetworks = false
  description             = "VPC network for Databricks workspace"
}

# Subnet for Databricks GCE Instances
resource "google_compute_subnetwork" "databricks_subnet" {
  name                     = var.subnet_name
  project                  = var.project_id
  region                   = var.region
  network                  = google_compute_network.databricks_vpc.id
  ip_cidr_range            = var.subnet_primary_ip_range
  private_ip_google_access = var.enable_private_google_access
}

# Cloud Router for NAT
resource "google_compute_router" "databricks_router" {
  name    = "${var.resource_prefix}-router"
  project = var.project_id
  region  = var.region
  network = google_compute_network.databricks_vpc.id

  bgp {
    asn = 64514
  }
}

# Cloud NAT for Secure Cluster Connectivity
resource "google_compute_router_nat" "databricks_nat" {
  count = var.enable_secure_cluster_connectivity ? 1 : 0

  name                               = "${var.resource_prefix}-nat"
  project                            = var.project_id
  router                             = google_compute_router.databricks_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.databricks_subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Firewall Rules
resource "google_compute_firewall" "databricks_internal" {
  count = var.enable_vpc_firewall_rules ? 1 : 0

  name    = "${var.resource_prefix}-allow-internal"
  project = var.project_id
  network = google_compute_network.databricks_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [
    var.subnet_primary_ip_range
  ]

  direction = "INGRESS"
  priority  = 1000
}

resource "google_compute_firewall" "databricks_ssh" {
  count = var.enable_vpc_firewall_rules ? 1 : 0

  name    = "${var.resource_prefix}-allow-ssh"
  project = var.project_id
  network = google_compute_network.databricks_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.allowed_ip_ranges
  target_tags   = ["databricks-cluster"]

  direction = "INGRESS"
  priority  = 1000
}

resource "google_compute_firewall" "databricks_https" {
  count = var.enable_vpc_firewall_rules ? 1 : 0

  name    = "${var.resource_prefix}-allow-https"
  project = var.project_id
  network = google_compute_network.databricks_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = var.allowed_ip_ranges
  target_tags   = ["databricks-cluster"]

  direction = "INGRESS"
  priority  = 1000
}

