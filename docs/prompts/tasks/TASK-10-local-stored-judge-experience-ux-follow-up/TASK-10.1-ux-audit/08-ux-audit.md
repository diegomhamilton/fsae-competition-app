# TASK#10.1 UX Audit

Date: 2026-07-05
Branch: `codex/milestone-10-design-review`
Base: `develop` at `0157377`

## Summary

The current local judge flow has the right broad screen inventory, but it is not yet ready for a judge to complete a fully local stored inspection without confusion. `FullStageView`, `TestCaseView`, and parts of `StepOverviewView` are closest to the intended workflow because they expose draft editing, validation, evidence metadata, and accessibility identifiers. The main blockers are still at the flow and polish level: stage submission is a no-op, blocked sessions cannot be opened for correction, several first-viewport screens still show proposal/scenario copy, `Pending` is exposed as a judge-selectable outcome, and session/team-switch surfaces are missing the stable identifiers required by the accessibility spec.

This audit should remain documentation-only. The findings below should split into small implementation PRs rather than landing broad UI, persistence, submission, and accessibility changes together.

## Evidence Reviewed

- Requirements: `TASK-10.1-ux-audit/01-requirements.md`, `02-entities.md`, `03-approach.md`, `04-structure.md`, `05-operations.md`, `06-norms.md`, `07-safeguards.md`
- Common TASK#10 instructions: `docs/prompts/tasks/TASK-10-local-stored-judge-experience-ux-follow-up/common-instructions.md`
- Acceptance source: `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature`
- OpenSpec specs: `inspection-event-execution/spec.md`, `inspection-event-accessibility-localization/spec.md`
- Current UI proposal: `Design/UI/DESIGN_PROPOSAL.md`
- Current manual snapshots: `Design/UI/Snapshots/manual-sessions.png`, `manual-team.png`, `manual-stage.png`, `manual-step.png`, `manual-team-switch.png`
- Source files:
  - `SessionSelectorView.swift`
  - `ActiveTeamDashboardView.swift`
  - `FullStageView.swift`
  - `TestCaseView.swift`
  - `StepOverviewView.swift`
  - `TeamSwitchConfirmationView.swift`
  - `ContentTabsView.swift`
  - `ContentViewBindings.swift`
  - `InspectionEventCoordinator.swift`
  - `SessionSelectionCoordinator.swift`
  - `InspectionExecutionCoordinator.swift`

## Prioritized Findings

### P0 - Stage submission is visibly available but does nothing

`FullStageView` renders an enabled submit button when the stage can submit and calls `submitStage()` from the button action (`FullStageView.swift:77`). In the app shell, that closure is wired to an empty implementation (`ContentTabsView.swift:60`). This creates a direct dead-end for the feature scenario "Submit a completed stage" and the OpenSpec requirement that valid stages create immutable submission snapshots.

Recommended split: wire a submit intent through `AppCoordinator`/`InspectionExecutionCoordinator`, call `SubmissionSnapshotService`, and add Swift Testing coverage for accepted and blocked submission paths. Keep history/recheck UI out of this PR unless required to prove the submission result.

### P0 - Blocked team sessions cannot be opened for correction
A: Agree, there should be a clear flow to re-inspect if a team is blocked.

The session selector shows blocked teams as first-class rows (`SessionSelectorView.swift:38`), but selecting a blocked team returns `.blocked` in `SessionSelectionCoordinator` (`SessionSelectionCoordinator.swift:43`) and `InspectionEventCoordinator.startOrResumeSession` returns `false` without opening the session (`InspectionEventCoordinator.swift:52`). A judge seeing "Needs evidence" cannot enter that team from the roster to correct blockers.

Recommended split: treat blocked as a resumable correction state, open the prior session context, and route the judge to the relevant stage/test case when available. Keep the blocked label, but do not make it a dead end.


### P1 - Stable accessibility identifiers are incomplete on session and team-switch surfaces
A: Agree, prioritize.

The accessibility spec requires identifiers for session selector rows/status/resume/blocked actions and stage/test-case controls. Identifier coverage is strong in `FullStageView`, `TestCaseView`, and `StepOverviewView`, but `SessionSelectorView` has no row/status/action identifiers and `TeamSwitchConfirmationView` has no cancel/confirm/current/target identifiers. `ActiveTeamDashboardView` only labels the switch button, without a stable identifier (`ActiveTeamDashboardView.swift:43`).

Recommended split: add identifier factories for session/team-switch/dashboard controls, then apply them without changing layout. Leave dedicated UI automation for TASK#8.

