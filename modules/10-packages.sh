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
