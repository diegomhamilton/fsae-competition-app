# Phase 4 MVVM Blueprint — Inspection App

Sources:
- `Design/UserStories/InspectionEvents/PHASE1_STORY_CATALOG.md`
- `Design/Flows/InspectionEvents/PHASE2_FLOW_SET.md`
- `Design/Flows/InspectionEvents/PHASE3_SCREEN_MAP.md`

## 1) Domain Model Map

## Core Entities

### InspectionSession
- `id: UUID`
- `eventId: String`
- `teamId: String`
- `status: SessionStatus` (`not_started | in_progress | submitted`)
- `currentStageId: String?`
- `currentStepId: String?`
- `updatedAt: Date`
- `version: Int` (for migration compatibility)

### Stage
- `id: String`
- `sessionId: UUID`
- `name: String`
- `order: Int`
- `status: StageStatus` (`not_started | in_progress | submitted`)
- `steps: [TestStep]`
- `validationSummary: ValidationSummary`

### TestCase
- `id: String`
- `eventId: String`
- `name: String`
- `stageIds: [String]`

### TestStep
- `id: String`
- `stageId: String`
- `title: String`
- `type: StepType` (`outcome | measurement | evidence`)
- `rules: StepRules`

### StepResult
- `stepId: String`
- `outcome: StepOutcome?` (`pass | fail | n_a`)
- `notes: String?`
- `measurementValue: Decimal?`
- `attachments: [Attachment]`
- `updatedAt: Date`

### Attachment
- `id: UUID`
- `stepId: String`
- `kind: AttachmentKind` (`photo | doc | other`)
- `displayName: String`
- `storageRef: String`
- `createdAt: Date`

## Supporting Types
- `StepRules`:
  - `requiresOutcome: Bool`
  - `requiresNotesOnFail: Bool`
  - `measurementConfig: MeasurementConfig?`
  - `evidenceRequired: Bool`
  - `minAttachmentCount: Int`
- `MeasurementConfig`:
  - `unit: String`
  - `precision: Int`
  - `minValue: Decimal?`
  - `maxValue: Decimal?`
- `ValidationSummary`:
  - `isValid: Bool`
  - `errors: [ValidationError]`
- `ValidationError`:
  - `stepId: String`
  - `code: String`
  - `message: String`

---

## 2) ViewModel Responsibilities by Screen

| Screen ID | ViewModel | Responsibilities | Inputs | Outputs |
|---|---|---|---|---|
| SC-001 | `SessionSelectorViewModel` | Load teams/session states; create/resume session. | eventId | team list, session status badges, load errors |
| SC-002 | `ActiveTeamDashboardViewModel` | Show active context; navigate to stage/history/switch; restore pointer. | sessionId | context header, action intents, restore warnings |
| SC-003 | `StageChecklistViewModel` | Load ordered steps; track completion; run submit gating. | sessionId, stageId | step rows, validation banner, submit enabled state |
| SC-004 | `OutcomeStepViewModel` | Edit outcome/notes and enforce notes-on-fail rule. | stepId | field states, inline validation, saved draft state |
| SC-005 | `MeasurementStepViewModel` | Validate measurement format/range/precision. | stepId | parsed value, field errors, validity state |
| SC-006 | `EvidenceStepViewModel` | Manage attachments, required-proof status. | stepId | attachment list, add/remove results, evidence validity |
| SC-007 | `TeamSwitchViewModel` | Confirm switch, persist draft, resolve failures. | sourceSessionId, targetTeamId | confirm state, save progress, switch result/error |
| SC-008 | `HistoryListViewModel` | Load immutable submission list. | teamId, testCaseId | history rows, empty state, load error |
| SC-009 | `HistoryDetailViewModel` | Load read-only snapshot detail. | submissionId | immutable stage/step detail, retry state |

---

## 3) Service Layer Contracts

### SessionPersistenceService
- `loadSessionIndex(eventId) -> [SessionSummary]`
- `createSession(eventId, teamId) -> InspectionSession`
- `loadSession(sessionId) -> InspectionSession`
- `saveDraft(sessionId, DraftPayload) -> Void`
- `restoreContext(sessionId) -> RestoredContext`
- `switchTeam(sourceSessionId, targetTeamId) -> InspectionSession`

### ValidationService
- `validateStep(step: TestStep, result: StepResult) -> [ValidationError]`
- `validateStage(stage: Stage, results: [StepResult]) -> ValidationSummary`
- `canSubmit(stageId, sessionId) -> Bool`

### AttachmentService
- `addAttachment(stepId, localRef, kind) -> Attachment`
- `removeAttachment(attachmentId) -> Void`
- `listAttachments(stepId) -> [Attachment]`
- `resolvePreview(attachmentId) -> PreviewDescriptor`

### SubmissionHistoryService
- `listSubmissions(teamId, testCaseId) -> [SubmissionSummary]`
- `getSubmissionDetail(submissionId) -> SubmissionSnapshot`

---

## 4) Validation Pipeline Design

Order of validation on submit:
1. **Outcome required rule**
   - If `requiresOutcome == true`, `StepResult.outcome` must exist.
2. **Notes required rule**
   - If `outcome == fail` and `requiresNotesOnFail == true`, notes must be non-empty.
3. **Evidence required rule**
   - If `evidenceRequired == true`, attachment count must satisfy `minAttachmentCount` (default >= 1).
4. **Measurement format/range rule**
   - For `measurement` steps, validate numeric parse, precision, and min/max range.
5. Aggregate into `ValidationSummary` and gate submission on `isValid == true`.

Error handling conventions:
- Step-level errors for field highlights.
- Stage-level summary banner for submit failures.
- Deterministic error codes for analytics and localization.

---

## 5) Storage & Migration Strategy (Step-Type Evolution)

### Storage Shape
- Persist normalized tables/collections:
  - `sessions`
  - `stages`
  - `steps`
  - `step_results`
  - `attachments`
  - `submission_snapshots`
- Include `schemaVersion` globally and `version` per session.

### Migration Rules
- Use additive migrations for new step fields/types.
- On read, apply compatibility adapters:
  - missing `measurementConfig` -> treat as no-range/no-precision constraints.
  - missing `evidenceRequired` -> default false.
- For incompatible changes, mark affected session as `needs_repair` and route to safe recovery path before edit.

### Integrity Guarantees
- Team isolation key on all mutable records (`eventId + teamId + sessionId`).
- Snapshot immutability for submitted history records.
- Idempotent draft saves to prevent switch/relaunch data loss.

---

## 6) Gate D Checklist (Architecture -> Implementation)
- Model contracts defined for `InspectionSession`, `Stage`, `TestCase`, `TestStep`, `StepResult`, `Attachment`.
- ViewModel ownership defined for every Phase 3 screen (`SC-001`..`SC-009`).
- Service contracts defined for persistence, validation, attachments, and history.
- Validation order and failure surfaces frozen.
- Storage and migration strategy defined for step-type evolution.
