# Safeguards Prompt

Act as the SPDD safeguard reviewer for this task:

Task: `10.7 Clarify notes and evidence states with labels such as Add Evidence, 1 Evidence, Required Evidence Missing, Add Note, and Edit Note, and ensure each state round-trips through the local test case JSON draft.`

Plan: `<paste operations>`

Review for:

- Scope creep beyond TASK#10.7
- Missing Swift Testing coverage for code-level behavior
- Dedicated UI automation added outside TASK#8
- Manual validation claimed without observed evidence
- Missing feature scenario or OpenSpec traceability
- Missing accessibility identifier or VoiceOver consideration where UI is touched
- Application Support storage that is not scoped by event/team/session/stage/test case where persistence is touched
- Mutable submitted snapshots where immutable history is required
- PR exceeding 10 files or mixing unrelated review contexts without a split plan
- Commit titles longer than 52 characters
- PR title not starting with `TASK#10.7:`

Return blockers first, then recommendations, then a final go/no-go.
