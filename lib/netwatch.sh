#!/usr/bin/env bash
# Network watchdog, run as root every 2 minutes by homebase-netwatch.timer.
#
# If the internet is unreachable it escalates, step by step:
#   ~6 min  down -> turn WiFi off and on
#   ~12 min down -> restart NetworkManager
#   ~30 min down -> reboot (at most once every 6 hours, never in the first
#                   30 minutes after boot), in case the Pi itself is stuck.
# If the school WiFi is genuinely down, nothing here can fix it; the Pi
# reconnects on its own when the WiFi comes back. The cycle repeats every
# 30 minutes while the outage lasts.
set -u
# shellcheck source=lib/common.sh
. "$(dirname "$(readlink -f "$0")")/common.sh"

STATE_DIR=/run/homebase
FAILS_FILE="$STATE_DIR/netwatch-fails"
LAST_REBOOT=/var/lib/homebase/last-netwatch-reboot
mkdir -p "$STATE_DIR" /var/lib/homebase

fails="$(cat "$FAILS_FILE" 2>/dev/null || echo 0)"

if internet_ok; then
  [ "$fails" -gt 0 ] && echo "internet back after ${fails} failed checks"
  echo 0 > "$FAILS_FILE"
  exit 0
fi

fails=$((fails + 1))
echo "$fails" > "$FAILS_FILE"
echo "internet check failed (${fails} in a row)"

# Repeat the cycle every 15 failures (30 min) while the outage lasts.
case $((fails % 15)) in
  3)
    echo "toggling WiFi"
    nmcli radio wifi off; sleep 5; nmcli radio wifi on
    ;;
  6)
    echo "restarting NetworkManager"
    systemctl restart NetworkManager
    ;;
  0)
    uptime_s="$(cut -d. -f1 /proc/uptime)"
    now="$(date +%s)"
    last="$(cat "$LAST_REBOOT" 2>/dev/null || echo 0)"
    if [ "$uptime_s" -lt 1800 ]; then
      echo "not rebooting: booted less than 30 minutes ago"
    elif [ $((now - last)) -lt 21600 ]; then
      echo "not rebooting: already rebooted for network loss in the last 6 hours"
    else
      echo "$now" > "$LAST_REBOOT"
      echo "rebooting to recover the network"
      systemctl reboot
    fi
    ;;
esac
