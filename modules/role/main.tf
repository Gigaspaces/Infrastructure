provider "aws" {
  region = "eu-central-1"
}

data "aws_iam_policy_document" "eks-jenkins-policy" {
  statement {
    sid    = "AmazonEKSWorkerNodePolicy"
    effect = "Allow"
    actions = [
                "ec2:DescribeInstances",
                "ec2:DescribeRouteTables",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVolumes",
                "ec2:DescribeVolumesModifications",
                "ec2:DescribeVpcs",
                "eks:DescribeCluster"
            ]
    resources = ["*"]
  }
  statement {
    sid    = "AmazonEC2ContainerRegistryReadOnly"
    effect = "Allow"
    actions = [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetRepositoryPolicy",
                "ecr:DescribeRepositories",
                "ecr:ListImages",
                "ecr:DescribeImages",
                "ecr:BatchGetImage",
                "ecr:GetLifecyclePolicy",
                "ecr:GetLifecyclePolicyPreview",
                "ecr:ListTagsForResource",
                "ecr:DescribeImageScanFindings"
            ]
    resources = ["*"]
  }
  statement{
    sid    = "AmazonEKSCNIPolicy"
    effect = "Allow"
    actions = [
                "ec2:AssignPrivateIpAddresses",
                "ec2:AttachNetworkInterface",
                "ec2:CreateNetworkInterface",
                "ec2:DeleteNetworkInterface",
                "ec2:DescribeInstances",
                "ec2:DescribeTags",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeInstanceTypes",
                "ec2:DetachNetworkInterface",
                "ec2:ModifyNetworkInterfaceAttribute",
                "ec2:UnassignPrivateIpAddresses"
            ]
    resources = ["*"]
  }
  

  
  statement {
    sid    = "AmazonEKSServicePolicy"
    effect = "Allow"
    actions =  [
                "ec2:CreateNetworkInterface",
                "ec2:CreateNetworkInterfacePermission",
                "ec2:DeleteNetworkInterface",
                "ec2:DescribeInstances",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DetachNetworkInterface",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcs",
                "ec2:ModifyNetworkInterfaceAttribute",
                "iam:ListAttachedRolePolicies",
                "eks:UpdateClusterVersion",
                "route53:AssociateVPCWithHostedZone",
                "logs:CreateLogGroup",
                "iam:CreateServiceLinkedRole"
            ]
      resources = ["*"]
      
      
  }
  
 
}
resource "aws_iam_policy" "policy" {
  name = "giga-jenkins-eks-role"
  policy = data.aws_iam_policy_document.eks-jenkins-policy.json
}




module "iam_assumable_role_with_oidc" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 3.0"

  create_role = true
  role_policy_arns = [aws_iam_policy.policy.arn]
  role_name = "giga-eks-role"

  provider_url = var.oidc
  tags = {
    Role = "role-with-oidc"
    Name = "eks-role"
  }
}

