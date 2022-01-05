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

}
