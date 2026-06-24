# TASK#10.6 SPDD Prompt Run

Task: `10.6 Review Pending semantics so incomplete required steps are represented as derived draft state rather than a confusing judge decision when Pass, Fail, and N/A are the actual choices.`

Purpose: Clarify Pending as derived incomplete state rather than a judge-selected outcome.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: Models; validation; UI labels; tests
- Validation: Swift Testing proves Pass/Fail/N/A are decisions and incomplete is derived.
- Split trigger: Split if migration from stored pending values is needed.

Expected PR title:

`TASK#10.6: Pending Semantics`

Branch:

`codex/inspection-event-local-judge-ux-10-6-pending-semantics`

Common instructions:

- Start after TASK#7 establishes stored local session behavior.
- Keep the judge task flow primary: restore context, inspect, correct blockers, submit, recheck, and verify sticker state.
- Replace prototype copy with persisted event, team, stage, and test case context.
- Make validation blockers actionable and persist corrections immediately.
- Use Swift Testing for logic, state, and helper checks.
- Use manual validation for Dynamic Type, VoiceOver, relaunch restore, and recovery paths.
- Split strongly if media capture, stopwatch timing, persistence, and layout work appear in one PR.
