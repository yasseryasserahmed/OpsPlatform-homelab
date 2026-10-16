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
  description = "Allow SSH from the configured client IP"
  vpc_id      = aws_vpc.lab.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "homeops-lab"
  }
}
