locals {
  environment = "dev"
  vpc_cidr    = "172.32.0.0/16"

  admin_accounts = [
    "orens",
  ]
  admin_roles = [
    "admin-role"
  ]
 dev_roles = [
    "dev-role"
  ]
  # argocd vars:
  http = "argocd.pocoz.tikal.io"
  repo_name_1 = "xap-umbrella-chart"
  repo_url_1  = "git@github.com:Gigaspaces/xap-umbrella-chart.git"
  app_of_apps_repo_url   = "https://github.com/Gigaspaces/xap-umbrella-chart/tree/main/argocd.git"
  git_path    = "overlays"

}
