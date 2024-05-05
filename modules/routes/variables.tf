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
# Routes
############

variable "name" {
  type        = string
  description = "Name of the route"
}

variable "description" {
  type        = string
  description = "Description of the route"
  default     = ""
}

variable "tags" {
  type        = list(string)
  description = "A list of instance tags to which this route applies."
  default     = null
}

variable "destination_range" {
  type        = string
  description = "IP CIDR range of destinations for this route"
}

variable "priority" {
  type        = number
  description = "The priority of this route. Priority is used to break ties in cases where there is more than one matching route of equal prefix length. In the case of two routes with equal prefix length, the one with the lowest-numbered priority value wins."
  default     = 1000
}

variable "next_hop" {
  type = object({
    type   = string
    target = string
  })
  description = "When the route is matches what it the type of the packet target and what is the target reference"
}