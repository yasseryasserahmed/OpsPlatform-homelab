resource "aws_instance" "lab_node_control_plane" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = module.network.public_subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [module.network.security_group_id]

  tags = {
    Name = "lab-node-control-plane"
    Role = "control-plane"
  }
}
