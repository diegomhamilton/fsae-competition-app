# SPDD Steps 1-3: Tentpole Entities

Task: identify the entities involved in the persistence, UX, and code organization tentpoles before any implementation.

## Current Domain Entities

### InspectionEventDefinition

- Responsibility: identifies an inspection event and its stage IDs.
- State: `id`, `name`, `stageIDs`.
- Type: immutable event definition.
- Current source: `InspectionEventStore.swift`.

### InspectionEventTeamRecord

- Responsibility: store-facing team record scoped to an event.
- State: `id`, `eventID`, `displayName`, `carNumber`.
- Type: mutable operational/session lookup data.
- Current source: `InspectionEventStore.swift`.
- Contract gap: coexists with `InspectionTeam` whose `id` is `Int`; future persistence should standardize on `String` IDs.

### InspectionTeam

- Responsibility: current UI-facing team row/state.
- State: `id`, `school`, `carNumber`, `status`, `currentStage`, `lastSaved`.
- Type: UI/session display model, still partly mock-backed.
- Current source: `InspectionModels.swift`.

### InspectionSessionRecord

- Responsibility: store-facing session record.
- State: `id`, `eventID`, `teamID`, `judgeUserID`, `status`, `currentStageID`, `startedAt`, `lastSavedAt`.
- Type: mutable session state.
- Current source: `InspectionEventStore.swift`.

### InspectionSessionContext

- Responsibility: coordinator-facing active session context.
- State: `eventID`, `sessionID`, `team`, `activeStageID`, `hasUnsavedDraft`.
- Type: UI/coordinator state.
- Current source: `AppCoordinators.swift`.
- Contract gap: does not yet derive entirely from the store/session record.

### InspectionStage and InspectionSection

- Responsibility: official offline inspection content grouped by stage and section.
- State: stable IDs, titles, display order, ordered test cases.
- Type: immutable content decoded from bundled JSON.
- Current source: `InspectionModels.swift`.

### InspectionTestCase

- Responsibility: official test case content and ordered steps.
- State: ID, code, title, rule references, safety badges, ordered steps.
- Type: immutable content.
- Current source: `InspectionTestCaseModels.swift`.

### InspectionTestStep

- Responsibility: official step content and validation-relevant rules.
- State: ID, code, title, type, required outcome, notes/evidence/measurement policy, safety badges.
- Type: immutable content.
- Current source: `InspectionTestStepModels.swift`.

### TestCaseDraft and TestStepDraft

- Responsibility: mutable in-progress answers for one test case and its steps.
- State: outcome, notes, measurement input/value, evidence metadata.
- Type: mutable draft state; persisted as one JSON file per test case.
- Current source: `InspectionTestCaseModels.swift`.

### TestCaseDraftFile

- Responsibility: persisted JSON envelope for a draft.
- State: schema version, event/team/session/stage/test case IDs, updated timestamp, draft payload, validation summary, recheck references.
- Type: durable local persistence record.
- Current source: `TestCaseJSONPersistenceService.swift`.

### SubmittedTestCaseSnapshotFile and SubmittedStageSnapshotFile

- Responsibility: immutable submitted review history.
- State: submission IDs, submitted timestamp, test case/stage payloads, validation summaries, recheck references.
- Type: immutable historical snapshot.
- Current source: `TestCaseJSONPersistenceService.swift` and `SubmissionSnapshotService.swift`.

### InspectionEventStore

- Responsibility: actor-isolated event/session source of truth and scoped persistence facade.
- State: events, teams, sessions, persistence service.
- Type: actor-isolated service state.
- Current source: `InspectionEventStore.swift`.

### TestCaseJSONPersistenceService

- Responsibility: actor-isolated Application Support JSON persistence for drafts and submissions.
- State: root URL, schema version, file/folder layout.
- Type: actor-isolated service.
- Current source: `TestCaseJSONPersistenceService.swift`.

### SubmissionSnapshotService

