# Epic 1 Task Plan — One-Team Inspection Stages Workflow

Parent branch:
- `feature/epic-1-inspection-stages-workflow`

Merge target after Epic completion:
- `develop`

## Epic Overview

Goal:
- Implement the inspection execution workflow for one active session/team by replacing mock state in the existing SwiftUI skeleton with domain-backed state, view models, validation, and navigation.

Scope:
- One active team/session only.
- Team and Stage are the primary tabs for the active workflow.
- Step detail is a drill-in destination from Stage.
- Draft edits live only for the current app process.
- Stage submission is blocked until validation passes.
- Existing SwiftUI skeleton views, navigation shape, and design components are the starting point.

Milestones:
| Milestone | Name | Goal |
|---|---|---|
| 1 | Inspection Content Foundation | Load bundled inspection content into stable domain models without editable draft state. |
| 2 | Single Active Team Shell | Route the existing SwiftUI skeleton into one active team/session workflow. |
| 3 | Runtime Draft Editing Foundation | Introduce process-lifetime draft state shared by Stage and Step detail. |
| 4 | Validation Pipeline | Add submit-blocking validation rules incrementally. |
| 5 | Stage Execution UI | Replace mock Stage behavior with editable, validation-aware execution. |
| 6 | Step Detail and Navigation | Add drill-in editing and complete expected back flows. |
| 7 | Epic Integration and Cleanup | Remove active mock dependencies and validate the complete one-team loop. |

Non-goals:
- Multi-team selection and team switching.
- Durable draft persistence across relaunches.
- Historical submissions.
- Re-submission flow.
- Attachment file storage or camera/file picker integration.
- A from-scratch rewrite of the app UI.

Completion criteria:
- Team tab opens with one active team.
- Team tab shows current stage, overall progress, open blockers, and stage rows.
- Selecting a stage opens Stage.
- Stage supports inline verdict, notes, measurement, and evidence metadata edits.
- Step detail opens from a Stage row and reflects edits back into Stage.
- Back navigation works for Stage-to-Team and Step-to-Stage flows.
- Stage submit is blocked until validation passes.
- Edits persist while the app process is alive and reset on relaunch.

## Branching Workflow

Each task branch is created from the Epic branch:
- `feature/epic-1-inspection-stages-workflow`

Each task branch opens a PR back into the Epic branch:
- `feature/epic-1-inspection-stages-workflow`

After all Epic task PRs merge, the Epic branch opens one PR into:
- `develop`

## Terminology

Durable persistence:
- Data written to storage that survives app termination, device restart, or app relaunch. Examples include files, SQLite, SwiftData/Core Data, UserDefaults, or cloud storage.

No durable persistence:
- Epic 1 must not write draft inspection state to storage that survives relaunch. Draft state may exist in Swift objects while the app is running, but it resets when the process starts again.

Draft edits held in memory:
- User edits are stored in app runtime state, such as an observable store or view model dependency. This allows screens in the same running app process to share edits without saving to disk.

Read back by `stepId`:
- Given a stable step identifier, the app can retrieve the current draft result for that step from the runtime draft state. This is needed so Stage and Step detail can show and edit the same draft result.

## Milestone 1 — Inspection Content Foundation

Goal:
- Load bundled inspection content into stable domain models without introducing editable draft state yet.

### PR 1.1 — Decode Bundled Stage JSON

Proposed branch:
- `codex/e1-m1-json-decoding`

Scope:
- Add JSON DTOs for bundled inspection files.
- Decode files from `Design/Resources/InspectionEvent`.
- Preserve stage, section, test case, and step ordering.

Validation flow:
- Given bundled JSON, decoding returns all stages in display order.
- Malformed or missing data produces deterministic load errors.

Tests:
- Decode at least one representative stage file.
- Verify stage title/order and nested test case/step counts.

### PR 1.2 — Map DTOs to Domain Models

Proposed branch:
- `codex/e1-m1-domain-mapping`

Scope:
- Add domain models for stage, test case, test step, step type, and rule metadata.
- Map decoded DTOs into domain models.
- Create stable step identifiers from stage/test case/step content.

