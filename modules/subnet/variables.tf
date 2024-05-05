############
# VPC Binding
############

variable "gcp_project_id" {
  type        = string
  description = "ID of the project which owns the VPC"
}

variable "vpc_network_id" {
  type        = string
  description = "ID of the VPC this subnet will be attached to"
}

############
# Subnet
############

variable "name" {
  type        = string
  description = "Name of the subnet being created"
}

variable "description" {
  type        = string
  description = "Human readable and understandable description of the scope of the subnet"
  default     = ""
  nullable    = false
}

variable "ip_cidr_range" {
  type        = string
  description = "CIDR formated range of IPs for the subnet"
}

variable "region" {
  type        = string
  description = "GCP region the the subnet will be associated with"
}

variable "private_ip_google_access" {
  type        = bool
  description = "Enable the private IP access to GCP services"
  default     = true
  nullable    = false
}

variable "secondary_ranges" {
  type = list(object({
    name = string
    ip_cidr_range = string
  }))
  description = "List of secondary ranges for this subnetwork. Must contain `name' and `cidr` of the secondary range."
  default     = []
  nullable    = false
}

############
# Flow logs Config
############

variable "flow_logs" {
  type = list(object({
    aggregation_interval = string
    flow_sampling        = number
    metadata             = string
    metadata_fields      = list(string)
  }))
  description = <<EOT
    Flow log configuration for created subnet. This is a list of flow log configurations, each item in the list must contain:
    - aggregation_interval
    - flow_sampling
    - metadata
    Refer to the terraform subnet resource for more information
  EOT
  default = [{
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
    metadata_fields      = []
  }]
  nullable = false
}

############
# Feature Flag - Internal Loadbalancer Subnet
############

variable "internal_lb_subnet" {
  type        = bool
  description = "Indicates if the subnets is a internal load balancer dedicated subnet"
  default     = false
  nullable    = false
}

############
# Feature Flag - VPC Serverless Connector
############

variable "vpc_serverless_connector" {
  type        = bool
  description = "Set to true if you want to add a Serveless VPC connector for this subnet"
  default     = false
  nullable    = false
}

variable "vpc_serverless_connector_prefix" {
  type        = string
  description = "Prefix to add to the VPC Serverless Access connector"
  default     = "serverless-access"
  nullable    = false
}

# Set local variables for subnet config based on input
locals {
  purpose                  = var.internal_lb_subnet ? "INTERNAL_HTTPS_LOAD_BALANCER" : null
  role                     = var.internal_lb_subnet ? "ACTIVE" : null
  private_ip_google_access = var.internal_lb_subnet ? false : var.private_ip_google_access
  flow_logs                = var.internal_lb_subnet ? [] : var.flow_logs
}