# TASK#10.9 SPDD Prompt Run

Task: `10.9 Add stopwatch-style timing support for egress-test measurement steps, including start, stop, reset, manual override, validation against the allowed range, draft persistence, and accessible announcements.`

Purpose: Add egress stopwatch timing with manual override, range validation, draft persistence, and accessibility announcements.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: Timing model/service/UI; tests
- Validation: Swift Testing timer/range/persistence checks and accessibility manual note.
- Split trigger: Split if timer engine and UI integration both grow.

Expected PR title:

`TASK#10.9: Egress Stopwatch`

Branch:

`codex/inspection-event-local-judge-ux-10-9-egress-stopwatch`

Common instructions:

- Start after TASK#7 establishes stored local session behavior.
- Keep the judge task flow primary: restore context, inspect, correct blockers, submit, recheck, and verify sticker state.
- Replace prototype copy with persisted event, team, stage, and test case context.
- Make validation blockers actionable and persist corrections immediately.
- Use Swift Testing for logic, state, and helper checks.
- Use manual validation for Dynamic Type, VoiceOver, relaunch restore, and recovery paths.
- Split strongly if media capture, stopwatch timing, persistence, and layout work appear in one PR.
