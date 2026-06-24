# TASK#10.10 SPDD Prompt Run

Task: `10.10 Add focused tests and manual validation for relaunch restore UX, actionable validation focus, camera evidence metadata, stopwatch timing, keyboard dismissal, VoiceOver operation, and common judge recovery paths.`

Purpose: Add focused Swift Testing checks and manual validation for restore, blocker focus, evidence metadata, stopwatch, keyboard, VoiceOver, and recovery paths.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: Tests; validation checklist; PR notes
- Validation: Swift Testing plus manual validation evidence.
- Split trigger: Keep as validation PR if implementation work is already large.

Expected PR title:

`TASK#10.10: Focused Tests Manual Validation`

Branch:

`codex/inspection-event-local-judge-ux-10-10-focused-tests-manual-validation`

Common instructions:

- Start after TASK#7 establishes stored local session behavior.
- Keep the judge task flow primary: restore context, inspect, correct blockers, submit, recheck, and verify sticker state.
- Replace prototype copy with persisted event, team, stage, and test case context.
- Make validation blockers actionable and persist corrections immediately.
- Use Swift Testing for logic, state, and helper checks.
- Use manual validation for Dynamic Type, VoiceOver, relaunch restore, and recovery paths.
- Split strongly if media capture, stopwatch timing, persistence, and layout work appear in one PR.
