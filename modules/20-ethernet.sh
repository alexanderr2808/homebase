# shellcheck shell=bash
# Direct Pi <-> PC cable: there is no router on it handing out addresses, so
# use link-local addressing instead of waiting forever for DHCP. Internet keeps
# going over WiFi. (If you ever plug the Pi into a router instead, run:
#   sudo nmcli connection modify "<name>" ipv4.method auto ipv6.method auto)
log "Configuring the Ethernet port for the direct PC cable"
if ! have nmcli; then
  warn "NetworkManager (nmcli) not found; skipping Ethernet setup"
  return 0
fi
conn="$(eth_connection "$WOL_IFACE")"
if [ -z "$conn" ]; then
  warn "no Ethernet connection profile found for ${WOL_IFACE}; skipping"
  return 0
fi
v4="$(nmcli -g ipv4.method connection show "$conn")"
v6="$(nmcli -g ipv6.method connection show "$conn")"
if [ "$v4" = "link-local" ] && [ "$v6" = "link-local" ]; then
  ok "Ethernet ('${conn}') already uses link-local addressing"
else
  sudo nmcli connection modify "$conn" \
    ipv4.method link-local ipv6.method link-local ipv4.never-default yes ipv6.never-default yes
  warn "Ethernet changed; reconnecting it (an SSH session over the cable may drop; just reconnect)"
  sudo nmcli connection up "$conn" >/dev/null 2>&1 || true
  ok "Ethernet ('${conn}') now uses link-local addressing"
fi
