# Contributing to QuantumTunnel

## Quality Gates Before Submitting a Pull Request
1. **ShellCheck Validation**: All scripts in `scripts/` and `scripts/termux/` must pass with zero warnings:
   ```bash
   shellcheck -x scripts/*.sh scripts/termux/*.sh tests/*.sh
   ```
2. **Docker Compose Validation**:
   ```bash
   cp .env.example .env && docker compose config -q && rm -f .env
   ```
3. **Rust Workspace Check & Tests**:
   ```bash
   cargo check --workspace && cargo test --workspace
   ```
4. **Never Commit Secrets**: Verify `.env`, `*.key`, and `*.conf` are ignored by `.gitignore`.
