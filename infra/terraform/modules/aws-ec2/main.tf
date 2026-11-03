# AWS EC2 Ubuntu 24.04 LTS Gateway (IMDSv2 + Encrypted GP3 EBS)
variable "environment" { type = string }
variable "admin_cidr" { type = string }
variable "ssh_public_key" { type = string }
variable "wg_port" { type = number }

output "module_ready" {
  value = "aws-ec2-ubuntu-24.04-ready"
}
