variable "cloud_provider" {
  description = "Target cloud provider: aws | azure | digitalocean | oci"
  type        = string
  default     = "aws"
  validation {
    condition     = contains(["aws", "azure", "digitalocean", "oci"], var.cloud_provider)
    error_message = "cloud_provider must be one of: aws, azure, digitalocean, oci."
  }
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "production"
}

variable "admin_cidr" {
  description = "Trusted admin IPv4 CIDR permitted to access SSH port 2222"
  type        = string
  default     = "203.0.113.10/32"
}

variable "ssh_public_key" {
  description = "Ed25519 SSH public key for the ubuntu user"
  type        = string
  sensitive   = true
}

variable "wg_port" {
  description = "WireGuard UDP listen port"
  type        = number
  default     = 51820
}
