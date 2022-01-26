

variable "cluster_id" {
  type = string
}
# variable "prod_infra_sshkey" {
#   type = string
# }
# variable "acm_cert" {
#   type = string
# }

variable "http" {
  type = string
}
variable "repo_name_1" {
  type = string
  default=""
}
variable "repo_url_1" {
  type = string
  default =""
}
variable "app_of_apps_repo_name" {
  type = string
  default =""
}

variable "repo_name_2" {
  type = string
  default = ""
}

variable "repo_url_2" {
  type = string
  default = ""
}

variable "app_of_apps_repo_url" {
  type = string
}

variable "git_path" {
  type = string
}
variable "argo_ssh_key" {
  type = string
}
variable "umbrella_ssh_key" {
  type = string
}
