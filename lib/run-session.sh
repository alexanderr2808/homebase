#!/usr/bin/env bash
# Runs inside the "homebase" tmux session (started by homebase.service).
# Keeps a Claude Code Remote Control session alive in the projects folder,
# restarting it if it ever exits.
set -u
# shellcheck source=lib/common.sh
. "$(dirname "$(readlink -f "$0")")/common.sh"
load_config

# Effort and auto-compact for the always-on session. Exported here, not in
# settings.json: Claude Code ignores the autocompact variable in settings.json.
export CLAUDE_CODE_EFFORT_LEVEL="$CLAUDE_EFFORT"
export CLAUDE_AUTOCOMPACT_PCT_OVERRIDE="$CLAUDE_AUTOCOMPACT_PCT"

mkdir -p "$PROJECTS_DIR"
cd "$PROJECTS_DIR" || exit 1

while true; do
  echo "[$(date '+%F %T')] starting: ${CLAUDE_CMD}  (in ${PROJECTS_DIR}, effort ${CLAUDE_EFFORT}, autocompact ${CLAUDE_AUTOCOMPACT_PCT}%)"
  # Word-splitting is intended: CLAUDE_CMD may contain arguments.
  # shellcheck disable=SC2086
  ${CLAUDE_CMD}
  code=$?
  echo "[$(date '+%F %T')] claude exited with code ${code}; restarting in 15s"
  echo "    (press Ctrl+C now to stop the loop; 'homebase start' brings it back)"
  sleep 15
done
