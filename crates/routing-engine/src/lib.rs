//! Routing Engine: Multi-Hop, Kill Switch, Split Tunneling & DAITA Obfuscation.
use serde::{Deserialize, Serialize};
use std::net::IpAddr;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct KillSwitchPolicy {
    pub allow_lan_rfc1918: bool,
    pub allowed_entry_ips: Vec<IpAddr>,
    pub vpn_interface: String,
    pub fwmark: u32,
}

pub fn compute_padded_bucket_size(payload_len: usize) -> usize {
    const BUCKETS: [usize; 6] = [128, 256, 512, 1024, 1280, 1420];
    for &b in &BUCKETS {
        if payload_len <= b {
            return b;
        }
    }
    1420
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_daita_bucket_padding() {
        assert_eq!(compute_padded_bucket_size(64), 128);
        assert_eq!(compute_padded_bucket_size(300), 512);
        assert_eq!(compute_padded_bucket_size(1400), 1420);
    }
}
