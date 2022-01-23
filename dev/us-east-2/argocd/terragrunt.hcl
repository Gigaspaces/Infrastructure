include {
  path = find_in_parent_folders()
}


locals {
  account = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  proj    = read_terragrunt_config(find_in_parent_folders("proj.hcl"))

  secretPath = "prod/infra/sshkey"
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

dependency "eks" {
  config_path = "${get_parent_terragrunt_dir()}/${local.environment}/${local.aws_region}/eks-ohoi"
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules/argocd"
}

inputs = {
  cluster_name = local.cluster_name
  cluster_id   = dependency.eks.outputs.cluster_id
  # need to create key in aws secrets manager before execution
  prod_infra_sshkey = local.secretPath
  http                 = local.env.locals.http
  repo_name_1          = local.env.locals.repo_name_1
  repo_url_1           = local.env.locals.repo_url_1
  app_of_apps_repo_url = local.env.locals.app_of_apps_repo_url
  git_path             = local.env.locals.git_path
}
