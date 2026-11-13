# shellcheck shell=bash
# Self-healing: hardware watchdog for full freezes, network watchdog for WiFi.
log "Setting up watchdogs"

if [ -e /dev/watchdog ] || [ -e /dev/watchdog0 ]; then
  if ! cmp -s "$HB_ROOT/templates/watchdog.conf" /etc/systemd/system.conf.d/homebase-watchdog.conf; then
    sudo mkdir -p /etc/systemd/system.conf.d
    sudo install -m 644 "$HB_ROOT/templates/watchdog.conf" /etc/systemd/system.conf.d/homebase-watchdog.conf
    sudo systemctl daemon-reexec
  fi
  ok "hardware watchdog: reboots automatically if the Pi freezes"
else
  warn "no hardware watchdog device found; skipping"
fi

render_unit homebase-netwatch.service || true
render_unit homebase-netwatch.timer || true
sudo systemctl daemon-reload
sudo systemctl enable --now homebase-netwatch.timer >/dev/null 2>&1
ok "network watchdog: checks every 2 minutes and repairs WiFi if it gets stuck"
