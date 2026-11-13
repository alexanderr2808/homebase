#!/usr/bin/env bash
# homebase installer. Safe to re-run any time; each step skips work already done.
#   Usage:  ./install.sh
set -euo pipefail

HB_ROOT="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
export HB_ROOT
# shellcheck source=lib/common.sh
. "$HB_ROOT/lib/common.sh"

[ "$(id -u)" -ne 0 ] || die "Run this as your normal user (not with sudo). It asks for sudo when needed."
have systemctl || die "systemd not found; homebase needs Raspberry Pi OS (or another systemd Linux)."

# render_unit NAME: fill in a systemd unit template and install it.
# Returns 0 if the installed file changed, 1 if it was already up to date.
render_unit() {
  local name="$1" tmp
  tmp="$(mktemp)"
  sed -e "s|@USER@|$(id -un)|g" -e "s|@HOME@|${HOME}|g" -e "s|@ROOT@|${HB_ROOT}|g" \
    "$HB_ROOT/templates/$name" > "$tmp"
  if cmp -s "$tmp" "/etc/systemd/system/$name"; then
    rm -f "$tmp"; return 1
  fi
  sudo install -m 644 "$tmp" "/etc/systemd/system/$name"
  rm -f "$tmp"
  return 0
}

echo
log "homebase installer (${HB_ROOT})"
sudo -v || die "sudo is needed for system setup."

mkdir -p "$HB_CONFIG_DIR"
[ -f "$HB_CONFIG" ] || cp "$HB_ROOT/templates/config.example" "$HB_CONFIG"
load_config

chmod +x "$HB_ROOT/bin/homebase" "$HB_ROOT/lib/"*.sh
sudo ln -sf "$HB_ROOT/bin/homebase" /usr/local/bin/homebase

for module in "$HB_ROOT"/modules/*.sh; do
  # shellcheck source=/dev/null
  . "$module"
done

echo
log "Done. Run 'homebase doctor' to check everything, or 'homebase help' for commands."
