# DESIGN PLAN — From Reset Backlog to Build-Ready App

## Objective
Deliver a planning sequence that ends with:
- validated **user stories**,
- end-to-end **flows**,
- complete **screen map**,
- implementation-ready **MVVM architecture**.

## Source feature analysis (from current BACKLOG)
The reset backlog clusters product scope into six capabilities:
1. Inspection correctness.
2. Step-type completeness (`measurement`, `evidence`).
3. Evidence attachments and required-proof rules.
4. Multi-team session management.
5. Submission history visibility.
6. In-stage speed/navigation improvements.

These capabilities are sequenced so product contracts are stable before UI and architecture hardening.

---

## Phase plan

### Phase 1 — User Stories (Output: story catalog)
**Goal:** Define behavior contracts before screens or implementation details.

**Deliverables**
- Persona set: Judge (primary), Team Reviewer (secondary), Event Admin (future).
- Story catalog with IDs (`US-001...`) containing:
  - actor,
  - trigger,
  - expected outcome,
  - acceptance criteria,
  - data requirements.

**Must-cover story groups**
- Start/select team inspection session.
- Complete stage with required outcomes/notes.
- Enter measurement values.
- Attach and validate evidence.
- Resume after relaunch.
- Switch teams safely.
- Review historical submissions.

### Phase 2 — Flows (Output: flow set + edge paths)
**Goal:** Convert stories into deterministic navigation and validation paths.

**Deliverables**
- Flow list (`FL-001...`) mapped to story IDs.
- For each flow:
  - preconditions,
  - happy path steps,
  - validation failures,
  - recovery path,
  - completion condition.

**Required flows**
- Session start/resume.
- Stage execution with submit gating.
- Measurement entry and correction.
- Evidence attach/remove and required-proof blocking.
- Team switch and context restore.
- Test-case history inspection.

### Phase 3 — Screens (Output: screen inventory + mapping)
**Goal:** Produce a complete screen/state map derived from flows.

**Deliverables**
- Screen inventory (`SC-001...`) with purpose and entry conditions.
- Flow-to-screen matrix (which flow step lands on which screen/state).
- State requirements per screen:
  - loading,
  - empty,
  - active,
  - validation error,
  - persisted/restored.

**Expected core screens**
- Session list/selector.
- Active team dashboard.
- Stage checklist/execution.
- Step detail (notes/measurement/evidence).
- Attachment picker/preview states.
- Test-case history view.

### Phase 4 — Architecture (Output: MVVM blueprint)
**Goal:** Lock implementation contracts after stories/flows/screens are stable.

**Deliverables**
- Domain model map:
  - `InspectionSession`, `Stage`, `TestCase`, `TestStep`, `StepResult`, `Attachment`.
- ViewModel responsibilities by screen.
- Service layer contracts:
  - session persistence,
  - submission validation,
  - attachment storage metadata.
- Validation pipeline design:
  - outcome required,
  - notes rule required,
  - evidence required,
  - measurement format/range.
- Storage/migration strategy for step-type evolution.

---

## Readiness gates between phases
- **Gate A (Stories -> Flows):** every high-priority capability has at least one approved user story.
- **Gate B (Flows -> Screens):** every flow has happy + failure paths and completion conditions.
- **Gate C (Screens -> Architecture):** every screen has explicit state definitions and owning ViewModel.
- **Gate D (Architecture -> Implementation):** contracts frozen for models, validation, and persistence APIs.

---

## Implementation kickoff after planning completes
1. Build P1 core correctness first.
2. Add P2 step-type completeness.
3. Add P3 attachments + required-proof rules.
4. Add P4 multi-team + history.
5. Finish with P5 speed enhancements.

This order minimizes rework and migration risk while keeping validation integrity central.
