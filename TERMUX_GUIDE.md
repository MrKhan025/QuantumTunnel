# Android Termux Complete Guide for QuantumTunnel

This guide explains how to run **QuantumTunnel** inside **Android Termux** in both **Unprivileged Mode (No Root)** and **Rooted Mode (`tsu` / Magisk / KernelSU)**.

## 1. One-Command Termux Setup
```bash
pkg update -y && pkg install -y git unzip
git clone https://github.com/MrKhan025/QuantumTunnel.git
cd QuantumTunnel
chmod +x scripts/*.sh scripts/termux/*.sh
./scripts/termux/setup-termux.sh
```

## 2. Generating & Exporting Android WireGuard Profiles
```bash
# Link Termux to Android Downloads (/sdcard/Download)
termux-setup-storage

# Generate client keys, .conf, and print QR code in Termux
./scripts/add-client.sh my-phone --qr

# Export .conf to /sdcard/Download/QuantumTunnel/my-phone.conf
./scripts/termux/export-android-client.sh my-phone
```

## 3. Pushing Changes from Termux to GitHub (`MrKhan025/QuantumTunnel`)
When you edit files in Termux and want to push them to GitHub:
```bash
./scripts/termux/push-to-github.sh
```
*(Tip: When GitHub asks for a password in Termux, paste a GitHub Personal Access Token from **GitHub Settings -> Developer settings -> Personal access tokens -> Tokens (classic)** with the `repo` and `workflow` scopes checked).*

## 4. Controlling Your Remote Ubuntu 24.04 VPS from Termux
```bash
# Edit .env and set WG_HOST to your VPS IP
nano .env

# Deploy the full stack to your VPS over SSH
./scripts/termux/remote-ctl.sh deploy

# Add a client on the remote VPS and display its QR code on your phone
./scripts/termux/remote-ctl.sh add-client laptop --qr

# Download a client .conf from the VPS directly into your Android Downloads folder
./scripts/termux/remote-ctl.sh pull-client laptop
```
