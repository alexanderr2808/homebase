# shellcheck shell=bash
# Tailscale: reach the Pi from anywhere without touching the router.
log "Checking Tailscale"
if ! have tailscale; then
  curl -fsSL https://tailscale.com/install.sh | sh
fi
if tailscale status >/dev/null 2>&1; then
  ok "Tailscale connected ($(tailscale ip -4 2>/dev/null | head -1))"
  warn "Reminder: disable key expiry for this Pi at login.tailscale.com/admin/machines"
else
  warn "Tailscale is installed but not logged in. Run: sudo tailscale up"
fi
