#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
umask 077

TARGET="${1:---all}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
WG_CONF="${REPO_ROOT}/wg-data/wg_confs/wg0.conf"

rotate_single_client() {
  local client="$1"
  echo "[INFO] Rotating cryptographic keys for peer: ${client}"
  "${SCRIPT_DIR}/remove-client.sh" "${client}"
  "${SCRIPT_DIR}/add-client.sh" "${client}"
}

if [[ "${TARGET}" == "--all" ]]; then
  mapfile -t CLIENTS < <(awk '/^# BEGIN_PEER / {print $3}' "${WG_CONF}")
  for client in "${CLIENTS[@]}"; do
    rotate_single_client "${client}"
  done
else
  rotate_single_client "${TARGET}"
fi

echo "[SUCCESS] Key rotation completed at $(date -u +"%Y-%m-%dT%H:%M:%SZ")."
