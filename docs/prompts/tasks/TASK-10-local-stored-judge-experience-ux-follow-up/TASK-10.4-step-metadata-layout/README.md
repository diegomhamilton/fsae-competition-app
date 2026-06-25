# TASK#10.4 SPDD Prompt Run

Task: `10.4 Refactor step metadata layout to avoid wrapping/truncation in compact widths and larger Dynamic Type: show step ID/title/status first, move rule references to a secondary row, and keep the open-step action compact.`

Purpose: Refactor step metadata layout for compact widths and larger Dynamic Type.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: StepOverviewView; metadata components; previews/tests
- Validation: Dynamic Type and compact width checks.
- Split trigger: Split if rule reference presentation becomes reusable component work.

Expected PR title:

`TASK#10.4: Step Metadata Layout`

Branch:

`codex/inspection-event-local-judge-ux-10-4-step-metadata-layout`

Common instructions:

- Start after TASK#7 establishes stored local session behavior.
- Keep the judge task flow primary: restore context, inspect, correct blockers, submit, recheck, and verify sticker state.
- Replace prototype copy with persisted event, team, stage, and test case context.
- Make validation blockers actionable and persist corrections immediately.
- Use Swift Testing for logic, state, and helper checks.
- Use manual validation for Dynamic Type, VoiceOver, relaunch restore, and recovery paths.
- Split strongly if media capture, stopwatch timing, persistence, and layout work appear in one PR.
