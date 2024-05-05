resource "google_compute_route" "route" {
  project                = var.gcp_project_id
  network                = var.vpc_network_id
  name                   = var.name
  description            = var.description
  tags                   = var.tags
  dest_range             = var.destination_range
  priority               = var.priority
  next_hop_gateway       = var.next_hop.type == "gateway" ? var.next_hop.target : null
  next_hop_ip            = var.next_hop.type == "ip" ? var.next_hop.target : null
  next_hop_instance      = var.next_hop.type == "instance" ? var.next_hop.target : null
  next_hop_instance_zone = var.next_hop.type == "instance_zone" ? var.next_hop.target : null
  next_hop_vpn_tunnel    = var.next_hop.type == "vpn_tunnel" ? var.next_hop.target : null
  next_hop_ilb           = var.next_hop.type == "ilb" ? var.next_hop.target : null
}