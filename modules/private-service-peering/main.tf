resource "google_compute_global_address" "peering_addresses" {
  project       = var.gcp_project_id
  name          = var.name
  description   = var.description
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = var.start_address
  prefix_length = var.prefix_length
  network       = var.vpc_network_id
}

resource "google_service_networking_connection" "private_service_peering" {
  for_each                = toset(var.peering_services)
  network                 = var.vpc_network_id
  service                 = each.value
  reserved_peering_ranges = [google_compute_global_address.peering_addresses.name]
}