- Responsibility: creates immutable stage/test case submissions and prevents duplicate submission IDs.
- Type: actor-isolated service.
- Current source: `SubmissionSnapshotService.swift`.

## Missing or Underspecified Entities

### Judge

- Responsibility: local judge identity, permissions, and review attribution.
- Proposed state: `judgeID`, display name, role, credential source, permitted event/team IDs, recheck review policy.
- Relationship: owns or starts sessions; approves submissions/rechecks/requests.

### Member

- Responsibility: team or event participant identity when needed for ESO, driver, captain, professor, or evidence attribution.
- Proposed state: `memberID`, `teamID`, name, role, optional competition credentials.
- Relationship: belongs to Team; may appear in inspection context or evidence metadata.

### InspectionWorkspace

- Responsibility: explicit local workspace for an event/team/session grouping.
- Proposed state: `workspaceID`, `eventID`, content version, active judge ID, last opened session/team.
- Relationship: groups sessions and submissions for an event and team.

### SubmissionRecord

- Responsibility: queryable operational representation of submitted stage/test case snapshots.
- Proposed state: `submissionID`, session/team/stage IDs, submittedAt, snapshot reference, immutable flag, content version.
- Relationship: generated from a session; source for history and rechecks.

### Request / RecheckRequest

- Responsibility: formal review item for failed test case, exception, approval, or correction request.
- Proposed state: `requestID`, type, status, source submission/test case/step IDs, openedBy, reviewedBy, timestamps, notes.
- Relationship: references immutable submission; closes through accepted review or exception policy.

### StickerEligibilityRecord

- Responsibility: derived team eligibility based on required stage submissions and open rechecks.
- Proposed state: team/session IDs, submitted stages, open request IDs, status, computedAt.
- Relationship: derived from submissions and recheck requests.

## UX Entities

### Sessions Tab

- Responsibility: choose/start/resume team sessions.
- Current files: `ContentView.swift`, `SessionSelectorView.swift`, `AppCoordinators.swift`.
- Contract: top-level tab remains.

### Team Tab

- Responsibility: show active team, stage list, switch team, submission/history entry points.
- Current files: `ActiveTeamDashboardView.swift`, `TeamSwitchConfirmationView.swift`.
- Contract: top-level tab remains.

### Stage Tab

- Responsibility: operational cockpit for stage progress, test cases, blockers, and submission.
- Current files: `FullStageView.swift`, `FullStageViewState.swift`, `StageChecklistView.swift`.
- Contract: top-level tab remains and becomes primary work surface.

### Case Route

- Responsibility: contextual case detail/editor opened from Stage.
- Current files: `TestCaseView.swift`, `InspectionTestCaseViewState.swift`, `TestCaseCoordinator.swift`.
- Contract: should be hidden from top-level tabs but retained as internal route/drill-in.

### Step Route

- Responsibility: optional focused step detail/editor.
- Current files: `StepOverviewView.swift`, `InspectionTestStepModels.swift`.
- Contract: should be hidden from top-level tabs and consume the same draft source as Stage/Case.

## Code Organization Entities

### App

- Owns bootstrap, root composition, dependency wiring, and top-level navigation.

### Common

- Owns UI primitives, accessibility identifiers, shared visual components, and cross-feature helpers.

### InspectionContent

- Owns official bundled JSON content models and content loading service.

### SessionFlow

- Owns login mock, session selector, active session context, team switching, and coordinators.

### StageExecution

- Owns stage view state, stage view, blocker aggregation, and submit readiness.

### TestCaseExecution

- Owns case draft composition, case view state, case view, and step handoff within a case.

### TestStepExecution

- Owns focused step editing and step detail presentation.

### Validation

- Owns canonical validation rules and deterministic validation issue codes.

### Persistence

- Owns Application Support JSON persistence today and the future SwiftData/ModelActor boundary.

### Submission

- Owns immutable snapshot creation and historical submission records.

### Rechecks and Stickers

- Own future TASK 7.10 and 7.11 behavior.
