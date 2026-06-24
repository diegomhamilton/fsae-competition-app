# Entities Prompt

For this task:

Task: `10.2 Replace prototype header/background treatment and mock state copy with stable event, team, stage, and test case context that survives relaunch restore and makes the active local session obvious.`

Identify the core entities and relationships.

Include:

- Domain models, services, coordinators, views, documentation, fixtures, or validation artifacts involved
- State boundaries and ownership
- Persistence or accessibility identifiers where relevant
- Test or validation entities
- PR review entities: files, commit boundaries, and reviewer concerns

Likely files or targets:

- SwiftUI views
- Strings enums
- tests/previews

Call out what can be validated through Swift Testing, static review, dedicated UI automation, or user-run manual validation.

Context:

- Macro-task: TASK#10 Local Stored Judge Experience UX Follow-up
- Subtask: TASK#10.2
- Expected PR title: `TASK#10.2: Stable Context Copy`
- Feature branch: `codex/inspection-event-local-judge-ux`
- Suggested task branch: `codex/inspection-event-local-judge-ux-10-2-stable-context-copy`
- Operation summary: Replace prototype copy and headers with persisted event/team/stage/test case context.
- Likely files or targets: SwiftUI views; Strings enums; tests/previews
- Validation: Relaunch restore shows clear active local session.
- Split trigger: Split if visual treatment and state plumbing both change heavily.
- Common instructions:
- Start after TASK#7 establishes stored local session behavior.
- Keep the judge task flow primary: restore context, inspect, correct blockers, submit, recheck, and verify sticker state.
- Replace prototype copy with persisted event, team, stage, and test case context.
- Make validation blockers actionable and persist corrections immediately.
- Use Swift Testing for logic, state, and helper checks.
- Use manual validation for Dynamic Type, VoiceOver, relaunch restore, and recovery paths.
- Split strongly if media capture, stopwatch timing, persistence, and layout work appear in one PR.
