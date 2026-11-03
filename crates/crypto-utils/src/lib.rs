//! Hybrid Post-Quantum (X25519 + NIST FIPS 203 ML-KEM-1024) PSK derivation.
use hkdf::Hkdf;
use pqcrypto_mlkem::mlkem1024;
use pqcrypto_traits::kem::SharedSecret;
use sha2::Sha256;
use x25519_dalek::{PublicKey as X25519Public, StaticSecret as X25519Secret};
use zeroize::{Zeroize, ZeroizeOnDrop};

#[derive(Zeroize, ZeroizeOnDrop)]
pub struct HybridPresharedKey(pub [u8; 32]);

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
    pub mlkem_pk: mlkem1024::PublicKey,
    pub mlkem_sk: mlkem1024::SecretKey,
}

impl HybridKeypair {
    pub fn generate() -> Self {
        let x25519_secret = X25519Secret::random_from_rng(rand::thread_rng());
        let x25519_public = X25519Public::from(&x25519_secret);
        let (mlkem_pk, mlkem_sk) = mlkem1024::keypair();
        Self {
            x25519_secret,
            x25519_public,
            mlkem_pk,
            mlkem_sk,
        }
    }
}
