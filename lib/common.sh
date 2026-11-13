# shellcheck shell=bash
# Shared helpers for homebase scripts. Source this file; don't run it.
# shellcheck disable=SC2034  # variables are used by the scripts that source this

HB_ROOT="${HB_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
HB_CONFIG_DIR="${HOME}/.config/homebase"
HB_CONFIG="${HB_CONFIG_DIR}/config"
HB_SESSION="homebase"        # tmux session name
HB_SERVICE="homebase"        # systemd unit name

# Make sure the native Claude Code install location is on PATH.
case ":${PATH}:" in *":${HOME}/.local/bin:"*) ;; *) PATH="${HOME}/.local/bin:${PATH}" ;; esac
export PATH

if [ -t 1 ]; then
  C_BLUE=$'\033[1;34m'; C_GREEN=$'\033[1;32m'; C_YELLOW=$'\033[1;33m'; C_RED=$'\033[1;31m'; C_OFF=$'\033[0m'
else
  C_BLUE=""; C_GREEN=""; C_YELLOW=""; C_RED=""; C_OFF=""
fi

log()  { printf '%s==>%s %s\n' "$C_BLUE" "$C_OFF" "$*"; }
ok()   { printf ' %s✓%s %s\n' "$C_GREEN" "$C_OFF" "$*"; }
warn() { printf ' %s!%s %s\n' "$C_YELLOW" "$C_OFF" "$*" >&2; }
bad()  { printf ' %s✗%s %s\n' "$C_RED" "$C_OFF" "$*" >&2; }
die()  { bad "$*"; exit 1; }

# Defaults, overridden by ~/.config/homebase/config
load_config() {
  PROJECTS_DIR="${HOME}/projects"
  CLAUDE_CMD="claude remote-control"
  PC_MAC=""
  WOL_IFACE="eth0"
  if [ -f "$HB_CONFIG" ]; then
    # shellcheck source=/dev/null
    . "$HB_CONFIG"
  fi
}

# set_config KEY VALUE  (writes KEY="VALUE" into the config file)
set_config() {
  local key="$1" value="$2" tmp
  mkdir -p "$HB_CONFIG_DIR"
  touch "$HB_CONFIG"
  tmp="$(mktemp)"
  grep -v "^${key}=" "$HB_CONFIG" > "$tmp" || true
  printf '%s="%s"\n' "$key" "$value" >> "$tmp"
  mv "$tmp" "$HB_CONFIG"
}

# Normalise a MAC address (accepts : or - separators). Prints it, or fails.
normalize_mac() {
  local mac
  mac="$(printf '%s' "$1" | tr 'a-f-' 'A-F:')"
  [[ "$mac" =~ ^([0-9A-F]{2}:){5}[0-9A-F]{2}$ ]] || return 1
  printf '%s\n' "$mac"
}

have() { command -v "$1" >/dev/null 2>&1; }

# Name of the NetworkManager connection used by the Ethernet port, if any.
eth_connection() {
  local iface="${1:-eth0}" name
  name="$(nmcli -g GENERAL.CONNECTION device show "$iface" 2>/dev/null || true)"
  if [ -z "$name" ]; then
    name="$(nmcli -t -f NAME,TYPE connection show 2>/dev/null \
      | awk -F: '$2=="802-3-ethernet"{print $1; exit}')"
  fi
  printf '%s\n' "$name"
}

# True if the internet is reachable (any HTTP answer counts).
internet_ok() {
  curl -sS -o /dev/null --max-time 15 https://api.anthropic.com 2>/dev/null \
    || curl -sS -o /dev/null --max-time 15 https://connectivitycheck.gstatic.com/generate_204 2>/dev/null
}