Validation flow:
- Given decoded JSON, domain models expose ordered stages, cases, and steps for read-only UI consumption.

Tests:
- Verify ordering survives DTO-to-domain mapping.
- Verify step identifiers are stable and unique within the loaded content.
- Verify known step types map correctly.

## Milestone 2 — Single Active Team Shell

Goal:
- Route the existing SwiftUI skeleton into one active team/session workflow while keeping future Epic 3 session-selection/team-switching surfaces inactive and available.

### PR 2.1 — Define One Active Team Context

Proposed branch:
- `codex/e1-m2-active-team-context`

Scope:
- Add a lightweight in-memory active team/session context for Epic 1.
- Keep session selector and team switching code available for future Epic work.
- Do not put session selector in the active Epic 1 tab flow.

Validation flow:
- App starts with exactly one active team context.
- The active team context can be passed to Team and Stage screens.

Tests:
- Verify active team context has stable team/session identifiers.
- Verify no multi-team selection is required for Epic 1 startup.

### PR 2.2 — Team Dashboard ViewModel

Proposed branch:
- `codex/e1-m2-team-dashboard-vm`

Scope:
- Implement `ActiveTeamDashboardViewModel`.
- Use loaded inspection content to produce stage rows.
- Show read-only initial dashboard summaries from inspection content: current stage defaults to the first stage, progress is explicitly `0%` / `Not started`, and blockers are shown as `Not evaluated` until draft state and validation exist.

Validation flow:
- Team tab displays one active team and read-only stage rows from domain content.

Tests:
- Verify dashboard rows are generated from loaded stages.
- Verify initial baseline progress/blocker labels are deterministic before edits exist.

### PR 2.3 — Connect Team View to ViewModel

Proposed branch:
- `codex/e1-m2-team-view-binding`

Scope:
- Update `ActiveTeamDashboardView` to consume the dashboard view model instead of mock arrays.
- Preserve the existing visual skeleton and design components.

Validation flow:
- Team screen still looks like the skeleton but uses domain-backed rows.

Tests:
- Add lightweight view model or snapshot-adjacent assertions where practical.

## Milestone 3 — Runtime Draft Editing Foundation

Goal:
- Introduce process-lifetime draft state after read-only content and one-team shell are stable.

Why draft state belongs here:
- The draft store is not required to decode or display inspection content.
- It becomes necessary once Stage and Step detail both need to read and update the same editable result.
- Moving it out of the first PR keeps the content foundation reviewable and avoids mixing loading, state mutation, and validation in one change.

### PR 3.1 — Step Result Model

Proposed branch:
- `codex/e1-m3-step-result-model`

Scope:
- Add `StepResult` for outcome, notes, measurement value, and evidence metadata count/status.
- Keep attachment file storage out of scope.

Validation flow:
- A result can represent untouched, passing, failing, measured, and evidence-marked states.

Tests:
- Verify default untouched result state.
- Verify result mutations produce expected values.

### PR 3.2 — In-Memory Draft Store

Proposed branch:
- `codex/e1-m3-draft-store`

Scope:
- Add runtime draft store keyed by stable `stepId`.
- Support create/read/update for `StepResult`.
- Keep state process-local only.

Validation flow:
- Editing one step result can be read back by `stepId` during the same app run.

Tests:
- Verify empty store returns default draft state.
- Verify update then read returns the edited result.
- Verify updates for one `stepId` do not affect another step.

## Milestone 4 — Validation Pipeline

Goal:
- Add validation incrementally so each rule is easy to review and test.

### PR 4.1 — Required Verdict Validation

Proposed branch:
- `codex/e1-m4-required-verdict-validation`

Scope:
- Validate that editable inspection steps have a verdict before submission.
- Return deterministic validation codes/messages.

Validation flow:
- Pending/empty verdict blocks submission.
- Pass, fail, and not-applicable verdicts satisfy the rule.

Tests:
- Verify missing verdict creates a blocker.
- Verify each valid verdict clears the blocker.

### PR 4.2 — Notes-on-Fail Validation

