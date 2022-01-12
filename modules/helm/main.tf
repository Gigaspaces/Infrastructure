provider "kubernetes" {
  alias                  = "giga-infra"
  host                   = data.aws_eks_cluster.cluster.endpoint
  load_config_file       = false
  version                = "~> 1.11"
}

provider "helm" {
  alias   = "giga-infra"
  version = "2.4.1"
  provider "kubernetes" {
    alias = kubernetes.giga-infra
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
  template = "${file("${path.module}/files/values.yaml.tpl")}"
  vars = {
    externaldns_http = "${var.http}"
    argocd_url = "http://${var.http}"
    repo_name_1 = "${var.repo_name_1}"
    repo_url_1 = "${var.repo_url_1}"

    repo_name_2 = "${var.repo_name_2}"
    repo_url_2 = "${var.repo_url_2}"

  }
}

resource "helm_release" "argocd" {
  name       = "argo-cd-pocoz"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "3.2.1"
  namespace  = kubernetes_namespace.argocd.metadata.0.name
  values = [
     data.template_file.values-override.rendered
  ]
}

