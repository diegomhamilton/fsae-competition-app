# Entities Prompt

For this task:

Task: `10.1 Audit SessionSelectorView, ActiveTeamDashboardView, FullStageView, TestCaseView, StepOverviewView, and TeamSwitchConfirmationView for the minimum UX polish needed after Task 7 so a judge can complete a fully local, stored inspection without prototype copy, unclear navigation, or dead-end states.`

Identify the core entities and relationships.

Include:

- Domain models, services, coordinators, views, documentation, fixtures, or validation artifacts involved
- State boundaries and ownership
- Persistence or accessibility identifiers where relevant
- Test or validation entities
- PR review entities: files, commit boundaries, and reviewer concerns

Likely files or targets:

- Audit doc
- view notes
- issue checklist

Call out what can be validated through Swift Testing, static review, dedicated UI automation, or user-run manual validation.

Context:

- Macro-task: TASK#10 Local Stored Judge Experience UX Follow-up
- Subtask: TASK#10.1
- Expected PR title: `TASK#10.1: UX Audit`
- Feature branch: `codex/inspection-event-local-judge-ux`
- Suggested task branch: `codex/inspection-event-local-judge-ux-10-1-ux-audit`
- Operation summary: Audit stored local judge workflow screens for minimum UX polish after TASK#7.
- Likely files or targets: Audit doc; view notes; issue checklist
- Validation: Manual audit mapped to judge flow.
- Split trigger: Keep audit separate if it finds broad UI changes.
- Common instructions:
- Start after TASK#7 establishes stored local session behavior.
- Keep the judge task flow primary: restore context, inspect, correct blockers, submit, recheck, and verify sticker state.
- Replace prototype copy with persisted event, team, stage, and test case context.
- Make validation blockers actionable and persist corrections immediately.
- Use Swift Testing for logic, state, and helper checks.
- Use manual validation for Dynamic Type, VoiceOver, relaunch restore, and recovery paths.
- Split strongly if media capture, stopwatch timing, persistence, and layout work appear in one PR.
