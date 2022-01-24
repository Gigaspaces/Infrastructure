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
    alias = kubernetes.pocoz-infra
  }
}
resource "kubernetes_namespace" "argocd" {
  metadata {
    annotations = {
      created-by = "terraform"
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
    externaldns_http = "${var.http}"
    argocd_url = "http://${var.http}"

  }
}

resource "helm_release" "argo-cd-GigaCI" {
  name       = "argo-cd-GigaCI"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "3.2.1"
  namespace  = kubernetes_namespace.argocd.metadata.0.name
  values = [
     data.template_file.values-override.rendered
  ]
}

data "aws_secretsmanager_secret" "ssh_argocd_giga" {
  name = "ssh_argocd_giga"
}

data "aws_secretsmanager_secret_version" "ssh_argocd_giga" {
  secret_id = data.aws_secretsmanager_secret.ssh_argocd_giga.id
}

locals {
  argocd_ssh_key_base64 = base64decode(data.aws_secretsmanager_secret_version.ssh_argocd_giga.secret_string)
}

resource "kubernetes_secret" "ssh_argocd_giga" {
  metadata {
    name      = "argocd-secret"
    namespace = kubernetes_namespace.argocd.metadata.0.name
  }

  data = {
    sshPrivateKey = local.argocd_ssh_key_base64
  }
}

data "template_file" "app" {
  template = "${file("${path.module}/files/app.tpl")}"
  vars = {
    repo_url = "${var.app_of_apps_repo_url}"
    path = "${var.git_path}"
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
