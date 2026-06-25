# Entities Prompt

For this task:

Task: `10.6 Review Pending semantics so incomplete required steps are represented as derived draft state rather than a confusing judge decision when Pass, Fail, and N/A are the actual choices.`

Identify the core entities and relationships.

Include:

- Domain models, services, coordinators, views, documentation, fixtures, or validation artifacts involved
- State boundaries and ownership
- Persistence or accessibility identifiers where relevant
- Test or validation entities
- PR review entities: files, commit boundaries, and reviewer concerns

Likely files or targets:

- Models
- validation
- UI labels
- tests

Call out what can be validated through Swift Testing, static review, dedicated UI automation, or user-run manual validation.

Context:

- Macro-task: TASK#10 Local Stored Judge Experience UX Follow-up
- Subtask: TASK#10.6
- Expected PR title: `TASK#10.6: Pending Semantics`
- Feature branch: `codex/inspection-event-local-judge-ux`
- Suggested task branch: `codex/inspection-event-local-judge-ux-10-6-pending-semantics`
- Operation summary: Clarify Pending as derived incomplete state rather than a judge-selected outcome.
- Likely files or targets: Models; validation; UI labels; tests
- Validation: Swift Testing proves Pass/Fail/N/A are decisions and incomplete is derived.
- Split trigger: Split if migration from stored pending values is needed.
- Common instructions:
- Start after TASK#7 establishes stored local session behavior.
- Keep the judge task flow primary: restore context, inspect, correct blockers, submit, recheck, and verify sticker state.
- Replace prototype copy with persisted event, team, stage, and test case context.
- Make validation blockers actionable and persist corrections immediately.
- Use Swift Testing for logic, state, and helper checks.
- Use manual validation for Dynamic Type, VoiceOver, relaunch restore, and recovery paths.
- Split strongly if media capture, stopwatch timing, persistence, and layout work appear in one PR.
