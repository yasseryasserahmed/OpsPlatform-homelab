variable "name" {
  description = "Name prefix for HAProxy resources."
  type        = string
}

variable "ami_id" {
  description = "Ubuntu AMI ID used by the Kubernetes nodes."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for HAProxy."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing EC2 key pair used to administer the proxy."
  type        = string
}

variable "subnet_id" {
  description = "Public subnet where the HAProxy instance will run."
  type        = string
}

variable "vpc_id" {
  description = "VPC that contains the proxy and Kubernetes nodes."
  type        = string
}

variable "worker_security_group_id" {
  description = "Security group attached to the Kubernetes nodes."
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "Administrator public IPv4 address allowed to SSH, in /32 format."
  type        = string
}

variable "allowed_ingress_cidr" {
  description = "Client public IPv4 address allowed to reach HAProxy, in /32 format."
  type        = string
}
