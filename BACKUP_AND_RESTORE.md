# Encrypted Backup & Disaster Recovery Guide

Run `./scripts/backup-vpn.sh` to create an AES-256 GPG-encrypted archive with a SHA-256 integrity manifest, and `./scripts/restore-vpn.sh <archive>` to verify and atomically restore `wg-data`.
