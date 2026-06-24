# Safeguards Prompt

Act as the SPDD safeguard reviewer for this task:

Task: `10.9 Add stopwatch-style timing support for egress-test measurement steps, including start, stop, reset, manual override, validation against the allowed range, draft persistence, and accessible announcements.`

Plan: `<paste operations>`

Review for:

- Scope creep beyond TASK#10.9
- Missing Swift Testing coverage for code-level behavior
- Dedicated UI automation added outside TASK#8
- Manual validation claimed without observed evidence
- Missing feature scenario or OpenSpec traceability
- Missing accessibility identifier or VoiceOver consideration where UI is touched
- Application Support storage that is not scoped by event/team/session/stage/test case where persistence is touched
- Mutable submitted snapshots where immutable history is required
- PR exceeding 10 files or mixing unrelated review contexts without a split plan
- Commit titles longer than 52 characters
- PR title not starting with `TASK#10.9:`

Return blockers first, then recommendations, then a final go/no-go.
