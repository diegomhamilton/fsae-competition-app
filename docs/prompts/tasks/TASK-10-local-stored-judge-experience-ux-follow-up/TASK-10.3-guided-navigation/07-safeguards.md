# Safeguards Prompt

Act as the SPDD safeguard reviewer for this task:

Task: `10.3 Refactor judge navigation so Sessions, Team, and Stage are the top-level landmarks, remove the standalone Case tab, and make Stage contain the case UI with dominant next-action and focused one-step editing.`

Plan: `<paste operations>`

Review for:

- Scope creep beyond TASK#10.3
- Leaving a standalone `Case` tab visible after the guided navigation refactor
- Moving case UI outside Stage or losing Stage context when a case is selected
- Missing Swift Testing coverage for code-level behavior
- Dedicated UI automation added outside TASK#8
- Manual validation claimed without observed evidence
- Missing feature scenario or OpenSpec traceability
- Missing accessibility identifier or VoiceOver consideration where UI is touched
- Application Support storage that is not scoped by event/team/session/stage/test case where persistence is touched
- Mutable submitted snapshots where immutable history is required
- PR exceeding 10 files or mixing unrelated review contexts without a split plan
- Commit titles longer than 52 characters
- PR title not starting with `TASK#10.3:`

Return blockers first, then recommendations, then a final go/no-go.
