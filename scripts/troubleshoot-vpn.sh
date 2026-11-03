#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib-platform.sh"

echo "======================================================================"
echo " QuantumTunnel Enterprise Diagnostics — $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "======================================================================"
if is_termux; then
  echo "[Platform] Android Termux (${TERMUX_VERSION:-detected})"
  if has_root; then
    echo "[Root Status] Rooted (tsu/su active)"
  else
    echo "[Root Status] Unprivileged User-Space Mode"
  fi
  for cmd in wg qrencode ssh gpg curl; do
    if command -v "${cmd}" >/dev/null 2>&1; then
      echo "  [OK] ${cmd} installed"
    else
      echo "  [MISSING] ${cmd} (run ./scripts/termux/setup-termux.sh)"
    fi
  done
else
  uname -a
  sysctl net.ipv4.ip_forward net.ipv6.conf.all.forwarding 2>/dev/null || true
fi
