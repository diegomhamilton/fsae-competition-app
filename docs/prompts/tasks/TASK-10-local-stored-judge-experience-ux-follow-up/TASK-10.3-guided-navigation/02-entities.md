# Entities Prompt

For this task:

Task: `10.3 Refactor judge navigation so Sessions, Team, and Stage are the top-level landmarks, remove the standalone Case tab, and make Stage contain the case UI with dominant next-action and focused one-step editing.`

Identify the core entities and relationships.

Include:

- Domain models, services, coordinators, views, documentation, fixtures, or validation artifacts involved
- State boundaries and ownership
- Persistence or accessibility identifiers where relevant
- Test or validation entities
- PR review entities: files, commit boundaries, and reviewer concerns

Likely files or targets:

- ContentTabsView
- ProposedScreen
- AppCoordinator / InspectionExecutionCoordinator route handling
- FullStageView
- TestCaseView
- view state
- tests

Call out what can be validated through Swift Testing, static review, dedicated UI automation, or user-run manual validation.

Context:

- Macro-task: TASK#10 Local Stored Judge Experience UX Follow-up
- Subtask: TASK#10.3
- Expected PR title: `TASK#10.3: Guided Navigation`
- Feature branch: `codex/inspection-event-local-judge-ux`
- Suggested task branch: `codex/inspection-event-local-judge-ux-10-3-guided-navigation`
- Operation summary: Implement the guided navigation refactor from `Design/Flows/InspectionEvents/JUDGE_NAVIGATION_FLOW_PROPOSAL.md`, keeping `Sessions`, `Team`, and `Stage` as top-level landmarks while Stage owns case-level execution UI.
- Likely files or targets: ContentTabsView; ProposedScreen; AppCoordinator/InspectionExecutionCoordinator route handling; FullStageView; TestCaseView; view state; tests
- Validation: Swift Testing for route transitions plus manual checks for one-step cases, multi-step cases, relaunch restore, empty states, and VoiceOver.
- Split trigger: Split if route model changes and Stage/Case UI composition cannot be reviewed together.
- Common instructions:
- Start after TASK#7 establishes stored local session behavior.
- Keep the judge task flow primary: restore context, inspect, correct blockers, submit, recheck, and verify sticker state.
- Replace prototype copy with persisted event, team, stage, and test case context.
- Make validation blockers actionable and persist corrections immediately.
- Use Swift Testing for logic, state, and helper checks.
- Use manual validation for Dynamic Type, VoiceOver, relaunch restore, and recovery paths.
- Split strongly if media capture, stopwatch timing, persistence, and layout work appear in one PR.
