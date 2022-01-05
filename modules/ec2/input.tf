variable "public_subnets_id" {
  description = "Public subnets"
}

# variable "user_data" {
  
# }
variable "vpc_cidr" {
  
}
variable "key_name" {
  

}
variable "region" {
  description = "AWS region where VPC will be created"
}
variable "vpc_id" {
  description = "AWS region where VPC will be created"
}
variable "name" {
  description = "Name of Cluster"
}
# variable "master_instance_type" {
#   description = "Master instance Type"
# }
# variable "worker_instance_type" {
#   description = "Worker instance Type"
# }
# variable "master_instance_count" {
#   description = "Number of ec2 instance"
# }
# variable "worker_instance_count" {
#   description = "Number of ec2 instance"
# }
# variable "master_disk_size" {
#   description = "Ebs volume size"
# }
# variable "worker_disk_size" {
#   description = "Ebs volume size"

# }


# variable "security_group_id" {
#   type    = list(string)  
#   description = "Public subnets"
# }

# variable "tf_state_bucket" {
#   description = "Terraform remote state S3 bucket name"
# }
# variable "tf_lock_table" {
#   description = "Terraform remote state DynamoDB table"
# }
variable "aws_ami"{
  description = "The ami id"
}
variable "office_cdir" {
  description = "The office cddir for security group"
}



# variable "aws_elb_api_port" {
#   description = "Port for AWS ELB"
# }

# variable "k8s_secure_api_port" {
#   description = "Secure Port of K8S API Server"
# }
