# Known issues and gotchas

## Environment variables don't reach the always-on session
The homebase session is started by systemd → tmux → lib/run-session.sh,
not by a login shell, so an `export` in ~/.bashrc does not apply to it.
Settings such as CLAUDE_AUTOCOMPACT_PCT_OVERRIDE only take effect in
sessions launched from a shell where they are set, so set session-wide
variables in lib/run-session.sh, not in ~/.bashrc or settings.json.

## shellcheck must be installed to run the lint checks
Briefs whose "Done when" uses shellcheck fail if it isn't installed
(`sudo apt install -y shellcheck`).

## Never restart the homebase service from inside a session
The session doing the work may be the one running in that service.
