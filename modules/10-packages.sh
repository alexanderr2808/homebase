# shellcheck shell=bash
# System packages homebase needs.
log "Installing packages"
pkgs=(git tmux curl etherwake)
missing=()
for p in "${pkgs[@]}"; do
  dpkg -s "$p" >/dev/null 2>&1 || missing+=("$p")
done
if [ "${#missing[@]}" -gt 0 ]; then
  sudo apt-get update -qq
  sudo apt-get install -y -qq "${missing[@]}"
fi
ok "packages: ${pkgs[*]}"

# Let `homebase wake pc` run without a password prompt, so it also works when
# the Claude session runs it for you. This allows only the etherwake command.
etherwake_path="$(command -v etherwake || echo /usr/sbin/etherwake)"
rule="$(id -un) ALL=(root) NOPASSWD: ${etherwake_path}"
if [ "$(sudo cat /etc/sudoers.d/homebase-wake 2>/dev/null)" != "$rule" ]; then
  tmp="$(mktemp)"
  printf '%s\n' "$rule" > "$tmp"
  if sudo visudo -cf "$tmp" >/dev/null; then
    sudo install -m 440 -o root -g root "$tmp" /etc/sudoers.d/homebase-wake
  else
    warn "couldn't add the passwordless rule for etherwake; 'homebase wake pc' will ask for your password"
  fi
  rm -f "$tmp"
fi
ok "'homebase wake pc' works without a password prompt"
