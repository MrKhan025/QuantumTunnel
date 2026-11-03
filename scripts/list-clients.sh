#!/usr/bin/env bash
# ==============================================================================
# scripts/list-clients.sh
# Works on both Ubuntu 24.04 and Android Termux.
# ==============================================================================
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib-platform.sh"

ensure_wg_initialized "${REPO_ROOT}"
WG_CONF="${REPO_ROOT}/wg-data/wg_confs/wg0.conf"

printf "%-22s %-34s %-46s\n" "CLIENT NAME" "ALLOCATED IPv4 / IPv6" "PUBLIC KEY"
printf "%-22s %-34s %-46s\n" "----------------------" "----------------------------------" "----------------------------------------------"

awk '
  /^# BEGIN_PEER / { client=$3 }
  /^PublicKey = /  { pub=$3 }
  /^AllowedIPs = / { ips=$3 " " $4; printf "%-22s %-34s %-46s\n", client, ips, pub }
' "${WG_CONF}"

echo ""
echo "=== Live WireGuard Tunnel Status ==="
if command -v docker >/dev/null 2>&1 && docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^quantumtunnel-wireguard$"; then
  docker exec quantumtunnel-wireguard wg show wg0
elif command -v wg >/dev/null 2>&1 && has_root && ip link show wg0 >/dev/null 2>&1; then
  wg show wg0
else
  echo "(No local active wg0 kernel interface; use scripts/termux/remote-ctl.sh to query a remote VPS from Termux)"
fi
