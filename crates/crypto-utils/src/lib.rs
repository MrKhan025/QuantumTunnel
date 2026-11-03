//! Hybrid Post-Quantum (X25519 + ML-KEM-1024) PSK derivation with automatic memory zeroization.
use hkdf::Hkdf;
use sha2::Sha256;
use x25519_dalek::{PublicKey as X25519Public, StaticSecret as X25519Secret};
use zeroize::{Zeroize, ZeroizeOnDrop};

#[derive(Zeroize, ZeroizeOnDrop)]
pub struct HybridPresharedKey(pub [u8; 32]);

/// Combines classical X25519 shared secret and Post-Quantum ML-KEM-1024 shared secret
/// using a domain-separated HKDF-SHA256 extract-and-expand step.
pub fn derive_hybrid_psk(
    classical_ecdh_ss: &[u8; 32],
    pq_mlkem_ss: &[u8],
    context_transcript_hash: &[u8],
) -> HybridPresharedKey {
    let mut ikm = Vec::with_capacity(classical_ecdh_ss.len() + pq_mlkem_ss.len());
    ikm.extend_from_slice(classical_ecdh_ss);
    ikm.extend_from_slice(pq_mlkem_ss);

    let hk = Hkdf::<Sha256>::new(Some(context_transcript_hash), &ikm);
    let mut okm = [0u8; 32];
    hk.expand(b"QuantumTunnel-v1-Hybrid-WG-PSK-MLKEM1024-X25519", &mut okm)
        .expect("32-byte HKDF expansion never fails");

    ikm.zeroize();
    HybridPresharedKey(okm)
}

pub struct HybridKeypair {
    pub x25519_secret: X25519Secret,
    pub x25519_public: X25519Public,
}

impl HybridKeypair {
    pub fn generate() -> Self {
        let x25519_secret = X25519Secret::random_from_rng(rand::thread_rng());
        let x25519_public = X25519Public::from(&x25519_secret);
        Self {
            x25519_secret,
            x25519_public,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_hybrid_psk_derivation() {
        let alice = HybridKeypair::generate();
        let bob = HybridKeypair::generate();
        let ss_a = alice.x25519_secret.diffie_hellman(&bob.x25519_public);
        let ss_b = bob.x25519_secret.diffie_hellman(&alice.x25519_public);
        let pq_kem_simulated_ss = [0x42u8; 32];
        let psk_a = derive_hybrid_psk(ss_a.as_bytes(), &pq_kem_simulated_ss, b"quantumtunnel");
        let psk_b = derive_hybrid_psk(ss_b.as_bytes(), &pq_kem_simulated_ss, b"quantumtunnel");
        assert_eq!(psk_a.0, psk_b.0);
    }
}
