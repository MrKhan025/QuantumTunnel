#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib-platform.sh"

echo "======================================================================"
echo " QuantumTunnel Enterprise Diagnostics — $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "======================================================================"
if is_termux; then
  echo "[Platform] Android Termux (${TERMUX_VERSION:-detected})"
  echo "[Root Status] $(has_root && echo 'Rooted (tsu/su active)' || echo 'Unprivileged User-Space Mode')"
  for cmd in wg qrencode ssh gpg curl; do
    command -v "${cmd}" >/dev/null 2>&1 && echo "  [OK] ${cmd} installed" || echo "  [MISSING] ${cmd} (run ./scripts/termux/setup-termux.sh)"
  done
else
  uname -a
  sysctl net.ipv4.ip_forward net.ipv6.conf.all.forwarding 2>/dev/null || true
fi
