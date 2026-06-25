# TASK#10.2 SPDD Prompt Run

Task: `10.2 Replace prototype header/background treatment and mock state copy with stable event, team, stage, and test case context that survives relaunch restore and makes the active local session obvious.`

Purpose: Replace prototype copy and headers with persisted event/team/stage/test case context.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: SwiftUI views; Strings enums; tests/previews
- Validation: Relaunch restore shows clear active local session.
- Split trigger: Split if visual treatment and state plumbing both change heavily.

Expected PR title:

`TASK#10.2: Stable Context Copy`

Branch:

`codex/inspection-event-local-judge-ux-10-2-stable-context-copy`

Common instructions:

- Start after TASK#7 establishes stored local session behavior.
- Keep the judge task flow primary: restore context, inspect, correct blockers, submit, recheck, and verify sticker state.
- Replace prototype copy with persisted event, team, stage, and test case context.
- Make validation blockers actionable and persist corrections immediately.
- Use Swift Testing for logic, state, and helper checks.
- Use manual validation for Dynamic Type, VoiceOver, relaunch restore, and recovery paths.
- Split strongly if media capture, stopwatch timing, persistence, and layout work appear in one PR.
