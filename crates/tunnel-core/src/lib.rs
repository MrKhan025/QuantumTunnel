//! Multi-Protocol Orchestrator supporting WireGuard (kernel netlink & boringtun/wireguard-go userspace for Termux)
//! and OpenVPN 2.6+ (TLS 1.3 fallback).
use serde::{Deserialize, Serialize};
use std::net::SocketAddr;
use std::time::Duration;
use thiserror::Error;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum VpnProtocol {
    WireGuardKernel,
    WireGuardUserspace,
    OpenVpnTls13,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TunnelConfig {
    pub interface_name: String,
    pub preferred_protocol: VpnProtocol,
    pub enable_fallback: bool,
    pub entry_endpoint: SocketAddr,
    pub exit_endpoint: Option<SocketAddr>,
    pub mtu: u16,
    pub persistent_keepalive_secs: u16,
    pub daita_obfuscation: bool,
}

#[derive(Error, Debug)]
pub enum TunnelError {
    #[error("WireGuard handshake timed out after {0:?}")]
    HandshakeTimeout(Duration),
    #[error("Interface error: {0}")]
    InterfaceError(String),
}
