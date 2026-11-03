#!/usr/bin/env bash
# ==============================================================================
# scripts/add-client.sh
# Works on BOTH Ubuntu 24.04 Server AND Android Termux!
# Usage: ./scripts/add-client.sh <client_name> [--qr]
# ==============================================================================
set -euo pipefail
IFS=$'\n\t'
umask 077

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <client_name> [--qr]" >&2
  exit 1
fi

CLIENT_NAME="$1"
SHOW_QR="${2:-}"

if [[ ! "${CLIENT_NAME}" =~ ^[a-zA-Z0-9_-]{3,32}$ ]]; then
  echo "[ERROR] Invalid client name '${CLIENT_NAME}'. Use 3-32 alphanumeric, dash, or underscore characters." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib-platform.sh"
# shellcheck disable=SC1091
[[ -f "${REPO_ROOT}/.env" ]] && source "${REPO_ROOT}/.env"

WG_HOST="${WG_HOST:-vpn.example.com}"
WG_PORT="${WG_PORT:-51820}"
WG_DNS_PRIMARY="${WG_DNS_PRIMARY:-1.1.1.1,1.0.0.1}"
WG_DNS_IPV6="${WG_DNS_IPV6:-2606:4700:4700::1111}"
WG_MTU="${WG_MTU:-1420}"

ensure_wg_initialized "${REPO_ROOT}"

WG_CONFIG_DIR="${REPO_ROOT}/wg-data/wg_confs"
WG_CLIENTS_DIR="${REPO_ROOT}/wg-data/clients"
WG_CONF="${WG_CONFIG_DIR}/wg0.conf"
CLIENT_DIR="${WG_CLIENTS_DIR}/${CLIENT_NAME}"

if [[ -d "${CLIENT_DIR}" ]] || grep -q "# BEGIN_PEER ${CLIENT_NAME}$" "${WG_CONF}"; then
  echo "[ERROR] Client '${CLIENT_NAME}' already exists." >&2
  exit 1
fi

mkdir -p "${CLIENT_DIR}"
chmod 700 "${CLIENT_DIR}"

NEXT_OCTET=""
for octet in $(seq 2 254); do
  if ! grep -q "10\.66\.66\.${octet}/32" "${WG_CONF}"; then
    NEXT_OCTET="${octet}"
    break
  fi
done

if [[ -z "${NEXT_OCTET}" ]]; then
  echo "[ERROR] Subnet 10.66.66.0/24 is exhausted." >&2
  exit 1
fi

CLIENT_IPV4="10.66.66.${NEXT_OCTET}/32"
CLIENT_IPV6="fd42:42:42::${NEXT_OCTET}/128"

CLIENT_PRIV_KEY="$(wg genkey)"
CLIENT_PUB_KEY="$(echo "${CLIENT_PRIV_KEY}" | wg pubkey)"
CLIENT_PSK="$(wg genpsk)"
SERVER_PUB_KEY="$(cat "${WG_CONFIG_DIR}/server_public.key")"

printf "%s\n" "${CLIENT_PRIV_KEY}" > "${CLIENT_DIR}/private.key"
printf "%s\n" "${CLIENT_PUB_KEY}"  > "${CLIENT_DIR}/public.key"
printf "%s\n" "${CLIENT_PSK}"      > "${CLIENT_DIR}/preshared.key"
chmod 600 "${CLIENT_DIR}"/*.key

CLIENT_CONF="${CLIENT_DIR}/${CLIENT_NAME}.conf"
cat <<EOF > "${CLIENT_CONF}"
# QuantumTunnel Client Configuration: ${CLIENT_NAME}
# Provisioned: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
[Interface]
PrivateKey = ${CLIENT_PRIV_KEY}
Address = ${CLIENT_IPV4}, ${CLIENT_IPV6}
DNS = ${WG_DNS_PRIMARY}, ${WG_DNS_IPV6}
MTU = ${WG_MTU}

[Peer]
PublicKey = ${SERVER_PUB_KEY}
PresharedKey = ${CLIENT_PSK}
Endpoint = ${WG_HOST}:${WG_PORT}
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF
chmod 600 "${CLIENT_CONF}"

cat <<EOF >> "${WG_CONF}"

# BEGIN_PEER ${CLIENT_NAME}
[Peer]
# Client: ${CLIENT_NAME} | Created: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
PublicKey = ${CLIENT_PUB_KEY}
PresharedKey = ${CLIENT_PSK}
AllowedIPs = ${CLIENT_IPV4}, ${CLIENT_IPV6}
# END_PEER ${CLIENT_NAME}
EOF

# Sync live interface if running on Docker or active kernel/userspace wg0
if command -v docker >/dev/null 2>&1 && docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^quantumtunnel-wireguard$"; then
  docker exec quantumtunnel-wireguard bash -c "wg syncconf wg0 <(wg-quick strip /config/wg_confs/wg0.conf)"
elif command -v wg >/dev/null 2>&1 && ip link show wg0 >/dev/null 2>&1 && has_root; then
  wg syncconf wg0 <(wg-quick strip "${WG_CONF}")
fi

if command -v qrencode >/dev/null 2>&1; then
  qrencode -t PNG -o "${CLIENT_DIR}/${CLIENT_NAME}-qr.png" < "${CLIENT_CONF}"
  chmod 600 "${CLIENT_DIR}/${CLIENT_NAME}-qr.png"
fi

echo "[SUCCESS] Provisioned client '${CLIENT_NAME}' (${CLIENT_IPV4}, ${CLIENT_IPV6})"
echo "          Config file: ${CLIENT_CONF}"

if [[ "${SHOW_QR}" == "--qr" ]] && command -v qrencode >/dev/null 2>&1; then
  echo ""
  echo "Scan the QR code below with the official WireGuard Android/iOS app:"
  qrencode -t ansiutf8 < "${CLIENT_CONF}"
fi
