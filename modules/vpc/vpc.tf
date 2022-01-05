

locals {
  region = "eu-central-1a"
  private_subnets = ["172.32.2.0/24", "172.32.3.0/24"]
  public_subnets  = ["172.32.56.0/24", "172.32.57.0/24"]
}
################################################################################
# VPC Module
################################################################################


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.name
  cidr = "172.32.0.0/16"
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  enable_ipv6 = true
  enable_nat_gateway = true
  single_nat_gateway = true
  public_subnet_tags = var.public_subnet_tags
  private_subnet_tags = var.private_subnet_tags
  tags = var.tags
  vpc_tags = var.vpc_tags
}
