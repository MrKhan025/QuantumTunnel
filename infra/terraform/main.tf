terraform {
  required_version = ">= 1.8.0"
}

module "aws_gateway" {
  count          = var.cloud_provider == "aws" ? 1 : 0
  source         = "./modules/aws-ec2"
  environment    = var.environment
  admin_cidr     = var.admin_cidr
  ssh_public_key = var.ssh_public_key
  wg_port        = var.wg_port
}

module "azure_gateway" {
  count          = var.cloud_provider == "azure" ? 1 : 0
  source         = "./modules/azure-vm"
  environment    = var.environment
  admin_cidr     = var.admin_cidr
  ssh_public_key = var.ssh_public_key
  wg_port        = var.wg_port
}

module "digitalocean_gateway" {
  count          = var.cloud_provider == "digitalocean" ? 1 : 0
  source         = "./modules/digitalocean"
  environment    = var.environment
  admin_cidr     = var.admin_cidr
  ssh_public_key = var.ssh_public_key
  wg_port        = var.wg_port
}

module "oci_free_gateway" {
  count          = var.cloud_provider == "oci" ? 1 : 0
  source         = "./modules/oracle-cloud-free"
  environment    = var.environment
  admin_cidr     = var.admin_cidr
  ssh_public_key = var.ssh_public_key
  wg_port        = var.wg_port
}
