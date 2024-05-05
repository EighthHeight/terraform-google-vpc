############
# VPC Binding
############

variable "gcp_project_id" {
  type        = string
  description = "The ID of the project where this VPC will be created"
}

variable "vpc_network_id" {
  type        = string
  description = "ID of the VPC this subnet will be attached to"
}

############
# Global Addresses to be used by peered service
############

variable "name" {
  type        = string
  description = <<EOT
    Name of the global address group used for peering
    The name must be 1-63 characters long and match the regular expression [a-z]([-a-z0-9]*[a-z0-9])? which means the first character must be a lowercase letter, and all following characters must be a dash, lowercase letter, or digit, except the last character, which cannot be a dash.
  EOT
}

variable "description" {
  type        = string
  description = "Description of the global address group used for peering"
}

variable "start_address" {
  type        = string
  description = "First IP address in range for global address group"
}

variable "prefix_length" {
  type     = number
  default  = 16
  nullable = false
}

############
# Private Service Peering
############

variable "peering_services" {
  type        = list(string)
  description = "Provider peering service that is managing peering connectivity for a service provider organization. For Google services that support this functionality it is 'servicenetworking.googleapis.com'."
  default     = ["services/servicenetworking.googleapis.com"]
  nullable    = false
}