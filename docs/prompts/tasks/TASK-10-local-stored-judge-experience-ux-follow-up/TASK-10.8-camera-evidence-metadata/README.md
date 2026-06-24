# TASK#10.8 SPDD Prompt Run

Task: `10.8 Add camera/photo capture support for evidence-required steps, persisting captured file metadata with the test case JSON draft while keeping full media storage behind a reviewed storage policy.`

Purpose: Add metadata-first camera/photo capture support for evidence-required steps.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: Evidence metadata; capture adapter; UI affordance; tests
- Validation: Metadata persistence checks and manual capture smoke notes.
- Split trigger: Split if platform permissions or media storage policy enters scope.

Expected PR title:

`TASK#10.8: Camera Evidence Metadata`

Branch:

`codex/inspection-event-local-judge-ux-10-8-camera-evidence-metadata`

Common instructions:

- Start after TASK#7 establishes stored local session behavior.
- Keep the judge task flow primary: restore context, inspect, correct blockers, submit, recheck, and verify sticker state.
- Replace prototype copy with persisted event, team, stage, and test case context.
- Make validation blockers actionable and persist corrections immediately.
- Use Swift Testing for logic, state, and helper checks.
- Use manual validation for Dynamic Type, VoiceOver, relaunch restore, and recovery paths.
- Split strongly if media capture, stopwatch timing, persistence, and layout work appear in one PR.
