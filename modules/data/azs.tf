data "aws_availability_zones" "all" {}

output "azs" {
  value = data.aws_availability_zones.all.names
}
