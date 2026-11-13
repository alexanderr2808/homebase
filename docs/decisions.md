# Decisions

One entry per decision: date, what was decided, why. Newest first.

## 2026-11-13: Session effort and autocompact set in run-session.sh
The always-on session exports CLAUDE_CODE_EFFORT_LEVEL and
CLAUDE_AUTOCOMPACT_PCT_OVERRIDE in lib/run-session.sh, from the config
keys CLAUDE_EFFORT (default xhigh) and CLAUDE_AUTOCOMPACT_PCT (default 40).
Why: the session is started by systemd at boot, not by a login shell, and
Claude Code ignores the autocompact variable in settings.json
(github.com/anthropics/claude-code/issues/63186).

## 2026-11-13: Orchestrator and Haiku workers
The main session plans, writes briefs and verifies results; bulk
implementation and diff review go to Haiku subagents (`builder`,
`reviewer`). Why: this keeps the main session's context for planning and
checking, and makes worker output verifiable via a "Done when" check.
