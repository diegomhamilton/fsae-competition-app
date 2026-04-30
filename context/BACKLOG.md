# BACKLOG

## Estimation model
- 1 session (2h) = **XS**
- 2 sessions (4h) = **S**
- 4 sessions (8h) = **M**
- 8 sessions (16h) = **L**
- 10 sessions (20h) = **XL**

## Working agreement for every task
1. Define and document **test scenarios** first.
2. Define explicit **acceptance criteria** before implementation.
3. Implement and run **Swift Testing unit tests** before/alongside code changes.
4. Keep tasks small enough for parallel Codex agents when possible.

---

## Bugs

### B-001 Auto-scroll after setting result at bottom of stage screen
- **Description:** When a judge assigns a result to a test case near the bottom of the screen, the app should automatically scroll so the next actionable item is visible.
- **Current status:** Reported.
- **Primary areas:** `ActiveSessionView`, `InspectionStageView`, stage view models, scroll-state coordination.
- **Acceptance criteria:**
  - After submitting a result, the next unfilled test case is visible without manual scroll.
  - Behavior is deterministic for both pass and fail outcomes.
  - No jump/scroll jitter when keyboard or notes UI is active.
- **Test scenarios to document before implementation:**
  - Submit result on last fully visible row.
  - Submit result on partially visible row.
  - Submit result with notes expanded.
- **Estimate:** **S** (2 sessions).
- **Parallelization:**
  - Can run in parallel with tasks that only touch seed data/model definitions.
  - Potential conflict with enhancement E-001 if both change stage scrolling/navigation logic.

### B-002 Enforce step outcomes + notes policy + stage persistence
- **Description:** Validate and close gaps against `Design/UserStories/InspectionEvents/FSAEJudgeInspectionEvents.md`, specifically: (a) each test step must always get an assertion outcome (**pass/fail/skip**) and notes when required; (b) stage submission must persist for the current team.
- **Current status:** Incomplete and partially ambiguous in current backlog.
- **Acceptance criteria:**
  - Every step in active flow can be explicitly marked as `pass`, `fail`, or `skip` (no silent/unset completion).
  - Notes are enforced whenever the configured step/test rule marks notes as required.
  - Stage submission persists and is reloadable for the same team session after app relaunch.
- **Test scenarios to document before implementation:**
  - Mark all step outcomes: pass, fail, skip.
  - Required-note validation on fail/skip (or rules-driven requirement).
  - Persist + reload stage result for same team.
- **Estimate:** **S** (2 sessions): 1 session analysis/spec + 1 session implementation gap(s) and tests.
- **Parallelization:**
  - Can run in parallel with UI polish not touching step-result schema.
  - Conflict risk with tasks changing `TestStep`/`TestCaseResult` enums and submission flow.
- **Implementation kickoff (start now):**
  - **B-002.1 Outcome state enforcement (XS, 1 session):**
    - Normalize result state so each step must be explicitly `pass`/`fail`/`skip` before completion.
    - Add validation gate to block stage submit when unresolved outcomes exist.
  - **B-002.2 Notes requirement enforcement (XS, 1 session):**
    - Enforce notes-required rule (rule-driven) during submit and inline row validation.
    - Keep scope independent from `measurement`/`evidence` handling (out of scope here).
  - **B-002.3 Stage persistence hardening (XS, 1 session):**
    - Ensure persisted stage submission status and reload behavior are deterministic after relaunch.
    - Add regression checks for same-team reload semantics only.
  - **B-002.4 Swift Testing coverage + acceptance verification (S, 2 sessions):**
    - Unit tests for outcome completeness checks.
    - Unit tests for required-note validation.
    - Unit tests for stage persistence/load round-trip.
  - **Potential conflicts to flag while developing B-002:**
    - `TestStep` / `TestCaseResult` enums or schema updates from other agents can break validation assumptions.
    - `InspectionSessionService` persistence refactors can invalidate round-trip tests.
    - `ActiveSessionView` submit-flow edits can create merge conflicts in gating logic.

---

## Features

### F-000 Step-type migration completion (Phase 2A/2B + UI/result support)
- **Description:** Complete and track the remaining work from `implementation_plans/Active/STEP_TYPE_MIGRATION_PLAN.md` so `measurement` and `evidence` types are fully supported end-to-end.
- **Why now:** This is a blocker for attachment features and currently only partially tracked in roadmap notes, not as an explicit backlog execution item.
- **Dependencies:** None (foundational), but should finish before F-001/F-002.
- **Acceptance criteria:**
  - Phase 2A validation is completed and documented (sequential behavior verified after measurement promotions).
  - Phase 2B evidence promotions are completed with conversion summary per seed file.
  - UI supports `measurement` and `evidence` step rendering in active stage flow.
  - Result capture supports structured measurement values and evidence metadata persistence contracts.
  - Swift Testing coverage exists for seed decode + submit gating behavior with these new types.
- **Test scenarios to document before implementation:**
  - Decode all seed files after Phase 2A/2B with strict step typing enabled.
  - Execute a stage containing `measurement` step(s) and submit valid/invalid values.
  - Execute a stage containing `evidence` step(s) with and without required proof artifacts.
  - Relaunch app and verify stored measurement/evidence payloads reload for same team.
- **Estimate:** **L** (8 sessions), split into two waves:
  - **F-000.1 Phase 2A validation closure (S, 2 sessions)**
  - **F-000.2 Phase 2B promotions + UI/result support starter (M, 4 sessions)**
  - **F-000.3 Swift Testing + persistence regression pack (S, 2 sessions)**
