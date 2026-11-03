#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLIENT_NAME="${1:?Usage: $0 <client_name>}"

"${SCRIPT_DIR}/revoke-client.sh" "${CLIENT_NAME}" "permanent_removal"
rm -rf "${SCRIPT_DIR}/../wg-data/revoked/${CLIENT_NAME}"-*
echo "[SUCCESS] Client '${CLIENT_NAME}' completely removed."
