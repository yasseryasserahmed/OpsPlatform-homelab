resource "aws_vpc" "lab" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "homeops-lab"
  }
}

resource "aws_subnet" "lab_public" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "homeops-lab-public"
  }
}

resource "aws_internet_gateway" "lab" {
  vpc_id = aws_vpc.lab.id

  tags = {
    Name = "homeops-lab"
  }
}

resource "aws_route_table" "lab_public" {
  vpc_id = aws_vpc.lab.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab.id
  }

  tags = {
    Name = "homeops-lab-public"
  }
}

resource "aws_route_table_association" "lab_public" {
  subnet_id      = aws_subnet.lab_public.id
  route_table_id = aws_route_table.lab_public.id
}

resource "aws_security_group" "lab" {
  name        = "homeops-lab"
  description = "Allow restricted administration and Kubernetes node traffic"
  vpc_id      = aws_vpc.lab.id

  tags = {
    Name = "homeops-lab"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.lab.id
  description       = "SSH from the configured client IP"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.allowed_ssh_cidr
}

resource "aws_vpc_security_group_ingress_rule" "node_traffic" {
  security_group_id            = aws_security_group.lab.id
  referenced_security_group_id = aws_security_group.lab.id
  description                  = "Kubernetes node and pod traffic between lab nodes"
  ip_protocol                  = "-1"
}

resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.lab.id
  description       = "Allow nodes to reach package repositories and external services"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
