#!/usr/bin/env bash
# ==============================================================================
# scripts/termux/remote-ctl.sh
# Manage your Ubuntu 24.04 WireGuard VPS directly from Android Termux over SSH!
# Why: Unprivileged Android does not allow Docker Engine or kernel netfilter in
# non-root Termux, so this controller lets Termux act as your mobile SecOps
# workstation to deploy, add/revoke clients, stream QR codes, and pull backups.
#
# Usage:
#   ./scripts/termux/remote-ctl.sh deploy
#   ./scripts/termux/remote-ctl.sh add-client <name> [--qr]
#   ./scripts/termux/remote-ctl.sh revoke-client <name> [reason]
#   ./scripts/termux/remote-ctl.sh list-clients
#   ./scripts/termux/remote-ctl.sh rotate-keys [name|--all]
#   ./scripts/termux/remote-ctl.sh pull-client <name>
#   ./scripts/termux/remote-ctl.sh status
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
# shellcheck disable=SC1091
[[ -f "${REPO_ROOT}/.env" ]] && source "${REPO_ROOT}/.env"

VPS_HOST="${WG_HOST:?Set WG_HOST in .env to your VPS IP or domain}"
VPS_USER="${VPS_USER:-ubuntu}"
VPS_PORT="${SSH_PORT:-2222}"
REMOTE_DIR="/opt/QuantumTunnel"

ACTION="${1:?Usage: $0 <deploy|add-client|revoke-client|list-clients|rotate-keys|pull-client|status> [args...]}"
shift || true

ssh_exec() {
  ssh -p "${VPS_PORT}" "${VPS_USER}@${VPS_HOST}" "$@"
}

case "${ACTION}" in
  deploy)
    echo "[TERMUX -> VPS] Syncing QuantumTunnel repository to ${VPS_USER}@${VPS_HOST}:${REMOTE_DIR}..."
    ssh_exec "sudo mkdir -p ${REMOTE_DIR} && sudo chown -R ${VPS_USER}:${VPS_USER} ${REMOTE_DIR}"
    rsync -az --delete --exclude 'wg-data' --exclude '.git' -e "ssh -p ${VPS_PORT}" \
      "${REPO_ROOT}/" "${VPS_USER}@${VPS_HOST}:${REMOTE_DIR}/"
    ssh_exec "cd ${REMOTE_DIR} && chmod +x scripts/*.sh && sudo ./scripts/bootstrap-ubuntu24.sh && sudo docker compose up -d"
    ;;
  add-client)
    CLIENT="${1:?Specify client name}"
    QR_FLAG="${2:---qr}"
    ssh_exec "cd ${REMOTE_DIR} && sudo ./scripts/add-client.sh ${CLIENT} ${QR_FLAG}"
    ;;
  revoke-client)
    CLIENT="${1:?Specify client name}"
    REASON="${2:-revoked_from_termux}"
    ssh_exec "cd ${REMOTE_DIR} && sudo ./scripts/revoke-client.sh ${CLIENT} ${REASON}"
    ;;
  list-clients)
    ssh_exec "cd ${REMOTE_DIR} && sudo ./scripts/list-clients.sh"
    ;;
  rotate-keys)
    TARGET="${1:---all}"
    ssh_exec "cd ${REMOTE_DIR} && sudo ./scripts/rotate-keys.sh ${TARGET}"
    ;;
  pull-client)
    CLIENT="${1:?Specify client name to download to Termux}"
    mkdir -p "${REPO_ROOT}/wg-data/clients/${CLIENT}"
    scp -P "${VPS_PORT}" "${VPS_USER}@${VPS_HOST}:${REMOTE_DIR}/wg-data/clients/${CLIENT}/${CLIENT}.conf" \
      "${REPO_ROOT}/wg-data/clients/${CLIENT}/${CLIENT}.conf"
    "${SCRIPT_DIR}/export-android-client.sh" "${CLIENT}"
    ;;
  status)
    ssh_exec "cd ${REMOTE_DIR} && sudo ./scripts/troubleshoot-vpn.sh"
    ;;
  *)
    echo "[ERROR] Unknown action '${ACTION}'." >&2
    exit 1
    ;;
esac
