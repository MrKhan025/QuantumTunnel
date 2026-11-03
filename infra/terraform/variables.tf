variable "cloud_provider" {
  description = "aws | azure | digitalocean | oci"
  type        = string
  default     = "aws"
}
variable "environment" {
  type    = string
  default = "production"
}
variable "admin_cidr" {
  type    = string
  default = "203.0.113.10/32"
}
variable "ssh_public_key" {
  type      = string
  sensitive = true
}
variable "wg_port" {
  type    = number
  default = 51820
}
