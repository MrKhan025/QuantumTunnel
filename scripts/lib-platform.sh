#!/usr/bin/env bash
# ==============================================================================
# scripts/lib-platform.sh
# Cross-platform detection and compatibility layer for:
# - Ubuntu 24.04 LTS Server (Root / Docker / Kernel WireGuard)
# - Android Termux (Unprivileged user-space OR Rooted tsu / wireguard-go)
# ==============================================================================

is_termux() {
  [[ -n "${TERMUX_VERSION:-}" ]] || [[ "${PREFIX:-}" == *"com.termux"* ]]
}

has_root() {
  [[ "${EUID:-$(id -u)}" -eq 0 ]]
}

# Portable shred/secure delete (Termux coreutils may or may not have shred installed)
secure_delete() {
  local target="$1"
  if [[ ! -f "${target}" ]]; then
    return 0
  fi
  if command -v shred >/dev/null 2>&1; then
    shred -u "${target}" 2>/dev/null || rm -f "${target}"
  else
    dd if=/dev/urandom of="${target}" bs=1k count=4 conv=notrunc >/dev/null 2>&1 || true
    rm -f "${target}"
  fi
}

# Resolve Audit Log directory (Termux cannot write to /var/log without root)
get_audit_log_path() {
  local repo_root="$1"
  if is_termux || ! has_root; then
    mkdir -p "${repo_root}/wg-data/logs"
    echo "${repo_root}/wg-data/logs/revocations.jsonl"
  else
    mkdir -p /var/log/quantumtunnel
    echo "/var/log/quantumtunnel/revocations.jsonl"
  fi
}

# Ensure Server Keys and Base wg0.conf exist (Allows running add-client.sh directly on Termux!)
ensure_wg_initialized() {
  local repo_root="$1"
  local wg_config_dir="${repo_root}/wg-data/wg_confs"
  local wg_clients_dir="${repo_root}/wg-data/clients"
  mkdir -p "${wg_config_dir}" "${wg_clients_dir}"
  chmod 700 "${wg_config_dir}" "${wg_clients_dir}"

  local server_priv="${wg_config_dir}/server_private.key"
  local server_pub="${wg_config_dir}/server_public.key"

  if [[ ! -f "${server_priv}" ]]; then
    echo "[INFO] Initializing Server Curve25519 Keypair in ${wg_config_dir}..."
    wg genkey | tee "${server_priv}" | wg pubkey > "${server_pub}"
    chmod 600 "${server_priv}" "${server_pub}"
  fi

  if [[ ! -f "${wg_config_dir}/wg0.conf" ]]; then
    local priv_val
    priv_val="$(cat "${server_priv}")"
    cat <<EOF > "${wg_config_dir}/wg0.conf"
[Interface]
Address = ${WG_IPV4_GATEWAY:-10.66.66.1}/24, ${WG_IPV6_GATEWAY:-fd42:42:42::1}/64
ListenPort = ${WG_PORT:-51820}
PrivateKey = ${priv_val}
MTU = ${WG_MTU:-1420}
SaveConfig = false

# --- BEGIN PROVISIONED PEERS ---
EOF
    chmod 600 "${wg_config_dir}/wg0.conf"
  fi
}
