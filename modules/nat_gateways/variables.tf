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

##############
# NAT Gatways
##############
variable "name" {
  type = string
}

variable "region" {
  type = string
}

variable "ip_allocation" {
  type = string
  validation {
    condition     = contains(["auto", "manual"], var.ip_allocation)
    error_message = "All NATs must have `ip_allocation` set to either `auto` or `manual`"
  }
  default = "auto"
  nullable = false
}

variable "ip_static_count" {
  type     = number
  default  = 1
  nullable = false
}

variable "enable_endpoint_independent_mapping" {
  type    = bool
  default = null
}

variable "router_name" {
  type = string
}

variable "subnetwork_ids" {
  type    = list(string)
  default = []
}
