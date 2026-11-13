# shellcheck shell=bash
# Projects folder and the instructions file Claude reads there.
log "Setting up ${PROJECTS_DIR}"
mkdir -p "$PROJECTS_DIR"
template="$HB_ROOT/templates/projects-CLAUDE.md"
target="$PROJECTS_DIR/CLAUDE.md"
# Remember the checksum of the copy we installed, so later updates can replace
# it automatically unless you have edited it yourself.
stamp="$HB_CONFIG_DIR/projects-claude-md.sha256"
if [ ! -f "$target" ] || { [ -f "$stamp" ] && sha256sum -c --status "$stamp" 2>/dev/null; }; then
  if cmp -s "$template" "$target" 2>/dev/null; then
    ok "${target} is up to date"
  else
    cp "$template" "$target"
    ok "installed the latest ${target}"
  fi
  sha256sum "$target" > "$stamp"
elif cmp -s "$template" "$target"; then
  sha256sum "$target" > "$stamp"
  ok "${target} is up to date"
else
  cp "$template" "${target}.homebase-new"
  warn "${target} has your own edits, so it was left alone."
  warn "The latest homebase version is in ${target}.homebase-new to compare."
  warn "To use it: mv ${target}.homebase-new ${target}"
fi

if [ -z "$(git config --global user.name || true)" ] || [ -z "$(git config --global user.email || true)" ]; then
  warn "git has no name/email yet, so commits will fail. Set them with:"
  warn "  git config --global user.name \"Your Name\""
  warn "  git config --global user.email \"you@example.com\""
fi
