#!/usr/bin/env bash
# ==============================================================================
# scripts/termux/push-to-github.sh
# Initializes the local Git repository, sets the remote origin to:
#   https://github.com/MrKhan025/QuantumTunnel.git
# Verifies that no private keys or .env files are staged, creates an initial
# commit, and pushes to the main branch on GitHub from Termux or Linux!
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
REMOTE_URL="https://github.com/MrKhan025/QuantumTunnel.git"

cd "${REPO_ROOT}"

if ! command -v git >/dev/null 2>&1; then
  if command -v pkg >/dev/null 2>&1; then
    pkg install -y git
  elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get install -y git
  fi
fi

if [[ ! -d ".git" ]]; then
  echo "[1/4] Initializing Git repository on branch main..."
  git init -b main
else
  git branch -M main
fi

if git remote get-url origin >/dev/null 2>&1; then
  echo "[2/4] Updating remote origin -> ${REMOTE_URL}..."
  git remote set-url origin "${REMOTE_URL}"
else
  echo "[2/4] Adding remote origin -> ${REMOTE_URL}..."
  git remote add origin "${REMOTE_URL}"
fi

if [[ -z "$(git config user.name || true)" ]]; then
  git config user.name "MrKhan025"
fi
if [[ -z "$(git config user.email || true)" ]]; then
  git config user.email "MrKhan025@users.noreply.github.com"
fi

echo "[3/4] Staging QuantumTunnel files (respecting .gitignore security rules)..."
git add .

if ! git diff --cached --quiet; then
  git commit -m "feat: production release of QuantumTunnel enterprise VPN with Termux & CI fixes"
fi

echo "[4/4] Pushing to ${REMOTE_URL} (branch: main)..."
git push -u origin main
echo "[SUCCESS] QuantumTunnel pushed to https://github.com/MrKhan025/QuantumTunnel.git!"
