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