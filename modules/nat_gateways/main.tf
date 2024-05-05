##############
# Reserve static IPs for `manual` nats
##############
resource "google_compute_address" "ip_address" {
  count   = var.ip_allocation == "manual" ? var.ip_static_count : 0
  project = var.gcp_project_id
  name    = "${var.name}-ip${count.index}"
  region  = var.region
  lifecycle {
    prevent_destroy = true
  }
}

##############
# NATs with associated subnetworks
##############
resource "google_compute_router_nat" "nat" {
  project = var.gcp_project_id

  name                                = var.name
  router                              = var.router_name
  region                              = var.region
  nat_ip_allocate_option              = var.ip_allocation == "auto" ? "AUTO_ONLY" : "MANUAL_ONLY"
  nat_ips                             = var.ip_allocation == "manual" ? [for ip in google_compute_address.ip_address : ip.id] : null
  source_subnetwork_ip_ranges_to_nat  = "LIST_OF_SUBNETWORKS"
  enable_endpoint_independent_mapping = var.enable_endpoint_independent_mapping

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }

  dynamic "subnetwork" {
    for_each = var.subnetwork_ids
    content {
      name                    = subnetwork.value
      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }
  }
}