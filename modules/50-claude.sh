# shellcheck shell=bash
# Claude Code (native installer; it keeps itself updated).
log "Checking Claude Code"
if ! have claude; then
  curl -fsSL https://claude.ai/install.sh | bash
  hash -r
fi
have claude || die "Claude Code did not install. Run: curl -fsSL https://claude.ai/install.sh | bash"
ok "Claude Code $(claude --version 2>/dev/null | head -1)"
if [ ! -d "$HOME/.claude" ]; then
  warn "Claude doesn't look logged in yet. Run 'claude' once, sign in, then '/exit'."
fi
