provider "aws" {
  region = "us-east-2"
}

data "aws_iam_policy_document" "route53_access" {
  statement {
    actions   = [
                  "route53:ChangeResourceRecordSets"
                ]
    resources = ["arn:aws:route53:::hostedzone/${var.zone_id}"]
  }

  statement {
    actions =  [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ]
      resources = ["*"]
  }


  statement {
    

    sid    = "Route53UpdateZones"
    effect = "Allow"
    actions = ["route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/${var.zone_id}"]
  }
  statement {
   sid    = "Route53DeleteZones"
    effect = "Allow"
    actions = ["route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/${var.zone_id}"]
  }
  statement{
   sid    = "Route53createZones"
    effect = "Allow"
    actions =["route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/${var.zone_id}"]
  }
  statement {
    actions =  [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ]
      resources = ["*"]
  }
}
resource "aws_iam_policy" "policy" {
  name = "GigaCI_external_dns_policy"
  policy = data.aws_iam_policy_document.route53_access.json
}




module "iam_assumable_role_with_oidc" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 2.23"

  create_role = true
  role_policy_arns = [aws_iam_policy.policy.arn]
  role_name = var.role_name
  oidc_subjects_with_wildcards = ["system:serviceaccount:*:*"]
  provider_url = var.oidc
  tags = {
    Role = "role-with-oidc"
    Name = "GigaCI"
  }
}

