variable "aws_region" {
  description = "AWS region for the lab."
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the dedicated lab VPC."
  type        = string
}

variable "public_subnet_cidr" {
  description = "IPv4 CIDR block for the lab's public subnet."
  type        = string
}

variable "ami_id" {
  description = "Ubuntu AMI ID available in the selected region."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "key_name" {
  description = "Name of an EC2 key pair that already exists in this region."
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "Your current public IPv4 address in /32 format."
  type        = string
}