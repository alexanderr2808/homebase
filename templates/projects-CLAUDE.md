# homebase: instructions for Claude sessions on this Pi

You are running on **homebase**, a Raspberry Pi 5 that the owner controls from
their phone and computers through Claude Code Remote Control. This folder
(`~/projects`) holds all of their coding projects.

## Keep projects organized
- Every project lives in its own folder directly inside `~/projects`.
  Create new ones with `homebase new <name>` (lowercase, dashes, no spaces).
  It makes the folder, runs `git init` and adds a README.
- Never put project files directly in `~/projects` itself.
- Before starting work, check whether a matching project already exists
  (`homebase list`) and work inside it rather than making a duplicate.
- Give each project a short `README.md` saying what it is and how to run it,
  and keep it current.

## Save work with git
- Commit after each meaningful step, with clear messages.
- If the project has a GitHub remote, push after committing. The Pi runs on a
  microSD card, which can fail without warning; GitHub is the real backup.
- Never commit secrets (API keys, passwords, tokens). Use a `.env` file and
  list it in `.gitignore`.

## Be careful with the system
- This Pi is a small, always-on server. Ask the owner before using `sudo`,
  installing system packages, changing network settings, or rebooting.
- Do not edit `~/homebase` (the homebase tool itself) unless asked.
- Never run `homebase stop`, `homebase restart` or `homebase update` yourself:
  they restart the session you are running in. Tell the owner to run them.
- Do not change the Ethernet (`eth0`) or WiFi settings; they keep the Pi
  reachable while the owner is away.

## Resources are limited
- The Pi has limited RAM and a microSD card. Avoid running many heavy
  processes at once, and stop dev servers and watchers when done.
- Avoid writing large amounts of data (big downloads, huge logs, datasets)
  without asking.
- Check free space with `df -h ~` and memory with `free -h` if something
  seems slow.

## Useful commands
- `homebase status`: health overview (network, Tailscale, disk, temperature)
- `homebase doctor`: checks the setup and says how to fix problems
- `homebase list` / `homebase new <name>`: projects
- `homebase wake pc`: wake the owner's PC over the Ethernet cable (no password
  needed; run it whenever the owner asks)
