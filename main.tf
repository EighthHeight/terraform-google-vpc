############
# VPC
############
resource "google_compute_network" "vpc_network" {
  project = var.gcp_project_id

  name                            = var.network_name
  description                     = var.network_description
  auto_create_subnetworks         = var.auto_create_subnetworks
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = var.delete_default_internet_gateway_routes
  mtu                             = var.mtu
}

resource "google_compute_shared_vpc_host_project" "shared_vpc_host" {
  count      = var.network_usage_scope == "host" ? 1 : 0
  project    = var.gcp_project_id
  depends_on = [google_compute_network.vpc_network]
}

############
# Subnet(s)
############

module "subnet" {
  source   = "./modules/subnet"
  for_each = { for subnet in var.subnets : subnet.ref_id => subnet }
  # VPC
  gcp_project_id = var.gcp_project_id
  vpc_network_id = google_compute_network.vpc_network.name
  # Subnet
  name             = each.value.name
  description      = each.value.description
  ip_cidr_range    = each.value.ip_cidr_range
  region           = each.value.region
  secondary_ranges = each.value.secondary_ranges
  flow_logs        = each.value.flow_logs
  # Feature Flags
  private_ip_google_access        = each.value.private_ip_google_access
  internal_lb_subnet              = each.value.internal_lb_subnet
  vpc_serverless_connector        = each.value.vpc_serverless_connector
  vpc_serverless_connector_prefix = each.value.vpc_serverless_connector_prefix
}

############
# Private Service Peering
############

module "private_service_peering" {
  source   = "./modules/private-service-peering"
  for_each = { for peering in var.private_service_peerings : peering.name => peering }
  # VPC
  gcp_project_id = var.gcp_project_id
  vpc_network_id = google_compute_network.vpc_network.name
  # Peering
  name             = each.value.name
  description      = each.value.description
  start_address    = each.value.start_address
  prefix_length    = each.value.prefix_length
  peering_services = each.value.peering_services
}

######
# Routes
######

locals {
  routes_enforced = [{
    name              = "internet-egress"
    description       = "Egress Route to internet for compute instances with `access-to-internet` network tag"
    destination_range = "0.0.0.0/0"
    tags              = ["allow-to-internet"]
    priority          = "5000"
    next_hop = {
      type   = "gateway"
      target = "default-internet-gateway"
    }
  }]
  routes = concat(var.routes, local.routes_enforced)
}

module "network_routes" {
  source   = "./modules/routes"
  for_each = { for route in local.routes : route.name => route }
  # VPC
  gcp_project_id = var.gcp_project_id
  vpc_network_id = google_compute_network.vpc_network.name
  # Routes
  name              = each.value.name
  description       = each.value.description
  tags              = each.value.tags
  destination_range = each.value.destination_range
  priority          = each.value.priority
  next_hop          = each.value.next_hop
}

######
# Cloud Routers / NATs
######
locals {
  router_regions = distinct([for ng in var.nat_gateways : ng.region])
}

# Regional Router(s)
resource "google_compute_router" "router" {
  for_each = toset(local.router_regions)
  # VPC
  project = var.gcp_project_id
  network = google_compute_network.vpc_network.name
  # Router
  name   = "${google_compute_network.vpc_network.name}-${each.value}"
  region = each.value
}

module "nat_gateways" {
  source   = "./modules/nat_gateways"
  for_each = { for ng in var.nat_gateways : ng.name => ng }
  # VPC
  gcp_project_id = var.gcp_project_id
  vpc_network_id = google_compute_network.vpc_network.name
  # NATs
  name = each.value.name
  region = each.value.region
  ip_allocation = each.value.ip_allocation
  ip_static_count = each.value.ip_static_count
  enable_endpoint_independent_mapping = each.value.enable_endpoint_independent_mapping
  router_name = google_compute_router.router[each.value.region].name
  subnetwork_ids = [for subnet in each.value.subnet_ref_ids: module.subnet[subnet].id]
}

######
# Firewall Rules
######

module "firewall" {
  source         = "./modules/firewall"
  # VPC
  gcp_project_id = var.gcp_project_id
  vpc_network_id = google_compute_network.vpc_network.name
}