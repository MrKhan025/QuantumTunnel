# QuantumTunnel — Enterprise Multi-Protocol VPN & Ubuntu 24.04 / Termux Toolkit

QuantumTunnel is an enterprise-grade, zero-trust VPN monorepo featuring:
1. **Rust + TypeScript Core Architecture (`src/`, `crates/`)**: Multi-protocol WireGuard + OpenVPN (TLS 1.3 fallback), hybrid Post-Quantum key derivation (X25519 + NIST FIPS 203 **ML-KEM-1024**), atomic `nftables` Kill Switch, and DAITA traffic padding.
2. **Production Ubuntu 24.04 LTS WireGuard Server Stack (`docker-compose.yml`, `scripts/`)**: Automated deployment with Docker Compose, UFW + `iptables`/`ip6tables` dual-stack NAT, Fail2ban, CIS Ubuntu Level 2 sysctl hardening, Prometheus + Grafana observability, and GitHub Actions CI/CD with atomic rollback.
3. **Full Android Termux Compatibility (`scripts/termux/`, `TERMUX_GUIDE.md`)**: Native Termux detection (`scripts/lib-platform.sh`) so you can run all client/key management scripts unprivileged inside Termux, export `.conf` files to Android Downloads, or remotely orchestrate your Ubuntu 24.04 VPS over SSH.

## Quick Start (Ubuntu 24.04 LTS Server)
```bash
cp .env.example .env
chmod 600 .env
sudo ./scripts/bootstrap-ubuntu24.sh
sudo docker compose up -d
sudo ./scripts/add-client.sh alice-laptop --qr
```

## Quick Start (Android Termux)
```bash
./scripts/termux/setup-termux.sh
./scripts/add-client.sh mobile-client --qr
./scripts/termux/export-android-client.sh mobile-client
```
See [`TERMUX_GUIDE.md`](./TERMUX_GUIDE.md), [`ARCHITECTURE.md`](./ARCHITECTURE.md), [`SECURITY.md`](./SECURITY.md), and [`BACKUP_AND_RESTORE.md`](./BACKUP_AND_RESTORE.md) for full details.

## GitHub Repository & One-Command Termux Push

- **Repository**: `QuantumTunnel`
- **Remote URL**: `https://github.com/MrKhan025/QuantumTunnel.git`

```bash
unzip QuantumTunnel.zip
cd QuantumTunnel
chmod +x scripts/*.sh scripts/termux/*.sh
./scripts/termux/push-to-github.sh
```
