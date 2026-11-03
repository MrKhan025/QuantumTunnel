//! Leak-proof DNS Proxy forcing queries over the encrypted WireGuard/OpenVPN tunnel.
pub struct DnsProxyConfig {
    pub listen_addr: String,
    pub upstream_doh: String,
}
