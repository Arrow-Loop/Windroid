# Continuing the Windroid lab

SESSION_STATE.md is the current checkpoint; AGENTS.md requires reading it and
checking actual Git state before work. ROADMAP.md tracks unfinished scope;
CHANGELOG.md records facts. The external lab engineering journal retains exact
commands, failures and evidence. Update these after substantive work and before
handoff, restart, or ending a session. Abrupt termination can precede an update,
so always verify the actual diff/process state.

## Supported resume, checked 2026-11-06

Installed CLI: `codex-cli 0.167.0-alpha.3.2`. Read-only `--help` checks confirm
`codex resume [SESSION_ID]` and `codex exec resume [SESSION_ID] [PROMPT]`.
No inference requests were submitted by these checks.

Official documentation describes saved-session resume and scheduled tasks, but
the pages reviewed do not establish a supported desktop/CLI trigger that resumes
this chat automatically when its usage allowance resets. This is an evidence
limit, not a claim that every product version lacks the feature.

- [CLI reference](https://learn.chatgpt.com/docs/cli/reference)
- [Non-interactive mode](https://learn.chatgpt.com/docs/non-interactive-mode)
- [Scheduled tasks](https://learn.chatgpt.com/docs/automations)

Therefore no automatic reset-continuation service is configured. Scheduled work
is not a verified quota-reset signal and may submit additional tasks. Do not
add polling, retry loops, paid credits, API fallback or reset purchases without
separate explicit authorization. Disk state survives app shutdown; the agent
cannot promise it will keep executing while the app/session is stopped.

## Resume procedure

1. Reopen the existing desktop chat, or open this repository in a fresh chat.
2. Ask: `Resume Windroid from SESSION_STATE.md.`
3. Agent reads the checkpoint and guidance, checks branch/status/diff, checks
   whether the host rebooted, and continues the recorded next action.
4. Use only one active writer per worktree. Do not launch a CLI continuation
   concurrently with the desktop session.

CLI alternative: run `codex resume` in the repository and select the intended
session. An explicit known session ID is preferable for scripted one-shot use.
No actual resume command is executed by this document or any project hook.

## Visual supervision
Read AGENTS.md's visual-supervision rule on every resume. Check the relevant
window first on apparent failure/stall and periodically during longer active
UI/runtime tests (roughly30–60seconds). Stop completed owned visible diagnostics.
This is active-session behavior, not unattended background execution.

