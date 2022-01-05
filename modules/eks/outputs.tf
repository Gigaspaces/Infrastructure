output "cluster_id" {
  value = module.eks-cluster.cluster_id
}
output "worker_iam_role_name" {
  value = module.eks-cluster.worker_iam_role_name
}
output "cluster_oidc_issuer_url" {
  value = module.eks-cluster.cluster_oidc_issuer_url
}
output "oidc_provider_arn" {
  value = module.eks-cluster.oidc_provider_arn
}
# output "kubeconfig-certificate-authority-data" {
#   value = module.eks-cluster.cluster_name.certificate_authority[0].data
# }