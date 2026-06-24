# Entities Prompt

For this task:

Task: `10.5 Make validation blockers actionable by tapping or selecting a blocker to focus the missing outcome, note, measurement, or evidence control, then persist the correction immediately to the test case JSON draft.`

Identify the core entities and relationships.

Include:

- Domain models, services, coordinators, views, documentation, fixtures, or validation artifacts involved
- State boundaries and ownership
- Persistence or accessibility identifiers where relevant
- Test or validation entities
- PR review entities: files, commit boundaries, and reviewer concerns

Likely files or targets:

- Validation UI
- coordinator intents
- persistence calls
- tests

Call out what can be validated through Swift Testing, static review, dedicated UI automation, or user-run manual validation.

Context:

- Macro-task: TASK#10 Local Stored Judge Experience UX Follow-up
- Subtask: TASK#10.5
- Expected PR title: `TASK#10.5: Actionable Validation Blockers`
- Feature branch: `codex/inspection-event-local-judge-ux`
- Suggested task branch: `codex/inspection-event-local-judge-ux-10-5-actionable-validation-blockers`
- Operation summary: Make validation blockers selectable, focus missing controls, and persist corrections immediately.
- Likely files or targets: Validation UI; coordinator intents; persistence calls; tests
- Validation: Swift Testing focus routing and JSON draft persistence checks.
- Split trigger: Split if focus routing and persistence updates exceed one review context.
- Common instructions:
- Start after TASK#7 establishes stored local session behavior.
- Keep the judge task flow primary: restore context, inspect, correct blockers, submit, recheck, and verify sticker state.
- Replace prototype copy with persisted event, team, stage, and test case context.
- Make validation blockers actionable and persist corrections immediately.
- Use Swift Testing for logic, state, and helper checks.
- Use manual validation for Dynamic Type, VoiceOver, relaunch restore, and recovery paths.
- Split strongly if media capture, stopwatch timing, persistence, and layout work appear in one PR.