- **Parallelization:**
  - Can run in parallel with B-001/B-002 if model contracts are frozen before merge.
  - Should not run in parallel with F-001 model/schema changes unless one owner controls `TestStep`/result schema.

### F-004 Multi-team session management on one device
- **Description:** Add explicit workflow for handling multiple teams on the same device (session list/switcher + active session selection).
- **Dependencies:** B-002 (stage result persistence correctness).
- **Acceptance criteria:**
  - Judge can create, view, and switch between multiple team sessions.
  - Active team context is clearly visible in main workflow.
  - Switching teams does not overwrite or hide persisted results from other teams.
  - Session list supports at least basic ordering/filtering (e.g., most recent first).
- **Test scenarios to document before implementation:**
  - Create two+ team sessions and switch between them.
  - Submit results in Team A, switch to Team B, confirm isolation.
  - Relaunch app and confirm previously active session restoration behavior.
- **Estimate:** **M** (4 sessions).
- **Parallelization:**
  - Can run in parallel with attachment-focused work (F-001/F-002) if session service API contracts are versioned/frozen.
  - Conflict risk with broad navigation shell refactors or changes to root session-loading logic.

### F-001 Add attachments at step level (images/documents)
- **Description:** Allow judges to add evidence attachments to a test step.
- **Dependencies:** Completion of step-type validation and UI handling (`measurement` + `evidence`) from roadmap.
- **Acceptance criteria:**
  - Judge can attach image/document from camera, photo library, or files.
  - Attachment metadata persists with the test step result.
  - Errors (permissions/cancelled import) handled gracefully.
- **Test scenarios to document before implementation:**
  - Camera flow success/failure.
  - Files import success/unsupported file.
  - Attachment persistence after app relaunch.
- **Estimate:** **L** (8 sessions).
- **Parallelization:**
  - Split across agents:
    - Agent A: storage/service layer and models.
    - Agent B: picker UI integration.
    - Agent C: Swift Testing coverage.
  - Conflict risk on shared step result model and session service files.

### F-002 Required attachments by step rule
- **Description:** Some steps require at least one evidence file before submission.
- **Dependencies:** F-001.
- **Acceptance criteria:**
  - Submission is blocked if required attachment is missing.
  - Clear inline validation message shown.
  - Rule is data-driven from step configuration.
- **Test scenarios to document before implementation:**
  - Required attachment missing.
  - Required attachment present.
  - Optional attachment step still submittable without evidence.
- **Estimate:** **M** (4 sessions).
- **Parallelization:**
  - Parallelizable with non-overlapping UI polish tasks.
  - High conflict if concurrent with broad submission-flow refactors.

### F-003 Test case details history of past submissions
- **Description:** Show historical submissions/discussion trail for each test case.
- **Dependencies:** Stable result persistence schema.
- **Acceptance criteria:**
  - Judge can open a test case and see ordered history entries.
  - Each entry includes timestamp, outcome, notes, and evidence references.
  - Handles empty history state.
- **Test scenarios to document before implementation:**
  - Empty history.
  - Single prior submission.
  - Multiple submissions sorted newest/oldest as defined.
- **Estimate:** **M** (4 sessions).
- **Parallelization:**
  - Can run in parallel with F-002 if API/model contracts are frozen.
  - Conflict risk on persistence schema migrations.

---

## Enhancements

### E-001 Jump to next unfilled test case (up/down floating arrow)
- **Description:** While scrolling, display directional controls to jump directly to the nearest unfilled test case.
- **Acceptance criteria:**
  - Up/down controls appear contextually.
  - Tap navigates to closest unfilled test case in selected direction.
  - Control hides/disables when no target exists.
- **Test scenarios to document before implementation:**
  - Middle of list with unfilled above and below.
  - At top with only below target.
  - At bottom with only above target.
  - All test cases filled.
- **Estimate:** **S** (2 sessions).
- **Parallelization:**
  - Should not be parallelized with B-001 unless one agent owns shared scroll coordinator.
  - Safe in parallel with backend/model work.

---

## Dependency map (explicit)
- **B-001:** none.
- **B-002:** none.
- **F-000:** none (foundational; recommended before F-001/F-002).
- **E-001:** soft dependency on B-001 scroll coordinator decisions (to avoid duplicate logic).
- **F-001:** depends on F-000 completion.
- **F-002:** depends on F-001.
- **F-003:** depends on stable persistence schema (recommended after B-002 stage persistence validation).
- **F-004:** depends on B-002.

---

## Suggested execution waves (parallel-friendly)

### Wave 1 (immediate)
- B-002.1 + B-002.2 (outcome + notes enforcement)
- B-001 (auto-scroll)

### Wave 1.5
- B-002.3 + B-002.4 (persistence hardening + Swift Testing coverage)

### Wave 2
- E-001 (jump arrows)
- F-000.1 (Phase 2A validation closure)

### Wave 3
- F-000.2 + F-000.3 (Phase 2B promotions, UI/result support, Swift Testing pack)
- F-001 (attachments foundation)
- F-004 (multi-team session management), once B-002 is accepted

### Wave 4
- F-002 (required attachment rules)
- F-003 (history view), if persistence contract stable

---

## Notes to keep in context
- `context/` contains the core planning and backlog files to start new flows quickly.
- For every new implementation task: write Swift Testing unit tests and document scenarios + acceptance criteria first.
