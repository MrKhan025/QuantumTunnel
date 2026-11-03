use anyhow::Result;
use tracing_subscriber::{fmt, EnvFilter};

#[tokio::main]
async fn main() -> Result<()> {
    fmt()
        .json()
        .with_env_filter(EnvFilter::from_default_env().add_directive("info".parse()?))
        .with_current_span(false)
        .init();

    tracing::info!(
        version = env!("CARGO_PKG_VERSION"),
        pq_kem = "ML-KEM-1024+X25519",
        no_log_mode = true,
        "Starting QuantumTunnel Zero-Trust Daemon"
    );

    tokio::signal::ctrl_c().await?;
    Ok(())
}
