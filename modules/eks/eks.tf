data "aws_eks_cluster" "cluster" {
  name = module.eks-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks-cluster.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  
  # version                = "~> 1.11"
}


module "eks-cluster" {
  source                        = "terraform-aws-modules/eks/aws"
  version                       = "17.1.0"
  enable_irsa                   = true
  write_kubeconfig              = false
  cluster_name                  = var.eks_cluster_name
  cluster_version               = var.eks_cluster_version
  subnets                       = var.eks_subnets
  vpc_id                        = var.eks_vpc_id
  tags                          = var.eks_cluster_tags
  map_users                     = var.eks_map_users

  #  worker_groups_launch_template = var.eks_worker_groups_launch_template
  # cluster_encryption_config     = var.eks_cluster_encryption_config
  node_groups                   = var.eks_node_groups
}