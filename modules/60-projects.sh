# shellcheck shell=bash
# Projects folder and the instructions file Claude reads there.
log "Setting up ${PROJECTS_DIR}"
mkdir -p "$PROJECTS_DIR"
template="$HB_ROOT/templates/projects-CLAUDE.md"
target="$PROJECTS_DIR/CLAUDE.md"
if [ ! -f "$target" ]; then
  cp "$template" "$target"
  ok "added ${target}"
elif cmp -s "$template" "$target"; then
  ok "${target} is up to date"
else
  cp "$template" "${target}.homebase-new"
  warn "${target} has your own edits, so it was left alone."
  warn "The latest homebase version is in ${target}.homebase-new to compare."
fi

if [ -z "$(git config --global user.name || true)" ] || [ -z "$(git config --global user.email || true)" ]; then
  warn "git has no name/email yet, so commits will fail. Set them with:"
  warn "  git config --global user.name \"Your Name\""
  warn "  git config --global user.email \"you@example.com\""
fi