Proposed branch:
- `codex/e1-m4-notes-on-fail-validation`

Scope:
- Require notes when a step is failed and the rule requires fail notes.
- Keep notes optional for pass/not-applicable unless a future rule says otherwise.

Validation flow:
- Fail without notes blocks submission.
- Fail with notes clears the blocker.

Tests:
- Verify whitespace-only notes do not satisfy the rule.
- Verify notes are not required for passing results.

### PR 4.3 — Measurement Validation

Proposed branch:
- `codex/e1-m4-measurement-validation`

Scope:
- Validate measurement value presence for measurement steps.
- Validate numeric format.
- Add min/max/precision checks only when represented by domain rules.

Validation flow:
- Missing or invalid measurement blocks submission for measurement steps.
- Valid measurement clears the blocker.

Tests:
- Verify missing, non-numeric, out-of-range, and valid measurements.

### PR 4.4 — Evidence Metadata Validation

Proposed branch:
- `codex/e1-m4-evidence-validation`

Scope:
- Validate required evidence metadata using attachment count/status only.
- Do not implement camera, picker, file storage, or preview rendering.

Validation flow:
- Required evidence with no metadata blocks submission.
- Required evidence with sufficient metadata clears the blocker.

Tests:
- Verify required evidence count behavior.
- Verify optional evidence does not block submission.

### PR 4.5 — Stage Validation Summary

Proposed branch:
- `codex/e1-m4-stage-validation-summary`

Scope:
- Aggregate step validation into a stage-level summary.
- Expose blocker count and submit-enabled state.

Validation flow:
- Stage submit is enabled only when every step passes validation.

Tests:
- Verify mixed valid/invalid step results aggregate correctly.
- Verify submit enabled state is derived from validation summary.

## Milestone 5 — Stage Execution UI

Goal:
- Replace mock Stage behavior with editable, validation-aware stage execution.

### PR 5.1 — Stage Execution ViewModel Read Model

Proposed branch:
- `codex/e1-m5-stage-read-model`

Scope:
- Implement initial `StageExecutionViewModel`.
- Load selected stage and ordered steps.
- Expose row state using domain content plus draft result state.

Validation flow:
- Selected stage displays real ordered steps with current draft values.

Tests:
- Verify selected stage rows match domain ordering.
- Verify default draft results appear in row state.

### PR 5.2 — Inline Verdict and Notes Editing

Proposed branch:
- `codex/e1-m5-inline-verdict-notes`

Scope:
- Support inline verdict changes.
- Support inline notes editing.
- Update draft store through the view model.

Validation flow:
- Changing verdict/notes updates row state and validation blockers.

Tests:
- Verify verdict edits update draft state.
- Verify notes-on-fail blocker responds to notes edits.

### PR 5.3 — Inline Measurement Editing

Proposed branch:
- `codex/e1-m5-inline-measurement`

Scope:
- Support measurement value editing for measurement steps.
- Surface measurement validation state in rows.

Validation flow:
- Measurement entry updates draft state and blocker status.

Tests:
- Verify measurement edits update draft state.
- Verify invalid measurement row state includes validation feedback.

### PR 5.4 — Inline Evidence Metadata Editing

Proposed branch:
- `codex/e1-m5-inline-evidence`

Scope:
- Support evidence metadata status/count editing.
- Surface required evidence blocker status in rows.

Validation flow:
- Marking evidence metadata present clears evidence-required blockers.

Tests:
- Verify evidence metadata updates draft state.
- Verify required evidence blocker responds to metadata edits.

### PR 5.5 — Submit Gating

Proposed branch:
- `codex/e1-m5-submit-gating`

Scope:
- Disable or block Stage submit until validation passes.
- Show stage-level blocker summary.
- No permanent submission record.

Validation flow:
- Submit cannot complete while blockers exist.
- Submit-ready state is visible when blockers are resolved.

Tests:
- Verify submit-disabled state with blockers.
- Verify submit-ready state without blockers.

### PR 5.6 — Dashboard Progress and Blocker Sync

Proposed branch:
- `codex/e1-m5-dashboard-progress-blockers`

