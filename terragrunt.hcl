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
  project     = local.proj.locals.project  
  # project_prefix = local.proj.locals.project_prefix

  # combo
  cluster_name = "${local.proj.locals.project}-${local.env.locals.environment}"
  namespace    = "${local.proj.locals.project}-${local.env.locals.environment}"

  # local
  vendor_name = local.proj.locals.vendor_name  
}



# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.account.locals,
  local.region.locals,
  local.env.locals,
)


# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}" 
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true

  default_tags {
    tags = {
      Terraform = "true"
      Environment = "${local.environment}"
      BusinessUnit = "${local.environment}"
      # map-migrated = "budget/voucher"
    }
  }
  # preserve kubernetes tags 
  ignore_tags {
    key_prefixes = ["kubernetes.io/"]
  }
}


EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"

  config = {

    encrypt = true
    bucket  = "${local.vendor_name}-infra-tfstate-${local.account_id}"
    key     = "${local.project}/${path_relative_to_include()}/terraform.tfstate"
    # !IMPORTATNT - Region is hardcoded intatnional for keep all states in the same region
    # ${local.account_id} in the name will create a uniq bucket per environment.
    region         = "eu-central-1"
    dynamodb_table = "${local.project}-infra-tfstate-lock-${local.account_name}"
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
