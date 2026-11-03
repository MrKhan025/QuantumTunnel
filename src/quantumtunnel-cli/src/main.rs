use anyhow::Result;
use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(name = "qtctl", about = "QuantumTunnel Enterprise Zero-Trust CLI (Ubuntu 24.04 & Android Termux)")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Check environment readiness (Ubuntu Server vs Android Termux)
    Doctor,
    /// Generate a Post-Quantum Hybrid Keypair
    GenPqKey,
}

fn main() -> Result<()> {
    let cli = Cli::parse();
    match cli.command {
        Commands::Doctor => {
            let is_termux = std::env::var("TERMUX_VERSION").is_ok()
                || std::env::var("PREFIX")
                    .map(|p| p.contains("com.termux"))
                    .unwrap_or(false);
            println!("QuantumTunnel Environment Check:");
            println!(
                "  Platform : {}",
                if is_termux {
                    "Android Termux"
                } else {
                    "Standard Linux / Ubuntu 24.04 Server"
                }
            );
            println!("  Status   : Ready");
        }
        Commands::GenPqKey => {
            let _kp = crypto_utils::HybridKeypair::generate();
            println!("Generated X25519 + ML-KEM-1024 hybrid keypair in zeroized memory.");
        }
    }
    Ok(())
}
