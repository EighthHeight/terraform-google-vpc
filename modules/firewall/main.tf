########### 
# For now this is just a list of firewall rules which are setup automatically by default in all VPCs we create
# Additional service specific firewall rules will need to be managed by the requesting service
# If we run into the case where developers are abusing the firewall access we will start restricting it via a library module of allowed firewall configs
###########
# TODO make this an actuall module which will allow others to use this how they would like
###########

# IAP
resource "google_compute_firewall" "allow_from_iap" {
  name        = "allow-from-iap"
  project     = var.gcp_project_id
  network     = var.vpc_network_id
  description = "Firewall rule: Allow access from GCP IAP service to tagged instances"
  direction   = "INGRESS"

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["allow-from-iap"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}