#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail
IFS=$'
	'
umask 077

ARCHIVE_PATH="${1:?Usage: $0 <path-to-encrypted-backup.tar.gz.gpg>}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [[ -f "${REPO_ROOT}/.env" ]]; then
  source "${REPO_ROOT}/.env"
fi
PASSPHRASE="${BACKUP_ENCRYPTION_PASSPHRASE:-default-change-me-in-env}"

if [[ -f "${ARCHIVE_PATH}.sha256" ]]; then
  sha256sum -c "${ARCHIVE_PATH}.sha256"
fi

STAGING_DIR="$(mktemp -d)"
trap 'rm -rf "${STAGING_DIR}"' EXIT

gpg --batch --yes --passphrase-fd 3 --decrypt "${ARCHIVE_PATH}" 3<<<"${PASSPHRASE}" |   tar -xzf - -C "${STAGING_DIR}"

if [[ -d "${REPO_ROOT}/wg-data" ]]; then
  mv "${REPO_ROOT}/wg-data" "${REPO_ROOT}/wg-data.pre-restore-$(date -u +%s)"
fi

mv "${STAGING_DIR}/wg-data" "${REPO_ROOT}/wg-data"
chmod -R go-rwx "${REPO_ROOT}/wg-data"
echo "[SUCCESS] Restored WireGuard state from ${ARCHIVE_PATH}."
