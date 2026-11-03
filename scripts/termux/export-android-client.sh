#!/usr/bin/env bash
# ==============================================================================
# scripts/termux/export-android-client.sh
# Copies a provisioned client's .conf and QR code PNG to Android Shared Downloads
# (/sdcard/Download/QuantumTunnel/) so you can import it in 1 tap into the official
# WireGuard for Android app, and prints the QR code in the Termux terminal.
# Usage: ./scripts/termux/export-android-client.sh <client_name>
# ==============================================================================
set -euo pipefail

CLIENT_NAME="${1:?Usage: $0 <client_name>}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
CLIENT_DIR="${REPO_ROOT}/wg-data/clients/${CLIENT_NAME}"
CLIENT_CONF="${CLIENT_DIR}/${CLIENT_NAME}.conf"

if [[ ! -f "${CLIENT_CONF}" ]]; then
  echo "[INFO] Client '${CLIENT_NAME}' not yet provisioned. Generating now..."
  "${REPO_ROOT}/scripts/add-client.sh" "${CLIENT_NAME}"
fi

ANDROID_DL_DIR="${HOME}/storage/downloads/QuantumTunnel"
if [[ -d "${HOME}/storage/downloads" ]]; then
  mkdir -p "${ANDROID_DL_DIR}"
  cp "${CLIENT_CONF}" "${ANDROID_DL_DIR}/${CLIENT_NAME}.conf"
  if [[ -f "${CLIENT_DIR}/${CLIENT_NAME}-qr.png" ]]; then
    cp "${CLIENT_DIR}/${CLIENT_NAME}-qr.png" "${ANDROID_DL_DIR}/${CLIENT_NAME}-qr.png"
  fi
  echo "[SUCCESS] Exported to Android Downloads: ${ANDROID_DL_DIR}/${CLIENT_NAME}.conf"
  echo "          Open the Android WireGuard app -> Tap '+' -> 'Import from file or archive' -> Select ${CLIENT_NAME}.conf"
else
  echo "[WARN] Termux storage not yet linked. Run 'termux-setup-storage' first, or copy from: ${CLIENT_CONF}"
fi

if command -v qrencode >/dev/null 2>&1; then
  echo ""
  echo "=== QR Code for '${CLIENT_NAME}' ==="
  qrencode -t ansiutf8 < "${CLIENT_CONF}"
fi
