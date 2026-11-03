# Running & Managing QuantumTunnel on Android Termux

## Can You Use This Repository on Termux?

**Yes — with important architectural distinctions based on how Android works:**

1. **What works natively in unprivileged (non-root) Termux right out of the box:**
   - **Cryptographic Key & Client Config Generation (`./scripts/add-client.sh`, `rotate-keys.sh`, `revoke-client.sh`, `list-clients.sh`)**: Termux provides native `wireguard-tools` (`wg genkey`, `wg pubkey`, `wg genpsk`) and `libqrencode`. Our scripts automatically detect Termux (`scripts/lib-platform.sh`) and store configs in `./wg-data` without requiring root or `/var/log`.
   - **Instant Android WireGuard App Export (`./scripts/termux/export-android-client.sh`)**: Exports generated `.conf` profiles and QR codes directly to `/sdcard/Download/QuantumTunnel/` so you can import them into the official WireGuard Android app in one tap.
   - **Remote VPS DevOps Control Center (`./scripts/termux/remote-ctl.sh`)**: Because non-root Android does not allow running the Linux kernel Docker daemon (`dockerd`), `ufw`, or kernel `iptables`, you can use Termux to remotely deploy, bootstrap, add/revoke peers, and stream QR codes from your Ubuntu 24.04 cloud VPS (AWS, Azure, DigitalOcean, or Oracle Cloud Free Tier) over SSH.
   - **Encrypted GPG Backups (`./scripts/backup-vpn.sh` & `restore-vpn.sh`)**: Works natively in Termux using `gnupg` and `tar`.
   - **Rust Control Plane CLI (`qtctl`)**: Compiles natively on ARM64 Android using Termux's `rust` and `clang` packages (`cargo build --release -p quantumtunnel-cli`).

2. **What requires a Rooted Android device (`tsu` / Magisk / KernelSU) if run locally on the phone:**
   - Creating a local `wg0` TUN network interface inside Termux (`./scripts/termux/termux-wg-up.sh wg0`).
   - Modifying kernel `sysctl` IPv4/IPv6 forwarding or `iptables`/`nftables` firewall rules locally on the phone.

---

## Step-by-Step Termux Quick Start

### Step 1: Unzip and Run the Automated Termux Setup
```bash
pkg update -y && pkg install -y unzip
unzip QuantumTunnel.zip -d QuantumTunnel
cd QuantumTunnel
chmod +x scripts/*.sh scripts/termux/*.sh
./scripts/termux/setup-termux.sh
```

### Step 2: Provision Peers & Generate QR Codes Locally on Termux
```bash
# Edit .env to set your WG_HOST (domain or public IP of your VPN server)
nano .env

# Generate a new client configuration + display scannable QR code in Termux
./scripts/add-client.sh phone-peer --qr

# Export the .conf file to your Android Downloads folder
./scripts/termux/export-android-client.sh phone-peer
```

### Step 3: Deploy & Control Your Ubuntu 24.04 VPS from Termux
```bash
# Deploy the entire Docker Compose + WireGuard + Prometheus/Grafana stack to your VPS
./scripts/termux/remote-ctl.sh deploy

# Create a client on the remote VPS and stream its QR code back to your Termux screen
./scripts/termux/remote-ctl.sh add-client tablet-peer --qr

# Pull a client .conf from the remote VPS directly into your Android Downloads folder
./scripts/termux/remote-ctl.sh pull-client tablet-peer
```
