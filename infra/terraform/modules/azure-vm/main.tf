# Azure Linux VM Ubuntu 24.04 LTS Gateway (Premium LRS + NSG)
variable "environment" { type = string }
variable "admin_cidr" { type = string }
variable "ssh_public_key" { type = string }
variable "wg_port" { type = number }

output "module_ready" {
  value = "azure-vm-ubuntu-24.04-ready"
}
