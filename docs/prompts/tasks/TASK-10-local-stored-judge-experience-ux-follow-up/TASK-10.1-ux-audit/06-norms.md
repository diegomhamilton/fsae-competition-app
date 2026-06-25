# Norms Prompt

Apply the project norms to this task:

Task: `10.1 Audit SessionSelectorView, ActiveTeamDashboardView, FullStageView, TestCaseView, StepOverviewView, and TeamSwitchConfirmationView for the minimum UX polish needed after Task 7 so a judge can complete a fully local, stored inspection without prototype copy, unclear navigation, or dead-end states.`

Check the proposed work against these norms:

- Start after TASK#7 establishes stored local session behavior.
- Keep the judge task flow primary: restore context, inspect, correct blockers, submit, recheck, and verify sticker state.
- Replace prototype copy with persisted event, team, stage, and test case context.
- Make validation blockers actionable and persist corrections immediately.
- Use Swift Testing for logic, state, and helper checks.
- Use manual validation for Dynamic Type, VoiceOver, relaunch restore, and recovery paths.
- Split strongly if media capture, stopwatch timing, persistence, and layout work appear in one PR.
- Use Swift Testing for unit and integration checks.
- Keep dedicated UI automation in the TASK#8 PR.
- Use stable accessibility identifiers instead of localized labels for UI automation.
- Keep PR titles in the `TASK#10.1: <summary>` format.
- Keep commit titles 52 characters or fewer.
- Keep manual validation honest: `not run` is better than unsupported claims.

Return any adjustments needed before implementation.

Expected PR title:

`TASK#10.1: UX Audit`
