# output "master_instance_ip_addr" {
#   value =zipmap(module.ec2_instance_master.public_ip ,module.ec2_instance_master.private_ip) 
# }
# output "worker_instance_ip_addr" {
#   value = zipmap(module.ec2_instance_worker.public_ip ,module.ec2_instance_worker.private_ip)
# }

# output "aws_elb_api_id" {
#   value = aws_elb.aws-elb-api.id
# }

# output "aws_elb_api_fqdn" {
#   value = aws_elb.aws-elb-api.dns_name
# }