# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

locals {
  account = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  proj    = read_terragrunt_config(find_in_parent_folders("proj.hcl"))


# account
  account_name = local.account.locals.account_name
  account_id   = local.account.locals.aws_account_id

  # region
  aws_region = local.region.locals.aws_region

  # env
  environment = local.env.locals.environment
  vpc_cidr    = local.env.locals.vpc_cidr

  # project
  project = local.proj.locals.project

  # combo
  cluster_name = "${local.proj.locals.project}-${local.env.locals.environment}"
  namespace    = "${local.proj.locals.project}-${local.env.locals.environment}"

}
dependency "data" {
  config_path = "../data"
}


terraform {
	source = "../../../modules/vpc/"
}


inputs = {

  name = local.namespace
  cidr = local.vpc_cidr
  azs             = dependency.data.outputs.azs
  private_subnets = [cidrsubnet(local.vpc_cidr, 8, 1), cidrsubnet(local.vpc_cidr, 8, 2)]
  public_subnets  = [cidrsubnet(local.vpc_cidr, 8, 11), cidrsubnet(local.vpc_cidr, 8, 12)]
  

  enable_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }


  tags = {
    Terraform   = "true"
    Environment = local.namespace
  }


}