### P1 - Prototype copy is still present in user-facing first viewports
A: Agree, remove or hide them (in debug macros).

The audit target explicitly calls for no prototype copy. Current first-viewport copy still exposes screen codes and proposal language:

- Session selector uses `SC-001 Session Selector` and an explanatory prototype panel (`SessionSelectorView.swift:14`, `SessionSelectorView.swift:56`).
- Active team dashboard uses `SC-002 Active Team Dashboard` and describes the screen rather than the judge task (`ActiveTeamDashboardView.swift:19`).
- Team switch sheet uses `SC-007 Team Switch` and "This proposal makes..." copy (`TeamSwitchConfirmationView.swift:24`).
- Test case and step detail mention mock/proposal state (`TestCaseView.swift:10`, `StepOverviewView.swift:10`).

Recommended split: replace hero eyebrow/subtitle and helper panel copy with event, team, stage, saved state, and next action language. This is a low-risk UI copy PR if it does not mix persistence or layout refactors.

### P1 - `Pending` is exposed as a judge outcome instead of derived incomplete state
A: Disagree, if judge wants to skip a test case, they have no way to left state Pending of previously selected test case.

TASK#10 common instructions say to treat `Pending` as derived incomplete state, not a confusing judge choice. The outcome enum includes `.pending` and `InspectionOutcome.allCases` drives segmented controls in both inline test-case rows and step detail (`InspectionTestStepModels.swift:216`, `TestCaseView.swift:272`, `StepOverviewView.swift:66`). The snapshots show `Pending` as a selectable fourth verdict.

Recommended split: keep `.pending` in stored draft/domain state, but expose only judge-entered choices such as Pass, Fail, and N/A in controls. Add tests that missing outcome remains incomplete without requiring the judge to choose Pending.

### P1 - Session status and last-saved information are static team model data, not restored session state
A: Agree, High effort. New milestone

`InspectionTeam` carries `status`, `currentStage`, and `lastSaved` as display fields (`InspectionModels.swift:8`). `SessionSelectionCoordinator` selects based on those static fields (`SessionSelectionCoordinator.swift:43`), while persisted sessions and saved timestamps live in `InspectionEventStore` (`InspectionEventStore.swift:202`, `InspectionEventStore.swift:262`). As a result, the roster can keep showing "Saved 2 min ago" or "Resume" from mock data rather than the latest stored session.

Recommended split: introduce a session-row view state sourced from store session records and current draft validation. Use it for status, resumable/blocked labels, current stage, and last saved text. Add coordinator/view-state tests for not started, in progress, blocked, and restored contexts.

### P1 - Team switch is not yet tied to unsaved work or save failure recovery
A: Agree, High effort. New milestone

The design proposal says the sheet should appear only when switching could affect unsaved draft work. The current dashboard switch action always targets the first non-active team (`ContentViewBindings.swift:53`) and `requestTeamSwitch` does not inspect `hasUnsavedDraft` (`InspectionExecutionCoordinator.swift:126`). The confirmation copy promises saving, but `confirmPendingTeamSwitch` simply starts/resumes the target team (`InspectionEventCoordinator.swift:86`) and there is no user-visible save failure or retry state.

Recommended split: make team switching a real target selection flow, show confirmation only for unsaved/error-prone transitions, and keep the judge on the current team if save fails. Add tests for draft isolation and restore behavior before polishing the sheet.

### P2 - Empty tab states are text-only and do not route the judge back to the next useful action
A: Agree w/ problem statement, but disagree proposed solution. I want us to propose a navigation flow as part of the solution. Would that work?

The tab model can expose `Team`, `Stage`, `Case`, or `Step` before a valid context exists. Those states use `EmptyFlowState`, which renders only repeated text in a content panel (`EmptyFlowState.swift:12`). A judge can recover by using the tab bar, but the state itself does not provide a clear action such as "Select team" or "Open current stage."

Recommended split: add context-aware empty states with a primary action, stable identifiers, and VoiceOver labels. Keep this separate from submit and persistence work.

### P2 - Evidence copy and default data still read as fake in the judge path
A: Agree, low priority.

Evidence actions append attachments named `Fake attachment` (`TestCaseView.swift:294`, `StepOverviewView.swift:214`), and step detail initializes notes/measurement with proposal defaults (`StepOverviewView.swift:26`). TASK#10.8 may keep evidence metadata-first, but TASK#10.1 still needs judge-safe language that makes the temporary metadata behavior clear without saying "fake" in the operating flow.

Recommended split: replace fake labels with inspection-safe metadata placeholders, such as "Attachment metadata 1", and ensure default values come from draft state or remain empty.

