# TASK#10.1 SPDD Prompt Run

Task: `10.1 Audit SessionSelectorView, ActiveTeamDashboardView, FullStageView, TestCaseView, StepOverviewView, and TeamSwitchConfirmationView for the minimum UX polish needed after Task 7 so a judge can complete a fully local, stored inspection without prototype copy, unclear navigation, or dead-end states.`

Purpose: Audit stored local judge workflow screens for minimum UX polish after TASK#7.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: Audit doc; view notes; issue checklist
- Validation: Manual audit mapped to judge flow.
- Split trigger: Keep audit separate if it finds broad UI changes.

Expected PR title:

`TASK#10.1: UX Audit`

Branch:

`codex/inspection-event-local-judge-ux-10-1-ux-audit`

Common instructions:

- Start after TASK#7 establishes stored local session behavior.
- Keep the judge task flow primary: restore context, inspect, correct blockers, submit, recheck, and verify sticker state.
- Replace prototype copy with persisted event, team, stage, and test case context.
- Make validation blockers actionable and persist corrections immediately.
- Use Swift Testing for logic, state, and helper checks.
- Use manual validation for Dynamic Type, VoiceOver, relaunch restore, and recovery paths.
- Split strongly if media capture, stopwatch timing, persistence, and layout work appear in one PR.
