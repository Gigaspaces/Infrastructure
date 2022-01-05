################################################################################

data "template_file" "user_data" {
  template = file("${path.module}/run.sh")

  vars = {
    HOMEDIR                = "/home/jenkins"
    WORKSPACES             = "/home/jenkins/workspaces"
    MODE                   = "-d"
    M2                     = "/home/jenkins/m2"
    M2S                    = "/home/jenkins/m2s"
    M2S_DEPENDENCY_CHECK   = "/home/jenkins/m2_dependency_check"
    NEWMAN_SERVER_IP       = "$(hostname -I | awk '{ print $1 }')"
  }
}



provider "aws" {
  region  = var.region
}
# resource "aws_key_pair" "deployer" {
#   key_name   = "groot"
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC/chIn4jjsReH6jVHB++SN7LxfMJUhJguizv8DOIzQA2DWVY3yBlItBbkG5zaebE6QilO7bkTNygVKUXpSK47+60P0VJQpknoGzNUAjM3cWByhCiMmWgG9/AP50Ep+gNu3ia5FzKMNrzkiW1LUaECWVsbBya71r6GuKn7KRaDT1ocZPcrGUpCVf4TR5bTSbICtRjFHu5MLmGDmsIa/BVOMAWjsBP52NEP4jY+Utfk0rKbpSGA2gAJcFH5rPync5y3oDZF7F57F3fzUruat1sEfyzDWTwF5YXS2VWdZ9etART9YVOeR326HG3eOuG7noynOeRuT1XmAHeCAUxO0Usegjw8ytcmmyVAtSL/XgW0WQ2oI+YCAESec0u8zDauVHpFpTx5xnfi9YmuNbu354UTK9aZT7+5UUXg3GByM9IloHnOKopQcY4TAQgPOygUkJHxEzYJBxupEbXkbJU8/fO3zSDYhY2JFiMPw0dsxj3lvYn5F0+W17BQpWN66Csghmdk= orensultan@Sultan-mac"
# }
module "ec2_instance" {
  source  ="./terraform-aws-ec2-instance"
  

  name = "groot_new"
  ami                    = var.aws_ami
  instance_type          = "t2.xlarge"
  associate_public_ip_address = true
  user_data              =  base64encode(data.template_file.user_data.rendered)
  key_name               = "instancersa" 
  subnet_id              = var.public_subnets_id
  vpc_security_group_ids   =  [module.security_group.this_security_group_id]

  # root_block_device = [
  #   {
  #     volume_type = "gp2"
  #     volume_size = var.master_disk_size
  #   },
  # ]
  
  
  tags = {
    Terraform   = "true"
    Environment = "dev-var.name"
  }
}

 
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "automation-dev"
  description = "Security group for example usage with EC2 instance"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp","all-icmp"]
  ingress_with_self   = [ { "rule" = "all-all" } ]
  ingress_with_cidr_blocks = [
                         {
                           from_port   = 6443
                           to_port     = 6443
                           protocol    = "tcp"
                           description = "cluster api"
                           cidr_blocks = "172.31.0.0/16"
                          },
                          {
                           from_port   = 6443
                           to_port     = 6443
                           protocol    = "tcp"
                           description = "cluster api from offiice"
                           cidr_blocks = var.office_cdir
                          },
                          {
                            from_port   = 8080
                            to_port     = 8080
                            protocol    = "tcp"
                            description = "jenkins"
                            cidr_blocks = var.office_cdir
                          },
                          {
                            from_port   = 22
                            to_port     = 22
                            protocol    = "tcp"
                            description = "ssh connection"
                            cidr_blocks = var.office_cdir
                          }
                        ]
  egress_rules        = ["all-all"]
}

# resource "aws_security_group" "aws-elb" {
#   name   = "kubernetes-${var.name}-securitygroup-elb"
#   vpc_id = var.vpc_id

#   tags = {
#     Terraform   = "true"
#     Environment = "dev-var.name"
#     Name = "kubernetes-${var.name}-securitygroup-elb"
#   }
 
# }

# resource "aws_security_group_rule" "aws-allow-api-access" {
#   type              = "ingress"
#   from_port         = var.aws_elb_api_port
#   to_port           = var.k8s_secure_api_port
#   protocol          = "TCP"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.aws-elb.id
# }

# resource "aws_security_group_rule" "aws-allow-api-egress" {
#   type              = "egress"
#   from_port         = 0
#   to_port           = 65535
#   protocol          = "TCP"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.aws-elb.id
# }

# # Create a new AWS ELB for K8S API
# resource "aws_elb" "aws-elb-api" {
#   name            = "kubernetes-elb-${var.name}"
#   subnets         = [var.public_subnets]
#   security_groups = [aws_security_group.aws-elb.id]

#   listener {
#     instance_port     = var.k8s_secure_api_port
#     instance_protocol = "tcp"
#     lb_port           = var.aws_elb_api_port
#     lb_protocol       = "tcp"
#   }

#   health_check {
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#     timeout             = 3
#     target              = "HTTPS:${var.k8s_secure_api_port}/healthz"
#     interval            = 30
#   }

#   cross_zone_load_balancing   = true
#   idle_timeout                = 400
#   connection_draining         = true
#   connection_draining_timeout = 400

#   tags = {
#     Terraform   = "true"
#     Environment = "dev-var.name"
#     Name = "kubernetes-${var.name}-elb-api" 
#   }
  

# }