## Screen Checklist

| Screen | Status | Notes |
| --- | --- | --- |
| `SessionSelectorView` | Needs work | Shows roster shape and statuses, but includes prototype copy, no stable identifiers, static status fields, and blocked rows are dead ends. |
| `ActiveTeamDashboardView` | Needs work | Shows active team, stage list, metrics, and switch action, but first viewport still reads as a proposal and switch is icon-only with limited automation support. |
| `FullStageView` | Closest | Uses local draft state, validation panel, identifiers, and blocked submit state. Submission wiring is missing at the app shell. |
| `TestCaseView` | Partially ready | Inline draft editing and identifiers are strong. `Pending`, fake evidence naming, and non-actionable validation summary remain polish gaps. |
| `StepOverviewView` | Needs polish | Good focused editing surface and persistence hooks. Hero copy, default mock values, `Pending`, and fake evidence labels need cleanup. |
| `TeamSwitchConfirmationView` | Needs work | Shows current/target teams and confirmation actions, but copy is prototype-level, identifiers are missing, save failure is not represented, and display is not conditional on unsaved work. |

## Acceptance Traceability

- Start/resume correct team session: partially met. Start/resume exists, but roster status is static and blocked correction cannot open.
- Resumable sessions clearly identified: visually met in snapshots, but not store-derived or identifier-complete.
- Submit completed stage: not met. Submit action is a no-op.
- Block invalid submission and navigate to first invalid step: partially met. `FullStageValidationPanel` exposes blocker buttons, but full submit flow is not wired.
- Measurement values and evidence metadata: partially met. Controls persist drafts, but fake/default copy remains and validation UI needs manual proof.
- Team switching preserves drafts and isolates context: partially met in services/coordinators, but the visible switch flow is not conditional on unsaved work and lacks save-failure recovery.
- Historical submissions and sticker eligibility: not visible in audited screens.
- Accessibility identifiers and VoiceOver-complete flow: partially met. Stage/test-case/step identifiers exist; session/team-switch/dashboard identifiers and VoiceOver validation correction proof remain missing.

## Recommended Implementation Order

1. Blocked re-inspection flow: allow blocked teams to open from the session selector, restore the relevant team/stage context, and make the correction path explicit instead of leaving blocked rows as dead ends.
2. Accessibility identifier slice: add stable identifiers for session rows, status labels, blocked/resume affordances, dashboard switch controls, and team-switch confirmation actions. Keep this layout-neutral and leave dedicated UI automation for TASK#8.
3. Prototype-copy cleanup: remove user-facing `SC-*`, proposal, and mock-copy language from the six audited screens, or hide diagnostic screen codes behind debug-only UI. Replace the copy with event/team/stage/save-state context and next-action language.
4. Navigation-flow proposal: define the intended judge navigation model for sessions, team dashboard, stage, test case, step detail, empty states, and blocked correction. Use that proposal to decide whether the tab model remains, changes, or gains guided routing before implementing empty-state buttons.
5. Submission slice: wire `Submit Stage` to validation and `SubmissionSnapshotService` with Swift Testing coverage for accepted submission, blocked submission, and first-invalid-step routing.
6. Pending outcome semantics: keep `Pending` available if judges need to intentionally skip or reset a previously selected outcome, but clarify the label and behavior so it reads as "leave incomplete for now" rather than a valid inspection verdict. Add tests that pending/incomplete state still blocks required submission.
7. Evidence/default copy cleanup: replace `Fake attachment` and seeded mock note/measurement defaults with judge-safe metadata labels or empty draft-backed values. Treat this as low priority unless it blocks manual validation.
8. New milestone: store-derived session rows and last-saved state. Derive session selector row status from persisted session records and validation state rather than static `InspectionTeam` display fields.
9. New milestone: team-switch recovery. Add target selection, unsaved-only confirmation, save-failure retry handling, and draft isolation tests once the session-state model is ready.
10. Manual validation pass: Dynamic Type, VoiceOver, relaunch restore, blocked correction, stage submit, pending reset/skip behavior, and team-switch recovery once the implementation slices above exist.

## Validation

- Static source audit: completed against the files listed above.
- Existing manual snapshot review: completed against `Design/UI/Snapshots/manual-*.png`.
- Build: not run. TASK#10.1 operations explicitly say not to build automatically unless requested.
- Swift Testing: not run. This audit does not change logic.
- Manual simulator validation: not run in this pass.
- VoiceOver/Dynamic Type/relaunch restore: not run. These should be captured when the implementation slices above are ready.
