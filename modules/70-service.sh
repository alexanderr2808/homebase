# shellcheck shell=bash
# The always-on Claude Remote Control session.
log "Installing the always-on Claude session"
changed=0
render_unit homebase.service && changed=1
sudo systemctl daemon-reload
sudo systemctl enable homebase >/dev/null 2>&1
if ! systemctl is-active --quiet homebase; then
  if [ -d "$HOME/.claude" ]; then
    sudo systemctl start homebase && ok "session started"
  else
    warn "not starting yet: log in to Claude first, then run 'homebase start'"
  fi
elif [ "$changed" = 1 ]; then
  warn "the service changed; run 'homebase restart' when you're not mid-task"
else
  ok "session is running"
fi
