#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail
IFS=$'
	'
umask 077

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${SCRIPT_DIR}/lib-platform.sh"

if [[ -f "${REPO_ROOT}/.env" ]]; then
  source "${REPO_ROOT}/.env"
fi

if is_termux || ! has_root; then
  BACKUP_DIR="${BACKUP_DIR:-${REPO_ROOT}/backups}"
else
  BACKUP_DIR="${BACKUP_DIR:-/var/backups/wireguard}"
fi
BACKUP_RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-30}"
PASSPHRASE="${BACKUP_ENCRYPTION_PASSPHRASE:-default-change-me-in-env}"

mkdir -p "${BACKUP_DIR}"
chmod 700 "${BACKUP_DIR}"

TIMESTAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
ARCHIVE_NAME="quantumtunnel-wg-backup-${TIMESTAMP}.tar.gz.gpg"
ARCHIVE_PATH="${BACKUP_DIR}/${ARCHIVE_NAME}"

tar -czf - -C "${REPO_ROOT}" wg-data |   gpg --batch --yes --passphrase-fd 3 --symmetric --cipher-algo AES256       -o "${ARCHIVE_PATH}" 3<<<"${PASSPHRASE}"

sha256sum "${ARCHIVE_PATH}" > "${ARCHIVE_PATH}.sha256"
chmod 600 "${ARCHIVE_PATH}" "${ARCHIVE_PATH}.sha256"

find "${BACKUP_DIR}" -type f -name "quantumtunnel-wg-backup-*.gpg*" -mtime "+${BACKUP_RETENTION_DAYS}" -delete 2>/dev/null || true
echo "[SUCCESS] Encrypted backup created: ${ARCHIVE_PATH}"
