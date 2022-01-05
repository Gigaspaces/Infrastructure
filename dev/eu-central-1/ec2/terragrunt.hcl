
include {
  path = find_in_parent_folders()
}

locals {
  # user_data = <<EOF
  #         #! /bin/bash
  #         sudo mkdir /home/jenkins
  #         sudo mkdir /home/jenkins/.m2
  #         sudo mkdir /xap-jenkins/
  #         sudo mkdir /xap-jenkins/workspaces
  #         ./jenkins/run.sh
  # EOF
region =  read_terragrunt_config(find_in_parent_folders("region.hcl"))
}


dependency "vpc" {
  config_path = "../vpc"
}
inputs = {

  region    = "eu-central-1"
  name      =  "groot_new"
  vpc_id    = dependency.vpc.outputs.vpc_id
  public_subnets_id = dependency.vpc.outputs.public_subnets[0]
  aws_ami   = "ami-07bdea37e5452a3b8"
  office_cdir = "172.35.0.0/16"
  
  key_name = "instancersa"
  # user_data = base64encode(local.user_data)
  vpc_cidr= dependency.vpc.outputs.vpc_cidr
  # master_disk_size= lookup(root_block_device.value, "volume_size", null)
  tags = {
    Name = "groot_Sultan"
  }
}   

terraform {
	source = "../../../modules/ec2"
}