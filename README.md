<div align="center">

# 🛡️ QuantumTunnel

### Enterprise-Grade, Post-Quantum Multi-Protocol Zero-Trust VPN Platform & Automated Ubuntu 24.04 / Android Termux Toolkit

[![Deploy WireGuard Enterprise VPN](https://github.com/MrKhan025/QuantumTunnel/actions/workflows/deploy-vps.yml/badge.svg)](https://github.com/MrKhan025/QuantumTunnel/actions/workflows/deploy-vps.yml)
[![Rust CI & Crypto Audit](https://github.com/MrKhan025/QuantumTunnel/actions/workflows/ci-security-audit.yml/badge.svg)](https://github.com/MrKhan025/QuantumTunnel/actions/workflows/ci-security-audit.yml)
[![Protocol: WireGuard + OpenVPN](https://img.shields.io/badge/Protocols-WireGuard%20%7C%20OpenVPN%20TLS%201.3-00b4d8?style=flat-square)](#)
[![Post-Quantum: X25519 + ML-KEM-1024](https://img.shields.io/badge/Post--Quantum-X25519%20%2B%20ML--KEM--1024-7209b7?style=flat-square)](#)
[![Platform: Ubuntu 24.04 & Android Termux](https://img.shields.io/badge/Platform-Ubuntu%2024.04%20%7C%20Android%20Termux-2ec4b6?style=flat-square)](#)
[![License: Apache-2.0](https://img.shields.io/badge/License-Apache%202.0-f77f00?style=flat-square)](./LICENSE)

</div>

---

## 📖 Table of Contents
1. [What Is QuantumTunnel & Why Use It?](#-1-what-is-quantumtunnel--why-use-it)
2. [Core Features & Architecture Matrix](#-2-core-features--architecture-matrix)
3. [Repository Directory Structure](#-3-repository-directory-structure)
4. [Step-by-Step Execution Guide: Android Termux (Mobile Workstation)](#-4-step-by-step-execution-guide-android-termux-mobile-workstation)
5. [Step-by-Step Execution Guide: Ubuntu 24.04 LTS Cloud VPS](#-5-step-by-step-execution-guide-ubuntu-2404-lts-cloud-vps)
6. [Step-by-Step Execution Guide: GitHub Actions Automated CI/CD & Settings](#-6-step-by-step-execution-guide-github-actions-automated-cicd--settings)
7. [Complete Command Reference (Clients, QR Codes, Rotation, Revocation, Backups)](#-7-complete-command-reference-clients-qr-codes-rotation-revocation-backups)
8. [Recommended GitHub Repository Settings & Tuning Guide](#-8-recommended-github-repository-settings--tuning-guide)

---

## 🚀 1. What Is QuantumTunnel & Why Use It?

**QuantumTunnel** (`https://github.com/MrKhan025/QuantumTunnel.git`) is a production-ready, open-source VPN orchestration platform and automated deployment repository designed for **SecOps engineers, privacy-conscious developers, and enterprise network administrators**.

### What Problem Does It Solve?
Setting up a commercial or self-hosted VPN usually forces you to choose between **ease of use** and **enterprise-grade security**. Manual WireGuard setups often lack:
- Protection against **Harvest-Now-Decrypt-Later (HNDL)** quantum computer attacks.
- Automated **IPv4 + IPv6 dual-stack NAT**, **DNS/IPv6 leak protection**, and **DDoS handshake flood rate-limiting**.
- Instant **one-command client provisioning** with **scannable terminal QR codes** and **cryptographic key rotation**.
- Native compatibility with **Android Termux**, allowing you to generate keys, export Android WireGuard profiles, and control your cloud VPN servers directly from your smartphone.
- **Technical No-Log enforcement**, where Prometheus metrics automatically strip client endpoint IP addresses (`action: labeldrop`) before writing to disk.

### Primary Use Cases
1. **Self-Hosted Zero-Trust Personal & Team VPN**: Deploy a hardened WireGuard server in 60 seconds on **AWS EC2**, **Azure VM**, **DigitalOcean**, or **Oracle Cloud Always-Free Tier** (`Ubuntu 24.04 LTS`).
2. **Mobile SecOps Control Center on Android Termux**: Generate client `.conf` files, render scannable QR codes in your phone terminal, export profiles directly to the official Android WireGuard app, or manage your remote VPS over SSH—without needing a laptop.
3. **Post-Quantum & Censorship-Resistant Tunneling**: Combines classical **Curve25519 (X25519)** with hybrid **Post-Quantum PSK derivation (`crates/crypto-utils`)**, **OpenVPN TLS 1.3 TCP/443 fallback** for restrictive networks that block UDP, and **DAITA-inspired packet padding** (`crates/routing-engine`) to resist traffic fingerprinting.
4. **Enterprise Compliance & Audit Readiness**: Ships with **CIS Ubuntu 24.04 Level 2** kernel hardening (`sysctl`), **Fail2ban** intrusion prevention, **AES-256 GPG automated backups**, and a **Prometheus + Grafana** observability stack.

---

## ✨ 2. Core Features & Architecture Matrix

| Capability Domain | Implemented Feature | How It Works in QuantumTunnel |
| :--- | :--- | :--- |
| **Multi-Protocol Core** | **WireGuard (Primary) + OpenVPN TLS 1.3 (Fallback)** | Kernel WireGuard (`wg0`) for line-rate speed, `wireguard-go`/`boringtun` userspace mode for Termux/containers, and OpenVPN TCP/443 fallback when UDP is blocked. |
| **Post-Quantum Crypto** | **Hybrid X25519 + ML-KEM-1024 PSK** | Derives a 256-bit WireGuard `PresharedKey` via domain-separated `HKDF-SHA256` and scrubs key material on drop using `zeroize`. |
| **Zero-Leak Networking** | **Atomic Kill Switch + Dual-Stack IPv4/IPv6** | Uses `nftables` (`table inet quantumtunnel_killswitch`) with `fwmark 0xca6c` and UFW + `iptables`/`ip6tables` MASQUERADE with TCP MSS clamping. |
| **Traffic Obfuscation** | **DAITA Packet Padding** | Pads variable-length payloads into fixed size buckets (`128B` to `1420B`) in `crates/routing-engine` to defeat AI/ML website fingerprinting. |
| **Host Hardening** | **CIS Ubuntu 24.04 Level 2 + Fail2ban + MFA** | Enforces `kptr_restrict=2`, `rp_filter=1`, `tcp_syncookies=1`, 25 MB UDP socket buffers, UFW least-privilege ports, and Fail2ban jails (`sshd` & API). |
| **No-Log Observability** | **Prometheus + Grafana (Zero PII)** | Scrapes live tunnel throughput and peer handshakes while dropping `endpoint` IP labels (`metric_relabel_configs: labeldrop`) so user IPs are never stored. |
| **Termux Native** | **Full Android Termux Suite (`scripts/termux/`)** | Runs unprivileged on Android to generate keys/QR codes, exports `.conf` files to `/sdcard/Download/QuantumTunnel/`, or controls a remote VPS via SSH. |

---

## 📂 3. Repository Directory Structure

```text
QuantumTunnel/
├── Cargo.toml                                  # Rust Workspace (Daemon, CLI `qtctl`, API, 4 modular crates)
├── docker-compose.yml                          # Production stack: WireGuard, Prometheus, Exporters, Grafana
├── .env.example                                # Complete environment variables template
├── .gitignore                                  # Prevents private keys, .conf, and .env from leaking to Git
├── .pre-commit-config.yaml                     # Pre-commit hooks (YAML/JSON validation, private key detection, ShellCheck)
├── LICENSE                                     # Apache 2.0 License
├── README.md                                   # Complete guide, architecture, and step-by-step execution manual
├── TERMUX_GUIDE.md                             # Dedicated Android Termux manual
├── ARCHITECTURE.md                             # Mermaid data-flow diagrams & STRIDE threat model
├── SECURITY.md                                 # CIS Ubuntu 24.04 hardening, SSH+TOTP MFA & disclosure policy
├── BACKUP_AND_RESTORE.md                       # AES-256 GPG backup and disaster recovery runbook
├── API_SPEC.md                                 # OpenAPI 3.1.0 specification for the Zero-Trust Management API
├── CONTRIBUTING.md                             # Contributor workflow & quality gates
├── .github/workflows/
│   ├── deploy-vps.yml                          # ShellCheck, Docker validation & atomic VPS deploy + rollback
│   └── ci-security-audit.yml                   # Rust workspace compile & unit test pipeline
├── crates/
│   ├── crypto-utils/                           # Hybrid Post-Quantum PSK derivation & zeroizing memory
│   ├── tunnel-core/                            # WireGuard & OpenVPN TLS 1.3 protocol state machines
│   ├── routing-engine/                         # Kill switch, multi-hop routing & DAITA packet padding
│   └── dns-proxy/                              # Leak-proof DoH/DoT DNS proxy
├── src/
│   ├── quantumtunnel-daemon/                   # Node daemon entry point
│   ├── quantumtunnel-cli/                      # `qtctl` operator CLI (Linux & Termux doctor + PQ keygen)
│   ├── quantumtunnel-api/                      # Axum REST control plane (`/healthz`)
│   └── dashboard/                              # React + TypeScript observability console
├── config/
│   ├── daemon.default.toml                     # Default zero-trust daemon configuration
│   ├── quantumtunnel-config.schema.json        # JSON Schema for config validation
│   ├── prometheus/                             # prometheus.yml (with endpoint labeldrop) & alerts.yml
│   ├── grafana/                                # Auto-provisioned datasource & WireGuard dashboard JSON
│   ├── fail2ban/                               # jail.local & custom auth filter
│   └── haproxy/                                # Multi-gateway TCP/443 load balancer config
├── scripts/
│   ├── lib-platform.sh                         # Cross-platform Ubuntu 24.04 & Android Termux detection library
│   ├── bootstrap-ubuntu24.sh                   # CIS hardening, sysctl forwarding, UFW/iptables, Fail2ban setup
│   ├── add-client.sh                           # Provisions peer IPv4/IPv6, Curve25519+PSK keys, .conf & QR code
│   ├── list-clients.sh                         # Displays provisioned peers & live tunnel handshakes
│   ├── revoke-client.sh                        # Evicts peer, securely shreds keys & logs JSON audit event
│   ├── remove-client.sh                        # Permanently removes a revoked client
│   ├── rotate-keys.sh                          # Zero-downtime key rotation for single or all clients
│   ├── backup-vpn.sh                           # AES-256 GPG encrypted backup with SHA-256 manifest
│   ├── restore-vpn.sh                          # Checksum-verified atomic backup restoration
│   ├── troubleshoot-vpn.sh                     # Automated diagnostics for Linux & Termux
│   └── termux/
│       ├── setup-termux.sh                     # One-command Termux dependency installer & initializer
│       ├── export-android-client.sh            # Exports .conf & QR to Android Downloads (/sdcard/Download/QuantumTunnel)
│       ├── remote-ctl.sh                       # Controls your remote Ubuntu 24.04 VPS from Termux over SSH
│       ├── push-to-github.sh                   # Initializes Git & pushes safely to MrKhan025/QuantumTunnel
│       └── termux-wg-up.sh                     # Starts a local WireGuard interface on Rooted Android (`tsu`)
├── infra/
│   ├── terraform/                              # Multi-cloud IaC (AWS EC2, Azure VM, DigitalOcean, Oracle Cloud Free Tier)
│   └── helm/quantumtunnel/                     # Kubernetes Helm chart for cloud-native gateways
└── tests/
    ├── e2e_leak_detection.sh                   # Kill-switch, IPv6, and DNS leak verification script
    └── integration_tunnel.rs                   # Rust integration test suite
```

---

## 📱 4. Step-by-Step Execution Guide: Android Termux (Mobile Workstation)

You can use **QuantumTunnel** directly inside **Android Termux** (without root!) to generate cryptographic keys, create client `.conf` profiles, display QR codes, export configs to the Android WireGuard app, push updates to GitHub, and control your remote cloud server.

### Step 4.1: Install Termux & Extract QuantumTunnel
1. Install **Termux** and **WireGuard** on your Android phone (from F-Droid or Google Play).
2. Open Termux and run:
   ```bash
   pkg update -y && pkg upgrade -y
   pkg install -y git unzip
   ```
3. Clone your repository (or unzip `QuantumTunnel.zip`):
   ```bash
   git clone https://github.com/MrKhan025/QuantumTunnel.git
   cd QuantumTunnel
   chmod +x scripts/*.sh scripts/termux/*.sh
   ```

### Step 4.2: Run the Automated Termux Setup
Run the Termux installer script. It installs `wireguard-tools`, `libqrencode`, `openssh`, `gnupg`, `age`, `jq`, `rsync`, and `rust`, creates your `.env` file, and generates your initial server keypair inside `./wg-data`:
```bash
./scripts/termux/setup-termux.sh
```

### Step 4.3: Configure Your VPN Server Hostname/IP
Open `.env` in Termux's `nano` editor and set `WG_HOST` to your server's public IP or domain name:
```bash
nano .env
# Update: WG_HOST=YOUR_SERVER_PUBLIC_IP
```

### Step 4.4: Create a VPN Client & Export to the Android WireGuard App
```bash
# 1. Grant Termux access to your Android Downloads folder (run once and tap "Allow")
termux-setup-storage

# 2. Generate a new client configuration + display a scannable QR code in Termux
./scripts/add-client.sh my-android-phone --qr

# 3. Export the .conf and PNG QR code to /sdcard/Download/QuantumTunnel/
./scripts/termux/export-android-client.sh my-android-phone
```
Now open the **WireGuard** app on your phone -> tap the **`+`** button -> tap **Import from file or archive** -> select `Download/QuantumTunnel/my-android-phone.conf` -> tap the switch to connect!

---

## ☁️ 5. Step-by-Step Execution Guide: Ubuntu 24.04 LTS Cloud VPS

Follow these steps to deploy the full **QuantumTunnel WireGuard + Prometheus + Grafana + Fail2ban** stack on any **Ubuntu 24.04 LTS** server (AWS EC2, Azure VM, DigitalOcean Droplet, or Oracle Cloud Always-Free Tier).

### Step 5.1: Connect to Your Ubuntu 24.04 VPS & Clone QuantumTunnel
```bash
ssh ubuntu@YOUR_VPS_PUBLIC_IP
sudo apt-get update -y && sudo apt-get install -y git docker.io docker-compose-v2
git clone https://github.com/MrKhan025/QuantumTunnel.git /opt/QuantumTunnel
cd /opt/QuantumTunnel
chmod +x scripts/*.sh scripts/termux/*.sh
```

### Step 5.2: Configure `.env` Secrets
```bash
cp .env.example .env
chmod 600 .env
nano .env
```
Set these key values inside `.env`:
- `WG_HOST`: Your VPS public IPv4 address or domain name (e.g., `203.0.113.50` or `vpn.yourdomain.com`)
- `GRAFANA_ADMIN_PASSWORD`: A strong password for your Grafana dashboard
- `BACKUP_ENCRYPTION_PASSPHRASE`: A strong passphrase (32+ characters) for AES-256 encrypted backups

### Step 5.3: Run the Automated Ubuntu 24.04 Bootstrap & Hardening Script
```bash
sudo ./scripts/bootstrap-ubuntu24.sh
```
**What this script does automatically:**
- Enables IPv4 (`net.ipv4.ip_forward=1`) and IPv6 (`net.ipv6.conf.all.forwarding=1`) packet forwarding.
- Applies **CIS Ubuntu 24.04 Level 2** sysctl hardening (`rp_filter`, `tcp_syncookies`, `kptr_restrict`, 25 MB UDP socket buffers).
- Configures **UFW** firewall rules (`51820/udp` for WireGuard and rate-limited `2222/tcp` for SSH).
- Generates your server's Curve25519 private/public keys and base `wg0.conf` with strict `0600` permissions.

### Step 5.4: Launch the Docker Compose Production Stack
```bash
sudo docker compose up -d
sudo docker compose ps
```

### Step 5.5: Add Clients & View Grafana Telemetry
```bash
# Provision a new peer and print a scannable QR code in the terminal
sudo ./scripts/add-client.sh laptop-pro --qr

# List all provisioned clients and live tunnel handshakes
sudo ./scripts/list-clients.sh
```
To view the **Grafana Dashboard** securely (Grafana is bound to `127.0.0.1:3000` so it is never exposed to the public internet), run this SSH tunnel from your laptop or Termux:
```bash
ssh -p 2222 -L 3000:127.0.0.1:3000 ubuntu@YOUR_VPS_PUBLIC_IP
```
Then open `http://localhost:3000` in your browser and log in with `secops-admin` and your `GRAFANA_ADMIN_PASSWORD`.

---

## ⚙️ 6. Step-by-Step Execution Guide: GitHub Actions Automated CI/CD & Settings

### Why Your Previous Workflow Failed (And How It Is Fixed Now)
1. **Error Fixed (`Process completed with exit code 1`)**: In the previous run, `shellcheck scripts/*.sh` returned exit code `1` because `scripts/bootstrap-ubuntu24.sh` sourced `.env` without a `# shellcheck disable=SC1091` directive and defined variables (`WG_IPV4_SUBNET`, `WG_IPV6_SUBNET`, `PUBLIC_INTERFACE`) that ShellCheck flagged as unused (`SC2034`). Every script in `scripts/` and `scripts/termux/` now passes `shellcheck -x` with **zero errors and zero warnings**.
2. **Warning Fixed (`Node.js 20 is deprecated... actions/checkout@v4`)**: Both workflows now set `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: "true"` and perform native Git checkouts so **zero Node.js 20 deprecation warnings** ever appear.
3. **Smart VPS Secret Detection Added**: Previously, if you pushed code to GitHub before adding your VPS SSH secrets, the deployment job would fail trying to connect to an empty host. Now, the workflow automatically checks if `VPS_HOST` and `VPS_SSH_PRIVATE_KEY` are configured:
   - **Before you add VPS secrets**: The workflow runs all **Security Scans, File Audits, ShellCheck, Cargo Tests, and Docker Compose validations** and finishes **100% Green (Passing)** while cleanly skipping the live SSH step.
   - **After you add VPS secrets**: Every push to `main` automatically deploys to your Ubuntu 24.04 VPS and rolls back if health checks fail.

### How to Add Your VPS Secrets in GitHub (When You Have a VPS Ready)
Go to **`https://github.com/MrKhan025/QuantumTunnel/settings/secrets/actions`** and click **New repository secret** for each of the following:

| GitHub Secret Name | Example Value | Purpose |
| :--- | :--- | :--- |
| `VPS_HOST` | `203.0.113.50` | Public IPv4 address or hostname of your Ubuntu 24.04 VPS |
| `VPS_USER` | `ubuntu` | Non-root sudo username on your VPS |
| `VPS_SSH_PORT` | `2222` (or `22`) | SSH port on your VPS |
| `VPS_SSH_PRIVATE_KEY` | `-----BEGIN OPENSSH PRIVATE KEY-----...` | Ed25519 SSH private key authorized on your VPS |
| `WG_HOST` | `vpn.yourdomain.com` | Public endpoint clients connect to on UDP port `51820` |
| `GRAFANA_ADMIN_PASSWORD` | `StrongRandomPassword!` | Admin password for the local Grafana dashboard |
| `BACKUP_ENCRYPTION_PASSPHRASE` | `32CharRandomPassphrase!` | Passphrase used by `backup-vpn.sh` for AES-256 GPG encryption |

---

## 🛠️ 7. Complete Command Reference (Clients, QR Codes, Rotation, Revocation, Backups)

```bash
# Add a new client and display QR code in terminal
./scripts/add-client.sh <client_name> --qr

# List all provisioned clients and live tunnel handshakes
./scripts/list-clients.sh

# Rotate cryptographic keys (Curve25519 + PSK) for one client or all clients
./scripts/rotate-keys.sh <client_name>
./scripts/rotate-keys.sh --all

# Immediately revoke a compromised client, shred its keys & record a JSON audit entry
./scripts/revoke-client.sh <client_name> "lost_device"

# Permanently remove a client and its archived revocation directory
./scripts/remove-client.sh <client_name>

# Create an AES-256 GPG encrypted backup with SHA-256 integrity manifest
./scripts/backup-vpn.sh

# Verify SHA-256 checksum and restore WireGuard state from an encrypted backup
./scripts/restore-vpn.sh ./backups/quantumtunnel-wg-backup-YYYYMMDDTHHMMSSZ.tar.gz.gpg

# Run automated diagnostics & environment health checks
./scripts/troubleshoot-vpn.sh
```

---

## 💡 8. Recommended GitHub Repository Settings & Tuning Guide

To make your `MrKhan025/QuantumTunnel` GitHub repository and VPN server maximally secure and high-performing, apply these recommended settings:

### A. Recommended GitHub Repository Settings (`github.com/MrKhan025/QuantumTunnel/settings`)
1. **Enable Branch Protection on `main`** (*Settings -> Branches -> Add branch ruleset*):
   - Enable **Require status checks to pass** and select **`Security Scan & ShellCheck`** and **`Rust Workspace Check & Unit Tests`**.
   - Enable **Block force pushes** so commit history cannot be overwritten.
2. **Enable GitHub Secret Scanning & Push Protection** (*Settings -> Code security*):
   - Turn on **Secret scanning** and **Push protection** so GitHub automatically blocks any accidental commit containing an SSH key or token.
   - Enable **Dependabot alerts** and **Dependabot security updates** to automatically patch Rust crates and Docker images.
3. **Set Repository Topics & Description** (*Click the ⚙️ gear icon next to "About" on the repo homepage*):
   - **Description**: `Enterprise Post-Quantum WireGuard & OpenVPN Zero-Trust VPN Platform for Ubuntu 24.04 & Android Termux`
   - **Topics**: `wireguard`, `vpn`, `post-quantum-cryptography`, `zero-trust`, `ubuntu-24-04`, `termux`, `docker-compose`, `rust`, `cybersecurity`, `devops`

### B. Recommended `.env` & Network Performance Settings
1. **Optimal `WG_MTU` Settings for Different Networks**:
   - **Standard Cloud VPS (AWS / DigitalOcean / Linode)**: Keep `WG_MTU=1420` (default).
   - **PPPoE Fiber or Mobile 4G/5G Hotspots (Jio / Airtel / Vi in India)**: Lower `WG_MTU=1380` or `WG_MTU=1280` in `.env` if you notice slow page loads on mobile networks—mobile IPv6/4G carriers often use smaller outer frames.
2. **Recommended Privacy & Ad-Blocking DNS (`WG_DNS_PRIMARY` in `.env`)**:
   - **Fastest Low-Latency**: `1.1.1.1,1.0.0.1` (Cloudflare Zero-Log)
   - **Malware & Phishing Protection**: `1.1.1.2,1.0.0.2` (Cloudflare Security) or `9.9.9.9` (Quad9)
   - **Ad + Tracker Blocking**: `194.242.2.2` (Mullvad Ad-blocking DNS)
3. **Mobile Battery Optimization (`WG_PERSISTENT_KEEPALIVE`)**:
   - Default is `25` seconds (ideal for traversing strict carrier-grade NAT). If you only initiate outbound connections from your phone and want to save mobile battery, increase `PersistentKeepalive = 60` in client configs.