Scope:
- Replace baseline Team dashboard progress/blocker summaries with values derived from draft results and validation summaries.
- Keep calculations scoped to the one active Epic 1 team/session.

Validation flow:
- Team dashboard progress and blocker counts update after Stage draft edits change validation state.

Tests:
- Verify overall progress aggregates draft completion across stages.
- Verify open blocker count aggregates validation summaries across stages.

## Milestone 6 — Step Detail and Navigation

Goal:
- Add drill-in editing and complete expected back flows for the one-team workflow.

Back-flow decision:
- Back navigation should be completed by the end of Epic 1. The workflow includes Team -> Stage -> Step, and judges need a reliable way to return from Step to Stage and from Stage to Team while preserving process-lifetime draft edits.

### PR 6.1 — Navigation Model

Proposed branch:
- `codex/e1-m6-navigation-model`

Scope:
- Define navigation state for Team, Stage, and Step detail.
- Preserve Team and Stage as primary tabs.
- Add explicit drill-in navigation from Stage row to Step detail.
- Add back behavior for Step-to-Stage and Stage-to-Team.

Validation flow:
- User can open a stage, drill into a step, and return without losing draft edits.

Tests:
- Verify navigation state transitions for Team -> Stage -> Step -> Stage.

### PR 6.2 — Step Detail ViewModel

Proposed branch:
- `codex/e1-m6-step-detail-vm`

Scope:
- Implement `StepDetailViewModel`.
- Read and update the same draft store used by Stage.
- Expose outcome, notes, measurement, evidence metadata, and validation state for one step.

Validation flow:
- Step detail shows the current draft result for the selected step.

Tests:
- Verify Step detail reads existing draft state.
- Verify Step detail writes back to shared draft state.

### PR 6.3 — Connect Step Detail View

Proposed branch:
- `codex/e1-m6-step-detail-view-binding`

Scope:
- Update `StepOverviewView` or successor Step detail view to consume `StepDetailViewModel`.
- Preserve useful visual structure from the skeleton.

Validation flow:
- Editing in Step detail updates Stage row state after returning.

Tests:
- Verify shared draft consistency through view models.

## Milestone 7 — Epic Integration and Cleanup

Goal:
- Remove active mock dependencies and validate the complete one-team inspection loop.

### PR 7.1 — Active Flow Cleanup

Proposed branch:
- `codex/e1-m7-active-flow-cleanup`

Scope:
- Remove mock data dependencies from the active Epic 1 flow.
- Keep deferred session selector/team-switch views inactive and available for later Epics.
- Align naming and branch documentation with Epic 1.

Validation flow:
- Active app flow is domain/view-model driven.

Tests:
- Verify active flow can initialize without mock inspection arrays.

### PR 7.2 — Epic Acceptance Pass

Proposed branch:
- `codex/e1-m7-acceptance-pass`

Scope:
- Add final acceptance-level tests where practical.
- Verify process-lifetime draft behavior and relaunch reset expectation at the architecture/test level.
- Polish blocked, empty, and submit-ready states.

Validation flow:
- Complete Team -> Stage -> Step -> Stage flow works for one active team.

Tests:
- Cover the main happy path and validation-blocked path.

## Notes on the Existing UI Skeleton

Epic 1 is not a from-scratch rewrite. The current SwiftUI skeleton is the visual and navigation baseline.

Implementation approach:
- Preserve useful skeleton views and design components.
- Replace mock state with domain-backed view models in small task PRs.
- Keep future-flow UI, such as session selection and team switching, available but inactive in the Epic 1 workflow.
- Avoid deleting future-flow UI unless it directly conflicts with Epic 1 correctness.

## Follow-Up Architecture Planning

Create a separate architecture-planning chat/worktree for each Epic or major Milestone before implementation begins.

Each architecture planning pass should include:
- Architecture diagrams for the affected models, services, view models, and navigation state.
- Highlighted diffs from the previous architecture state.
- Explicit boundaries between current Epic work and deferred future Epic work.
- Test strategy notes for each planned task PR.
