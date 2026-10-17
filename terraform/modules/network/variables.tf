variable "vpc_cidr" {
  description = "IPv4 CIDR block for the dedicated lab VPC."
  type        = string
}

variable "public_subnet_cidr" {
  description = "IPv4 CIDR block for the lab's public subnet."
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "Client public IPv4 address allowed to connect over SSH, in /32 format."
  type        = string

  validation {
    condition     = can(cidrhost(var.allowed_ssh_cidr, 0)) && can(cidrnetmask(var.allowed_ssh_cidr)) && can(regex("/32$", var.allowed_ssh_cidr))
    error_message = "Use your public IPv4 address with /32, for example 203.0.113.10/32."
  }
}

variable "allowed_ingress_cidr" {
  description = "Client public IPv4 address allowed to reach ingress NodePorts, in /32 format."
  type        = string

  validation {
    condition     = can(cidrhost(var.allowed_ingress_cidr, 0)) && can(cidrnetmask(var.allowed_ingress_cidr)) && can(regex("/32$", var.allowed_ingress_cidr))
    error_message = "Use your public IPv4 address with /32, for example 203.0.113.10/32."
  }
}
