resource "google_compute_shared_vpc_service_project" "svpc_service_project" {
  host_project    = var.svpc_host_project_id
  service_project = var.gcp_project_id
}

data "google_compute_subnetwork" "svpc_subnetwork" {
  for_each = { for subnet in var.svpc_host_subnets : subnet.name => subnet }
  project = var.svpc_host_project_id

  name   = each.value.name
  region = each.value.region
}

resource "google_compute_subnetwork_iam_binding" "subnetwork_iam_binding" {
  for_each = { for subnet in var.svpc_host_subnets : subnet.name => subnet }
  project    = var.svpc_host_project_id

  subnetwork = data.google_compute_subnetwork.svpc_subnetwork[each.key].name
  region     = data.google_compute_subnetwork.svpc_subnetwork[each.key].region
  role       = "roles/compute.networkUser"
  members    = each.value.members
}
