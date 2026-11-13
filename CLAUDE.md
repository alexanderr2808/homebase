# homebase repository

Bash tooling that turns a Raspberry Pi 5 (Raspberry Pi OS Lite 64-bit, systemd,
NetworkManager) into an always-on Claude Code Remote Control server.

- `install.sh` must stay safe to re-run: every module checks before changing
  anything. Modules in `modules/` are *sourced* by `install.sh` (they share its
  helpers and `set -euo pipefail`); use `return`, not `exit`, to skip a step.
- Run as the normal user; use `sudo` only for system changes.
- Never restart the `homebase` service automatically: the Claude session
  editing this repo may be running inside it.
- Lint with `shellcheck -x -e SC2016 install.sh bin/homebase lib/*.sh` and
  `shellcheck -s bash modules/*.sh`.
- Keep the README's setup steps in sync with what the installer does.
