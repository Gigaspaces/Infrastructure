provider "kubernetes" {
  alias                  = "GigaCI-infra"
  host                   = data.aws_eks_cluster.cluster.endpoint
  load_config_file       = false
  version                = "~> 1.11"
}

provider "helm" {
  alias   = "GigaCI-infra"
  version = "1.3.2"
  provider "kubernetes" {
    alias = kubernetes.gigaspaces-infra
  }
}
resource "kubernetes_namespace" "argocd" {
  metadata {
    annotations = {
      created-by = "terraform"
      "app.kubernetes.io/managed-by" = "Helm"
    }

    labels = {
      purpose = "ArgoCD-IAC"
      
    }

    name = "argocd"
  }
}

data "template_file" "values-override" {
  template = "${file("${path.module}/files/values-override.tpl")}"
  vars = {
    externaldns_http       = "${var.http}"
    argocd_url             = "http://${var.http}"
    argo_ssh_key           = "${var.argo_ssh_key}"
    umbrella_ssh_key       = "${var.umbrella_ssh_key}"
    path                   = "${var.git_path}"
    repo_name_1            = "${var.repo_name_1}"
    repo_url_1             = "${var.repo_url_1}"
    app_of_apps_repo_name  = "${var.app_of_apps_repo_name}"
    app_of_apps_repo_url   = "${var.app_of_apps_repo_url}"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "3.2.1"
  namespace  = kubernetes_namespace.argocd.metadata.0.name
  values = [
     data.template_file.values-override.rendered
  ]
#argo secret pull from secret manager   
}
data "aws_secretsmanager_secret" "argocd_aws_secret" {
  name = "argocd_aws_secret"
}

data "aws_secretsmanager_secret_version" "argocd_aws_secret" {
  secret_id = data.aws_secretsmanager_secret.argocd_aws_secret.id
}

locals {
  argocd_ssh_key_base64 = base64decode(data.aws_secretsmanager_secret_version.argocd_aws_secret.secret_string)
}
#xap-umbrella-git  secret pull from secret manager   
data "aws_secretsmanager_secret" "xapumbrella_idrsa" {
  name = "xapumbrella_idrsa"
}

data "aws_secretsmanager_secret_version" "xapumbrella_idrsa" {
  secret_id = data.aws_secretsmanager_secret.xapumbrella_idrsa.id
}

locals {
  umbrella_ssh_key_base64 = base64decode(data.aws_secretsmanager_secret_version.xapumbrella_idrsa.secret_string)
}

resource "kubernetes_secret" "xapumbrella_idrsa" {
  metadata {
    name      = "umbrella-github-secret"
    namespace = kubernetes_namespace.argocd.metadata.0.name

  }
  data = {
    sshPrivateKey = local.umbrella_ssh_key_base64
  }
}

resource "kubernetes_secret" "argocd_aws_secret" {
  metadata {
    name      = "argocd-github-secret"
    namespace = kubernetes_namespace.argocd.metadata.0.name

  }
  data = {
    sshPrivateKey = local.argocd_ssh_key_base64
  }
}

data "template_file" "app" {
  template = "${file("${path.module}/files/app.tpl")}"
  vars = {
    repo_url_1 = "${var.repo_url_1}"
    app_of_apps_repo_url = "${var.app_of_apps_repo_url}"
    path = "${var.git_path}"
    repo_name_1 = "${var.repo_name_1}"
    app_of_apps_repo_name = "${var.app_of_apps_repo_name}"
    
    

  }
}

resource "local_file" "my_app" {
    content     = data.template_file.app.rendered
    filename = "${path.module}/my_app.yaml"
}
resource "null_resource" "apply-app" {

    provisioner "local-exec" {
        command = "kubectl apply -f ${path.module}/my_app.yaml"
  }
}
