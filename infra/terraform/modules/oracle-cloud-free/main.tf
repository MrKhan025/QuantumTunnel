# Oracle Cloud Always-Free Ampere A1 ARM64 Ubuntu 24.04 Gateway
variable "environment" { type = string }
variable "admin_cidr" { type = string }
variable "ssh_public_key" { type = string }
variable "wg_port" { type = number }

output "module_ready" {
  value = "oracle-cloud-free-ubuntu-24.04-ready"
}
