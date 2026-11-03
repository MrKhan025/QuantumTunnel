#!/usr/bin/env bash
# ==============================================================================
# scripts/termux/termux-wg-up.sh
# Brings up a live WireGuard interface directly inside Rooted Android Termux
# (via Magisk / KernelSU / `tsu`). Automatically falls back to userspace
# `boringtun` / `wireguard-go` if the Android kernel lacks CONFIG_WIREGUARD.
# Usage (inside Termux): tsu -c "./scripts/termux/termux-wg-up.sh [wg0]"
# ==============================================================================
set -euo pipefail

IFACE="${1:-wg0}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
WG_CONF="${REPO_ROOT}/wg-data/wg_confs/${IFACE}.conf"

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  echo "[ERROR] Starting a local TUN/WireGuard interface on Android requires root." >&2
  echo "        Run with: tsu -c './scripts/termux/termux-wg-up.sh ${IFACE}'" >&2
  echo "        (If your phone is NOT rooted, use './scripts/termux/export-android-client.sh <name>' and import into the official Android WireGuard app!)" >&2
  exit 1
fi

if [[ ! -f "${WG_CONF}" ]]; then
  echo "[ERROR] Config file not found at ${WG_CONF}" >&2
  exit 1
fi

wg-quick up "${WG_CONF}"
wg show "${IFACE}"
echo "[SUCCESS] WireGuard interface ${IFACE} is active on Android Termux."
