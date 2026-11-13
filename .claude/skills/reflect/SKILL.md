---
name: reflect
description: End-of-session review. Lists what went wrong or took too long this session, proposes the smallest skill or CLAUDE.md edit that would have prevented each, and waits for Alex's OK before applying anything.
---

# Reflect

Run at the end of every session, after updating the docs.

1. Go back over this session and list each thing that went wrong or
   took too long: a worker sent back, a check that failed, a wrong
   assumption, repeated steps, a question Alex had to answer twice.
2. For each one, give:
   - **What happened:** one line.
   - **Evidence:** the specific failure output, command, or message
     from this session. No evidence, no proposal.
   - **Proposed edit:** the smallest change to one file (CLAUDE.md, an
     agent in .claude/agents/, or a skill), shown as before → after.
3. Skip anything a one-off and unlikely to recur, and any edit that only
   restates an existing rule.
4. Present the list and stop. Apply only the edits Alex approves, exactly
   as approved. Record applied ones in docs/decisions.md.

If nothing went wrong, say so in one line and propose nothing.
