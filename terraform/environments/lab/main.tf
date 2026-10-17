module "network" {
  source = "../../modules/network"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidr   = var.public_subnet_cidr
  allowed_ssh_cidr     = var.allowed_ssh_cidr
  allowed_ingress_cidr = var.allowed_ingress_cidr
}
