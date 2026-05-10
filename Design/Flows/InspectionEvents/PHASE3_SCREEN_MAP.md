# Phase 3 Screen Map — Inspection App

Source flows: `Design/Flows/InspectionEvents/PHASE2_FLOW_SET.md`.

## Screen Inventory
| Screen ID | Name | Purpose | Entry Conditions |
|---|---|---|---|
| SC-001 | Session Selector | Select team and start/resume team session. | Event context available; team roster requested. |
| SC-002 | Active Team Dashboard | Show active team context and navigation to current stage/history/switch. | Team selected or resumed session loaded. |
| SC-003 | Stage Checklist / Execution | Execute ordered steps, view validation status, submit stage. | Active session + current stage loaded. |
| SC-004 | Step Detail — Outcome/Notes | Capture outcome and required notes for a selected step. | Step selected from stage checklist. |
| SC-005 | Step Detail — Measurement | Enter/validate measurement value for `measurement` step. | Selected step type is `measurement`. |
| SC-006 | Step Detail — Evidence | View/add/remove required or optional evidence metadata. | Selected step supports/requires evidence. |
| SC-007 | Team Switch Confirmation | Prevent data loss and confirm save-before-switch. | Judge initiates team switch with potential dirty state. |
| SC-008 | Submission History List | List immutable past submissions for team/test case. | User opens history for selected team/test case. |
| SC-009 | Submission History Detail | Show read-only stage/step outcomes, notes, evidence refs. | History record selected from SC-008. |

---

## Flow-to-Screen Matrix

### FL-001 — Session Start / Resume
1. Launch + load roster/session states → **SC-001**
2. Select team / create-or-resume session → **SC-001**
3. Enter active context → **SC-002**

Failure/Recovery states:
- Team roster unavailable/empty → **SC-001 (empty/error state)**
- Resume pointer repair fallback → **SC-002 (restored-to-nearest-valid-stage state)**

### FL-002 — Stage Execution + Submit Gating
1. Open current stage → **SC-003**
2. Open step for outcome/notes edit → **SC-004**
3. Return to stage summary + validation → **SC-003**
4. Submit stage → **SC-003 (submission attempt state)**

Failure/Recovery states:
- Missing outcome/notes rule violation → **SC-003 + SC-004 (validation error state with jump-to-step)**

### FL-003 — Measurement Entry + Correction
1. Open measurement step → **SC-005**
2. Enter value + validate format/range → **SC-005**
3. Return to stage with valid state → **SC-003**

Failure/Recovery states:
- Non-numeric/precision/range errors → **SC-005 (field validation error state)**

### FL-004 — Evidence Attach/Remove + Required-Proof Blocking
1. Open evidence step → **SC-006**
2. Attach/remove evidence metadata → **SC-006**
3. Return to stage and attempt submit → **SC-003**

Failure/Recovery states:
- Required proof missing / metadata save fail → **SC-006 (attachment error state)** and **SC-003 (submit blocked state)**

### FL-005 — Team Switch + Context Restore
1. Trigger switch from active context → **SC-002**
2. Unsaved changes prompt + confirm save/switch → **SC-007**
3. Load target team context → **SC-002**

Failure/Recovery states:
- Draft save failure or target unavailable → **SC-007 (error/retry state)** then fallback **SC-001** or remain **SC-002**

### FL-006 — Historical Submission Inspection
1. Open submission history → **SC-008**
2. Select record → **SC-009**

Failure/Recovery states:
- No records available → **SC-008 (empty state)**
- Load failure → **SC-008/SC-009 (recoverable error + retry state)**

---

## Screen State Requirements

### SC-001 Session Selector
- **loading:** fetching teams/session states.
- **empty:** no teams available for event.
- **active:** teams listed with status badges.
- **validation error:** selection/resume failure feedback.
- **persisted/restored:** resumable sessions clearly labeled.

### SC-002 Active Team Dashboard
- **loading:** restoring active team context.
- **empty:** no active session yet.
- **active:** team header, current stage, actions.
- **validation error:** resume/context restore warnings.
- **persisted/restored:** restored pointer shown after relaunch/switch.

### SC-003 Stage Checklist / Execution
- **loading:** stage steps/rules loading.
- **empty:** stage has no actionable steps.
- **active:** ordered steps + completion indicators.
- **validation error:** submit gating banner + step-level flags.
- **persisted/restored:** draft progress markers restored.

### SC-004 Step Detail — Outcome/Notes
- **loading:** step detail loading.
- **empty:** step metadata unavailable.
- **active:** outcome controls + notes input.
- **validation error:** required outcome/notes messages.
- **persisted/restored:** prior draft values shown.

### SC-005 Step Detail — Measurement
- **loading:** measurement schema loading.
- **empty:** schema unavailable.
- **active:** value input + unit guidance.
- **validation error:** format/precision/range messages.
- **persisted/restored:** last valid/draft measurement restored.

### SC-006 Step Detail — Evidence
- **loading:** attachment metadata loading.
- **empty:** no attachments yet.
- **active:** attachment list + add/remove controls.
- **validation error:** required-proof and attach/remove errors.
- **persisted/restored:** attachment metadata restored.

### SC-007 Team Switch Confirmation
- **loading:** save-before-switch operation.
- **empty:** no switch target selected.
- **active:** confirm/cancel options.
- **validation error:** draft save failure, target unavailable.
- **persisted/restored:** saved timestamp/confirmation shown.

### SC-008 Submission History List
- **loading:** history fetch in progress.
- **empty:** no historical submissions.
- **active:** timestamp-ordered list.
- **validation error:** fetch error + retry.
- **persisted/restored:** last-viewed filter/context restored.

### SC-009 Submission History Detail
- **loading:** snapshot detail loading.
- **empty:** record missing/unavailable.
- **active:** read-only outcomes/notes/evidence refs.
- **validation error:** detail load error + retry.
- **persisted/restored:** last selected record context restored.

---

## Gate C Pre-Check (Screens -> Architecture)
- Every Phase 2 flow step has a mapped screen/state target.
- Every screen defines loading/empty/active/validation/persisted-restored states.
- Screen inventory is sufficient to assign owning ViewModels in Phase 4.
