#!/usr/bin/env bash
# ==============================================================================
# scripts/revoke-client.sh
# Works on both Ubuntu 24.04 and Android Termux.
# Usage: ./scripts/revoke-client.sh <client_name> [reason]
# ==============================================================================
# shellcheck disable=SC1091
set -euo pipefail
IFS=$'
	'
umask 077

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <client_name> [reason]" >&2
  exit 1
fi

CLIENT_NAME="$1"
REASON="${2:-administrative_revocation}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${SCRIPT_DIR}/lib-platform.sh"

WG_CONF="${REPO_ROOT}/wg-data/wg_confs/wg0.conf"
CLIENT_DIR="${REPO_ROOT}/wg-data/clients/${CLIENT_NAME}"
REVOCATION_DIR="${REPO_ROOT}/wg-data/revoked"
AUDIT_LOG="$(get_audit_log_path "${REPO_ROOT}")"

if [[ ! -f "${WG_CONF}" ]] || ! grep -q "# BEGIN_PEER ${CLIENT_NAME}$" "${WG_CONF}"; then
  echo "[ERROR] Peer '${CLIENT_NAME}' not found in ${WG_CONF}." >&2
  exit 1
fi

CLIENT_PUB_KEY="$(sed -n "/# BEGIN_PEER ${CLIENT_NAME}$/,/# END_PEER ${CLIENT_NAME}$/p" "${WG_CONF}" | awk '/^PublicKey = / {print $3}')"

TMP_CONF="$(mktemp "${WG_CONF}.XXXXXX")"
sed "/^# BEGIN_PEER ${CLIENT_NAME}$/,/# END_PEER ${CLIENT_NAME}$/d" "${WG_CONF}" > "${TMP_CONF}"
chmod 600 "${TMP_CONF}"
mv "${TMP_CONF}" "${WG_CONF}"

if command -v docker >/dev/null 2>&1 && docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^quantumtunnel-wireguard$"; then
  docker exec quantumtunnel-wireguard wg set wg0 peer "${CLIENT_PUB_KEY}" remove
elif command -v wg >/dev/null 2>&1 && has_root && ip link show wg0 >/dev/null 2>&1; then
  wg set wg0 peer "${CLIENT_PUB_KEY}" remove
fi

mkdir -p "${REVOCATION_DIR}"
if [[ -d "${CLIENT_DIR}" ]]; then
  secure_delete "${CLIENT_DIR}/private.key"
  secure_delete "${CLIENT_DIR}/${CLIENT_NAME}.conf"
  secure_delete "${CLIENT_DIR}/${CLIENT_NAME}-qr.png"
  mv "${CLIENT_DIR}" "${REVOCATION_DIR}/${CLIENT_NAME}-$(date -u +%Y%m%d%H%M%S)"
fi

printf '{"timestamp":"%s","event":"peer_revoked","client":"%s","public_key":"%s","reason":"%s"}
'   "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "${CLIENT_NAME}" "${CLIENT_PUB_KEY}" "${REASON}" >> "${AUDIT_LOG}"

echo "[SUCCESS] Client '${CLIENT_NAME}' (${CLIENT_PUB_KEY}) revoked and keys securely wiped."
