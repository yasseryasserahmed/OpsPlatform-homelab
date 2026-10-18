resource "aws_security_group" "proxy" {
  name        = "${var.name}-sg"
  description = "Public HAProxy access and restricted worker backend access"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-sg"
    Role = "load-balancer"
  }
}
#---- ingress rules for the proxy security group ----
# we can use for_each to all rules in a map, but for now we will keep it simple and just create the rules one by one
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.proxy.id
  description       = "SSH from the configured administrator IP"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.allowed_ssh_cidr
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.proxy.id
  description       = "HTTP from the configured client IP"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = var.allowed_ingress_cidr
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.proxy.id
  description       = "HTTPS from the configured client IP"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = var.allowed_ingress_cidr
}

resource "aws_vpc_security_group_egress_rule" "outbound" {
  security_group_id = aws_security_group.proxy.id
  description       = "Allow package installation and worker connections"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# Workers accept the NodePorts only from the HAProxy security group.
resource "aws_vpc_security_group_ingress_rule" "worker_http_from_proxy" {
  security_group_id            = var.worker_security_group_id
  referenced_security_group_id = aws_security_group.proxy.id
  description                  = "HTTP NodePort traffic from HAProxy"
  ip_protocol                  = "tcp"
  from_port                    = 30080
  to_port                      = 30080
}


resource "aws_vpc_security_group_ingress_rule" "worker_https_from_proxy" {
  security_group_id            = var.worker_security_group_id
  referenced_security_group_id = aws_security_group.proxy.id
  description                  = "HTTPS NodePort traffic from HAProxy"
  ip_protocol                  = "tcp"
  from_port                    = 30443
  to_port                      = 30443
}

resource "aws_instance" "proxy" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.proxy.id]

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = var.name
    Role = "load-balancer"
  }
}
