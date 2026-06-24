# TASK#10.3 SPDD Prompt Run

Task: `10.3 Refine the test case screen so the primary next judge action is visually dominant: compact case summary, actionable validation message, and focused step editor for one-step cases.`

Purpose: Refine test case screen around the judge's next action, compact summary, validation message, and focused one-step editor.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: TestCaseView; view state; tests
- Validation: Swift Testing and manual checks for one-step and multi-step cases.
- Split trigger: Split if editor refactor touches step models or persistence.

Expected PR title:

`TASK#10.3: Test Case Next Action`

Branch:

`codex/inspection-event-local-judge-ux-10-3-test-case-next-action`

Common instructions:

- Start after TASK#7 establishes stored local session behavior.
- Keep the judge task flow primary: restore context, inspect, correct blockers, submit, recheck, and verify sticker state.
- Replace prototype copy with persisted event, team, stage, and test case context.
- Make validation blockers actionable and persist corrections immediately.
- Use Swift Testing for logic, state, and helper checks.
- Use manual validation for Dynamic Type, VoiceOver, relaunch restore, and recovery paths.
- Split strongly if media capture, stopwatch timing, persistence, and layout work appear in one PR.
