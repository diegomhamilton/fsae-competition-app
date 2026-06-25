# TASK#10.7 SPDD Prompt Run

Task: `10.7 Clarify notes and evidence states with labels such as Add Evidence, 1 Evidence, Required Evidence Missing, Add Note, and Edit Note, and ensure each state round-trips through the local test case JSON draft.`

Purpose: Clarify notes/evidence state labels and persist each state through JSON draft round-trips.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: Step/test case UI; Strings enums; draft tests
- Validation: Swift Testing label state matrix and JSON round-trip checks.
- Split trigger: Split if evidence state model changes independently.

Expected PR title:

`TASK#10.7: Notes Evidence Labels`

Branch:

`codex/inspection-event-local-judge-ux-10-7-notes-evidence-labels`

Common instructions:

- Start after TASK#7 establishes stored local session behavior.
- Keep the judge task flow primary: restore context, inspect, correct blockers, submit, recheck, and verify sticker state.
- Replace prototype copy with persisted event, team, stage, and test case context.
- Make validation blockers actionable and persist corrections immediately.
- Use Swift Testing for logic, state, and helper checks.
- Use manual validation for Dynamic Type, VoiceOver, relaunch restore, and recovery paths.
- Split strongly if media capture, stopwatch timing, persistence, and layout work appear in one PR.
