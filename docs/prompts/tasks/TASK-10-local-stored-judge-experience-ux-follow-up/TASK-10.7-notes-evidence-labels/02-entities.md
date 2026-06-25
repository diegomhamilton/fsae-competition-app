# Entities Prompt

For this task:

Task: `10.7 Clarify notes and evidence states with labels such as Add Evidence, 1 Evidence, Required Evidence Missing, Add Note, and Edit Note, and ensure each state round-trips through the local test case JSON draft.`

Identify the core entities and relationships.

Include:

- Domain models, services, coordinators, views, documentation, fixtures, or validation artifacts involved
- State boundaries and ownership
- Persistence or accessibility identifiers where relevant
- Test or validation entities
- PR review entities: files, commit boundaries, and reviewer concerns

Likely files or targets:

- Step/test case UI
- Strings enums
- draft tests

Call out what can be validated through Swift Testing, static review, dedicated UI automation, or user-run manual validation.

Context:

- Macro-task: TASK#10 Local Stored Judge Experience UX Follow-up
- Subtask: TASK#10.7
- Expected PR title: `TASK#10.7: Notes Evidence Labels`
- Feature branch: `codex/inspection-event-local-judge-ux`
- Suggested task branch: `codex/inspection-event-local-judge-ux-10-7-notes-evidence-labels`
- Operation summary: Clarify notes/evidence state labels and persist each state through JSON draft round-trips.
- Likely files or targets: Step/test case UI; Strings enums; draft tests
- Validation: Swift Testing label state matrix and JSON round-trip checks.
- Split trigger: Split if evidence state model changes independently.
- Common instructions:
- Start after TASK#7 establishes stored local session behavior.
- Keep the judge task flow primary: restore context, inspect, correct blockers, submit, recheck, and verify sticker state.
- Replace prototype copy with persisted event, team, stage, and test case context.
- Make validation blockers actionable and persist corrections immediately.
- Use Swift Testing for logic, state, and helper checks.
- Use manual validation for Dynamic Type, VoiceOver, relaunch restore, and recovery paths.
- Split strongly if media capture, stopwatch timing, persistence, and layout work appear in one PR.
