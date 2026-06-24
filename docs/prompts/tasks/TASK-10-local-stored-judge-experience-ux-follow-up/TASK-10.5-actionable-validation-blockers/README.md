# TASK#10.5 SPDD Prompt Run

Task: `10.5 Make validation blockers actionable by tapping or selecting a blocker to focus the missing outcome, note, measurement, or evidence control, then persist the correction immediately to the test case JSON draft.`

Purpose: Make validation blockers selectable, focus missing controls, and persist corrections immediately.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: Validation UI; coordinator intents; persistence calls; tests
- Validation: Swift Testing focus routing and JSON draft persistence checks.
- Split trigger: Split if focus routing and persistence updates exceed one review context.

Expected PR title:

`TASK#10.5: Actionable Validation Blockers`

Branch:

`codex/inspection-event-local-judge-ux-10-5-actionable-validation-blockers`

Common instructions:

- Start after TASK#7 establishes stored local session behavior.
- Keep the judge task flow primary: restore context, inspect, correct blockers, submit, recheck, and verify sticker state.
- Replace prototype copy with persisted event, team, stage, and test case context.
- Make validation blockers actionable and persist corrections immediately.
- Use Swift Testing for logic, state, and helper checks.
- Use manual validation for Dynamic Type, VoiceOver, relaunch restore, and recovery paths.
- Split strongly if media capture, stopwatch timing, persistence, and layout work appear in one PR.
