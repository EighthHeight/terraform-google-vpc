############
# GCP Project
############

variable "gcp_project_id" {
  type        = string
  description = "The ID of the project where this VPC will be created"
}

############
# SVPC
############

variable "svpc_host_project_id" {
  type = string
  description = "(Required) The ID of a host project to associate."
}

variable "svpc_host_subnets" {
  type = list(object({
    name = string
    region = string
    members = optional(list(string), [])
  }))
  description = "List of subnets and their region to attach to in host project"
  default = []
}
