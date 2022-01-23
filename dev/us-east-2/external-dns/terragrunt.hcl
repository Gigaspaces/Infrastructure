


dependency "eks"{
  config_path ="../eks-ohoi"
}
locals {
  account = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  proj    = read_terragrunt_config(find_in_parent_folders("proj.hcl"))

  # Extract the variables we need for easy access
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
  cluster_name   = "${local.proj.locals.project}-${local.env.locals.environment}"
  namespace      = "${local.proj.locals.project}-${local.env.locals.environment}"
  admin_accounts = local.env.locals.admin_accounts

}

terraform {
  source = "../../../modules/external-dns-role/"
}

inputs={
    zone_id = "Z3OMNX2Q8Y2YLG"
    oidc= dependency.eks.outputs.cluster_oidc_issuer_url
    role_name = "${local.cluster_name}-external-dns"
    }