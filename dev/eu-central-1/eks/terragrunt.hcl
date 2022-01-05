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
  

  # combo
  admin_accounts = local.env.locals.admin_accounts
  admin_roles    = local.env.locals.admin_roles
  dev_roles      = local.env.locals.dev_roles



}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  eks_vpc_id = dependency.vpc.outputs.vpc_id
  eks_subnets = dependency.vpc.outputs.private_subnets
  eks_cluster_name = local.cluster_name
  eks_cluster_version = "1.21"

  eks_cluster_tags = {
    Environment = local.environment
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }
  eks_map_users = [
    for user in "${local.admin_accounts}" :
    {
      userarn  = "${format("arn:aws:iam::${local.account_id}:user/%s", user)}"
      username = "${format("%s", user)}"
      groups   = ["system:masters"]
    }
  ]
  map_roles = [
    for role in concat(local.admin_roles,local.dev_roles) :
    {
      rolearn  = "${format("arn:aws:iam::${local.account_id}:role/%s", role)}"
      username = "${format("%s", role)}"
      groups   = ["system:masters"]
    }
  ]

  # eks_worker_groups =[
  #   {
  #     name                          = "worker-group-1"
  #     instance_type                 = "t3.large"
  #     asg_desired_capacity          = 2
     
  #   }
  # ]


  eks_worker_groups_launch_template = [
    {
      name          = "Giga-workers"
      instance_type = "t3.large"
      asg_max_size         = 3
      asg_min_size         = 2
      asg_desired_capacity = 2
    }
  ]



  eks_node_groups = {
    managed_worker_group_0 = {
      name             = "standard-primary-xlarge"
      # purpose - have 1 instance up at all times ...
      desired_capacity = 4
      max_capacity     = 8
      min_capacity     = 2

      instance_types = ["t2.xlarge"]
      /* capacity_type  = "SPOT" */
      k8s_labels = {
        Environment = local.cluster_name
        InstanceTypes = "regular"
      }
      additional_tags = {
        Environment = local.cluster_name
      }
      # worker_additional_security_group_ids = [dependency.worker_sg.outputs.this.id]
    },
    # managed_worker_group_1 = {
    #   name             = "standard-secondery"

    #   # purpose - have 1 instance up at all times ...
    #   desired_capacity = 1
    #   max_capacity     = 1
    #   min_capacity     = 1

    #   instance_types = ["t2.xlarge"]
    #   /* capacity_type  = "SPOT" */
    #   k8s_labels = {
    #     Environment = local.cluster_name
    #     InstanceTypes = "regular"
    #   }
    #   additional_tags = {
    #     Environment = local.cluster_name
    #   }
    #   # worker_additional_security_group_ids = [dependency.worker_sg.outputs.this.id]
    # },
  #   managed_spot_worker_group_1 = {
  #     name             = "spot-1"
  #     # purpose - have 1 instance up at all times ...
  #     desired_capacity = 0
  #     max_capacity     = 0
  #     min_capacity     = 0

  #     instance_types = ["m5.large", "m5a.large", "m5d.large", "m5ad.large"]
  #     capacity_type  = "SPOT"
  #     k8s_labels = {
  #       Environment = local.cluster_name
  #       InstanceTypes = "regular"
  #     }
  #     additional_tags = {
  #       Environment = local.cluster_name
  #     }
  #     # worker_additional_security_group_ids = [dependency.worker_sg.outputs.this.id]
  #   },
  }

}

terraform {
	source = "../../../modules/eks"
}
