variable "eks_vpc_id" {
  type        = string
  default     = ""
  description = "The VPC for the eks cluster"
}
variable "eks_cluster_name" {
  type        = string
  default     = ""
  description = "Name of the cluster"
}

variable "eks_subnets" {
  type        = any
  default     = ""
  description = "subnets the cluster will manage"
}
variable "eks_map_users" {
  description = "IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
}

variable "eks_cluster_version" {
  type        = string
  default     = ""
  description = "k8s version"
}
variable "eks_cluster_tags" {
  type        = any
  default     = ""
  description = "Cluster Tags"
}

variable "eks_worker_groups_launch_template" {
  description = "A list of maps defining worker group configurations to be defined using AWS Launch Templates. See workers_group_defaults for valid keys."
  type        = any
  default     = []
}
variable "eks_worker_sg" {
  type        = string
  description = "(optional) describe your variable"
  default     = ""
}

variable "eks_node_groups" {
  description = "Map of map of node groups to create. See `node_groups` module's documentation for more details"
  type        = any
  default     = {}
}
variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}
variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. When it's set to `false` ensure to have a proper private access with `cluster_endpoint_private_access = true`."
  type        = bool
  default     = true
}
