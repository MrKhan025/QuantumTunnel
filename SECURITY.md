# Security Hardening Guide & Vulnerability Disclosure Policy

## 1. Multi-Factor Authentication (MFA) for Administration Access
1. **SSH Public Key + TOTP MFA**: Configure `/etc/ssh/sshd_config.d/99-quantumtunnel-zero-trust.conf`:
   ```text
   Port 2222
   PermitRootLogin no
   PasswordAuthentication no
   KbdInteractiveAuthentication yes
   AuthenticationMethods publickey,keyboard-interactive
   MaxAuthTries 3
   ClientAliveInterval 300
   ClientAliveCountMax 2
   AllowUsers ubuntu
   ```
2. Enable PAM Google Authenticator in `/etc/pam.d/sshd` and run `google-authenticator -t -d -f -r 3 -R 30 -w 3` to enroll TOTP MFA.

## 2. CIS Ubuntu 24.04 LTS Hardening Controls Implemented
- **Filesystem & Permissions**: `umask 077` enforced across all key-handling scripts; `wg0.conf` and `private.key` restricted to `0600`.
- **Kernel Attack Surface**: `kernel.kptr_restrict=2`, `kernel.dmesg_restrict=1`, `kernel.unprivileged_bpf_disabled=1`, `fs.suid_dumpable=0`.
- **No-Log Enforcement**: `LOG_CONFS=false` in Docker Compose and `action: labeldrop` on `endpoint` labels in `config/prometheus/prometheus.yml`.

## 3. Responsible Vulnerability Disclosure Policy
Report suspected security vulnerabilities via [GitHub Private Security Advisories](https://github.com/MrKhan025/QuantumTunnel/security/advisories). Do not open public issues for exploitable vulnerabilities.
