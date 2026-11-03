#!/usr/bin/env bash
# ==============================================================================
# scripts/termux/setup-termux.sh
# Complete installer & configuration script for Android Termux!
# ==============================================================================
# shellcheck disable=SC1091
set -euo pipefail

echo "======================================================================"
echo " QuantumTunnel — Android Termux Environment Setup"
echo "======================================================================"

if [[ -z "${TERMUX_VERSION:-}" ]] && [[ "${PREFIX:-}" != *"com.termux"* ]]; then
  echo "[WARN] You do not appear to be inside Android Termux, but continuing package check..."
fi

if command -v pkg >/dev/null 2>&1; then
  echo "[1/4] Updating Termux packages and installing WireGuard & crypto tools..."
  pkg update -y
  pkg install -y     wireguard-tools     libqrencode     openssh     gnupg     age     jq     curl     git     rsync     coreutils     gawk     sed     grep     tsu     rust     clang     make     pkg-config
else
  echo "[INFO] 'pkg' not found; skipping Termux package installation."
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

echo "[2/4] Setting executable permissions on all QuantumTunnel scripts..."
chmod +x "${REPO_ROOT}/scripts/"*.sh "${REPO_ROOT}/scripts/termux/"*.sh

echo "[3/4] Initializing local .env and WireGuard key store..."
if [[ ! -f "${REPO_ROOT}/.env" ]]; then
  cp "${REPO_ROOT}/.env.example" "${REPO_ROOT}/.env"
  chmod 600 "${REPO_ROOT}/.env"
fi

source "${REPO_ROOT}/scripts/lib-platform.sh"
ensure_wg_initialized "${REPO_ROOT}"

echo "[4/4] Checking Termux Shared Storage access (for exporting .conf to Android WireGuard app)..."
if [[ ! -d "${HOME}/storage/downloads" ]]; then
  echo "  -> Tip: Run 'termux-setup-storage' once to allow exporting .conf files to your Android Downloads folder."
fi

cat <<'EOF'

[SUCCESS] QuantumTunnel is now ready to use on Termux!

Available Termux Workflows:
  1. Generate Client Config + Terminal QR Code right inside Termux:
       ./scripts/add-client.sh my-phone --qr

  2. Export a generated Client Config to Android Downloads (for importing into the Android WireGuard app):
       ./scripts/termux/export-android-client.sh my-phone

  3. Manage & Deploy to your Remote Ubuntu 24.04 VPS from Termux over SSH:
       ./scripts/termux/remote-ctl.sh status
       ./scripts/termux/remote-ctl.sh add-client laptop-work --qr
       ./scripts/termux/remote-ctl.sh deploy

  4. Run a Live WireGuard Tunnel directly inside Termux (Requires Rooted Android + tsu):
       tsu -c "./scripts/termux/termux-wg-up.sh wg0"
EOF
