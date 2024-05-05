resource "google_compute_subnetwork" "subnetwork" {
  project                  = var.gcp_project_id
  name                     = var.name
  ip_cidr_range            = var.ip_cidr_range
  region                   = var.region
  private_ip_google_access = local.private_ip_google_access
  network                  = var.vpc_network_id
  description              = var.description

  purpose = local.purpose
  role    = local.role

  dynamic "log_config" {
    for_each = local.flow_logs
    content {
      aggregation_interval = log_config.value.aggregation_interval
      flow_sampling        = log_config.value.flow_sampling
      metadata             = log_config.value.metadata
      metadata_fields      = log_config.value.metadata_fields
    }
  }

  dynamic "secondary_ip_range" {
    for_each = var.secondary_ranges
    content {
      range_name    = secondary_ip_range.value.name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
}

resource "google_vpc_access_connector" "connector" {
  count    = var.vpc_serverless_connector ? 1 : 0
  provider = google-beta

  project = var.gcp_project_id
  name    = "${var.vpc_serverless_connector_prefix}--${var.name}"
  subnet {
    name = google_compute_subnetwork.subnetwork.name
  }

  # TODO: This is a temporary patch to get around a change Google made in their API, can be addressed when fixed.
  # https://github.com/hashicorp/terraform-provider-google/issues/11304
  #   lifecycle {
  #     ignore_changes = [
  #       network,
  #     ]
  #   }
}