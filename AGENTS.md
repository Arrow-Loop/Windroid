# Windroid lab continuation

At the start of every new/resumed session, before modifying files:

1. Read `SESSION_STATE.md`, `ROADMAP.md`, `CHANGELOG.md`, and `docs/CONTINUATION.md`.
2. Inspect `git status --short`, current branch, recent commits, and the actual
   diff. Treat interrupted operations as potentially partially completed.
3. Read the lab's HANDOFF.md and engineering journal if available at the paths
   in SESSION_STATE.md; read repository development guidance in README.md and
   docs/PLAN.md before implementation. Preserve upstream working agreements.
4. Verify the checkpoint against actual files/processes. Continue its exact next
   action; do not reinstall tools, redownload verified artifacts, or repeat
   completed experiments without a reason recorded in the journal.

Update SESSION_STATE.md after meaningful findings, validation, environment
changes, and before ending a substantial session or handing off for a reboot.
Record objective, completed work, active investigation, last successful
operation, blockers, validation, uncommitted work, and exact next action.
Keep the tracked ROADMAP.md/CHANGELOG.md accurate and mirror substantive updates
to the lab copies when that lab is present. Maintain the engineering journal.

Commit completed coherent changes with their validation; leave incomplete work
explicitly identified. Never mark a draft fix or static check as runtime proof.
Use repository-local command overrides for an automation commit identity if
none is configured; do not alter global Git identity.

Use PowerShell 7 for development/setup. Windows PowerShell 5.1 is a compatibility
test target. Check `C:\Program Files\Git\cmd\git.exe` before installing Git.
Continue authorized work without routine approval. Stay within the dedicated
lab and Windroid repositories; do not access unrelated machines/accounts.

Do not install quota polling, retry submissions, reset purchases, paid-credit
fallback, or an API-key fallback. A saved checkpoint does not itself run Codex.
Do not run a second agent against the same worktree while this chat is active.

## Publishing progress
User authorized periodic GitHub publishing on November8,2026. Update PROGRESS.md
and push completed coherent checkpoints to the development branch in
Arrow-Loop/Windroid at meaningful milestones (roughly30–60minutes of active work)
and before substantial session handoffs. Publish code and accurate validation,
keeping draft experiments labeled. Verify remote/branch and push result. Preserve
history; do not force-push or merge without separate authorization. Do not publish
APKs, signing keys, SDKs, account data or raw private logs. Perform publication
within the active session; do not install a polling/submission service.
