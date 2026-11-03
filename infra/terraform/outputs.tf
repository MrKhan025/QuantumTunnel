output "selected_cloud_provider" {
  description = "Active cloud provider selected for QuantumTunnel gateway"
  value       = var.cloud_provider
}

output "wireguard_udp_port" {
  description = "WireGuard UDP port exposed on the gateway"
  value       = var.wg_port
}
