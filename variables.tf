############
# GCP Project
############

variable "gcp_project_id" {
  type        = string
  description = "The ID of the project where this VPC will be created"
}

############
# VPC
############

variable "network_name" {
  type        = string
  description = "The name of the network being created"
}

variable "network_description" {
  type        = string
  description = "An optional description of vpc network. The resource must be recreated to modify this field."
  default     = ""
}

variable "auto_create_subnetworks" {
  type        = bool
  description = "When set to true, the network is created in 'auto subnet mode' and it will create a subnet for each region automatically across the 10.128.0.0/9 address range. When set to false, the network is created in 'custom subnet mode' so the user can explicitly connect subnetwork resources."
  default     = false
}

variable "routing_mode" {
  type        = string
  description = "The network routing mode (default 'GLOBAL')"
  default     = "GLOBAL"
}

variable "delete_default_internet_gateway_routes" {
  type        = bool
  description = "If set, ensure that all routes within the network specified whose names begin with 'default-route' and with a next hop of 'default-internet-gateway' are deleted"
  default     = true
  nullable    = false
}

variable "mtu" {
  type        = number
  description = "The network MTU. Must be a value between 1460 and 1500 inclusive. If set to 0 (meaning MTU is unset), the network will default to 1460 automatically."
  default     = 1460
  nullable    = false
}

variable "network_usage_scope" {
  type        = string
  description = <<EOT
    Usage scope refers to if this VPC will only be used within the project or hosted out to other projects
    Valid values are:
    - project
    - host
    EOT
  default     = "project"
  validation {
    condition     = contains(["project", "host"], var.network_usage_scope)
    error_message = "The given value for `network_usage_scope` is not `project` or `host`"
  }
}

############
# Subnets
############

variable "subnets" {
  type = list(object({
    ref_id        = string
    name          = string
    description   = optional(string)
    ip_cidr_range = string
    region        = string
    secondary_ranges = optional(list(object({
      name          = string
      ip_cidr_range = string
    })))
    flow_logs = optional(list(object({
      aggregation_interval = string
      flow_sampling        = number
      metadata             = string
      metadata_fields      = list(string)
    })))
    # Feature Flags
    private_ip_google_access        = optional(bool)
    internal_lb_subnet              = optional(bool)
    vpc_serverless_connector        = optional(bool)
    vpc_serverless_connector_prefix = optional(string)
  }))
  description = <<EOT
    List of all subnets which will be bound to the VPC.
    The only required fields are:
    - ref_id -- A unique reference ID for the subnet used for other resources like the NAT
    - name -- Name of the subenet
    - ip_cidr_range -- The IP range in CIDR notation for the subnet
    - region -- GCP region where the subnet resides
    For information on the full subnet options check out the `subnet` submodule
  EOT
  default     = []
}

############
# Private Service Peering
############

variable "private_service_peerings" {
  type = list(object({
    name             = string
    description      = optional(string)
    start_address    = string
    prefix_length    = optional(number)
    peering_services = optional(list(string), [])
  }))
  description = <<EOT
    List of all external servicess which will be peered to the VPC.
    The only required fields are:
    - name -- Name of the peering
    - start_address -- First IP in the peering range
    By default this will create a peering with a /16 subnet masked range to the Google shared services which allows priate connections to products like Cloud SQL
  EOT
  default = []
}

######
# Routes
######

variable "routes" {
  type = list(object({
    name              = string
    description       = optional(string)
    tags              = optional(list(string))
    destination_range = string
    priority          = optional(number)
    next_hop = object({
      type   = string
      target = string
    })
  }))
  default = []
}

######
# Cloud Routers / NATs
######

variable "nat_gateways" {
  type = list(object({
    name                                = string
    region                              = string
    ip_allocation                       = optional(string)
    ip_static_count                     = optional(number)
    enable_endpoint_independent_mapping = optional(bool)
    subnet_ref_ids                      = list(string)
  }))
}