#!/usr/bin/env bash
# ==============================================================================
# scripts/bootstrap-ubuntu24.sh
# Production bootstrap for Ubuntu 24.04 LTS (Noble Numbat).
# Note: If run on Android Termux, automatically redirects to scripts/termux/setup-termux.sh!
# ==============================================================================
# shellcheck disable=SC1091
set -euo pipefail
IFS=$'
	'
umask 077

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${SCRIPT_DIR}/lib-platform.sh"

if is_termux; then
  echo "[INFO] Android Termux environment detected! Delegating to scripts/termux/setup-termux.sh..."
  exec "${SCRIPT_DIR}/termux/setup-termux.sh"
fi

if ! has_root; then
  echo "[ERROR] bootstrap-ubuntu24.sh must be executed as root on Ubuntu 24.04." >&2
  exit 1
fi

if [[ -f "${REPO_ROOT}/.env" ]]; then
  source "${REPO_ROOT}/.env"
fi

WG_PORT="${WG_PORT:-51820}"
SSH_PORT="${SSH_PORT:-2222}"
WG_IPV4_SUBNET="${WG_IPV4_SUBNET:-10.66.66.0/24}"
WG_IPV4_GATEWAY="${WG_IPV4_GATEWAY:-10.66.66.1}"
WG_IPV6_SUBNET="${WG_IPV6_SUBNET:-fd42:42:42::/64}"
WG_IPV6_GATEWAY="${WG_IPV6_GATEWAY:-fd42:42:42::1}"
WG_MTU="${WG_MTU:-1420}"
PUBLIC_INTERFACE="${PUBLIC_INTERFACE:-$(ip route get 1.1.1.1 | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1); exit}')}"

echo "[INFO] Configuring QuantumTunnel Gateway on interface ${PUBLIC_INTERFACE} (IPv4: ${WG_IPV4_SUBNET}, IPv6: ${WG_IPV6_SUBNET})..."

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y --no-install-recommends   wireguard-tools qrencode ufw iptables fail2ban unattended-upgrades   apt-listchanges libpam-google-authenticator auditd age jq curl gnupg

cat <<'EOF' > /etc/sysctl.d/99-quantumtunnel-wireguard-hardening.conf
net.ipv4.ip_forward = 1
net.ipv4.conf.all.forwarding = 1
net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.all.forwarding = 1
net.ipv4.conf.all.src_valid_mark = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.tcp_syncookies = 1
net.core.rmem_max = 26214400
net.core.wmem_max = 26214400
kernel.kptr_restrict = 2
kernel.dmesg_restrict = 1
kernel.unprivileged_bpf_disabled = 1
fs.suid_dumpable = 0
EOF
sysctl --system

sed -i 's/^IPV6=.*/IPV6=yes/' /etc/default/ufw
sed -i 's/^DEFAULT_FORWARD_POLICY=.*/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw

ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow "${WG_PORT}/udp" comment 'WireGuard VPN UDP'
ufw limit "${SSH_PORT}/tcp" comment 'Hardened SSH'
ufw --force enable

ensure_wg_initialized "${REPO_ROOT}"
echo "[SUCCESS] Ubuntu 24.04 WireGuard Host Hardening & Bootstrap Complete."
