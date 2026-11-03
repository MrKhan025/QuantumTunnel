# Encrypted Backup & Disaster Recovery Guide (`BACKUP_AND_RESTORE.md`)

## 1. Creating an Encrypted Backup (Ubuntu 24.04 or Termux)
```bash
./scripts/backup-vpn.sh
```
Creates an AES-256 GPG-encrypted `.tar.gz.gpg` archive of `wg-data` along with a `.sha256` checksum manifest and prunes backups older than `BACKUP_RETENTION_DAYS` (default: 30 days).

## 2. Automating Daily Backups via Cron (Ubuntu 24.04 Server)
```bash
sudo tee /etc/cron.d/quantumtunnel-backup >/dev/null <<'EOF'
0 3 * * * root /opt/QuantumTunnel/scripts/backup-vpn.sh >> /var/log/quantumtunnel/backup.log 2>&1
EOF
sudo chmod 600 /etc/cron.d/quantumtunnel-backup
```

## 3. Restoring from Backup
```bash
./scripts/restore-vpn.sh /path/to/quantumtunnel-wg-backup-YYYYMMDDTHHMMSSZ.tar.gz.gpg
```
Verifies the SHA-256 integrity manifest, decrypts the archive into a temporary staging directory, preserves a pre-restore snapshot, and swaps `wg-data` atomically.
