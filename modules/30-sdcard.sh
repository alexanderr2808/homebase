# shellcheck shell=bash
# Reduce microSD wear: logs in RAM, compressed swap in RAM instead of on the card.
log "Protecting the microSD card"

if ! cmp -s "$HB_ROOT/templates/journald.conf" /etc/systemd/journald.conf.d/homebase.conf; then
  sudo mkdir -p /etc/systemd/journald.conf.d
  sudo install -m 644 "$HB_ROOT/templates/journald.conf" /etc/systemd/journald.conf.d/homebase.conf
  sudo systemctl restart systemd-journald
fi
ok "system logs kept in RAM"

if dpkg -s rpi-swap >/dev/null 2>&1; then
  ok "swap already handled by Raspberry Pi OS (zram)"
elif systemctl list-unit-files dphys-swapfile.service 2>/dev/null | grep -q dphys; then
  if systemctl is-enabled dphys-swapfile >/dev/null 2>&1; then
    sudo dphys-swapfile swapoff || true
    sudo systemctl disable --now dphys-swapfile >/dev/null 2>&1 || true
    sudo rm -f /var/swap
  fi
  if ! dpkg -s zram-tools >/dev/null 2>&1; then
    sudo apt-get install -y -qq zram-tools
  fi
  printf 'ALGO=zstd\nPERCENT=50\n' | sudo tee /etc/default/zramswap >/dev/null
  sudo systemctl enable zramswap >/dev/null 2>&1 || true
  sudo systemctl restart zramswap || true
  ok "swap moved from the microSD card to compressed RAM (zram)"
else
  ok "no swap file on the card"
fi
