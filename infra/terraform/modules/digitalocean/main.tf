# DigitalOcean Ubuntu 24.04 LTS Droplet + Cloud Firewall
variable "environment" { type = string }
variable "admin_cidr" { type = string }
variable "ssh_public_key" { type = string }
variable "wg_port" { type = number }

output "module_ready" {
  value = "digitalocean-ubuntu-24.04-ready"
}
