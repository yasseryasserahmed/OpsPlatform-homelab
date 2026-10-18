module "network" {
  source = "../../modules/network"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidr   = var.public_subnet_cidr
  allowed_ssh_cidr     = var.allowed_ssh_cidr
  allowed_ingress_cidr = var.allowed_ingress_cidr
}

module "ha_proxy" {
  source = "../../modules/ha-proxy"

  name                     = "homeops-ha-proxy"
  ami_id                   = var.ami_id
  instance_type            = var.ha_proxy_instance_type
  key_name                 = var.key_name
  subnet_id                = module.network.public_subnet_id
  vpc_id                   = module.network.vpc_id
  worker_security_group_id = module.network.security_group_id
  allowed_ssh_cidr         = var.allowed_ssh_cidr
  allowed_ingress_cidr     = var.allowed_ingress_cidr
}
