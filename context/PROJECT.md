# PROJECT — FSAE Inspection Checklist iOS App

## 1) Current App Definition (Session 1 Refined Brief)

### Problem
Formula SAE judges need a reliable, fast, and structured way to record technical inspection outcomes on-site without losing data, skipping required checks, or creating inconsistent submissions across teams and stages.

### Target Users
1. **Primary:** Formula SAE judges/inspectors (alumni, sponsors, engineers, managers).
2. **Secondary:** Team-side reviewers (captains/members) who may need visibility into outcomes.
3. **Future:** Event admins/organizers managing cross-team workflows and ranking.

### Core Value
Deliver a deterministic inspection workflow that enforces required step outcomes and notes, persists stage results per team, and reduces judge friction during live inspections.

### Core Features (Current + Near-Term)
1. **Stage-based inspection execution** with active-session flow and sequential step completion.
2. **Outcome capture + validation** (pass/fail/skip, required notes policies).
3. **Reliable persistence** for sessions/stage submissions across app relaunches.
4. **Seeded inspection templates** (garage/body/chassis/EV/egress/rain).
5. **Roadmap-ready extensibility** for measurement/evidence steps and attachments.

### Success Metrics (to baseline in future sessions)
- Stage completion time per team.
- Validation error rate (missing outcomes/notes) before submit.
- Data-loss incidents after relaunch (target: zero).
- Judge actions per completed test case (efficiency proxy).

---

## 2) Repository-Informed Current State

### Implemented Foundations
- SwiftUI app with screens for active session, stage inspection, and test case details.
- ViewModel + service layers for inspection sessions and result handling.
- Seed JSON templates for six inspection stages.
- Unit-test coverage exists for seed and session services.
- Sequential inspection behavior has been implemented (per planning/backlog docs).

### In-Progress / Open Roadmap Items
- Measurement step handling in UI/result capture is not complete.
- Evidence/attachment step handling is not complete.
- Required-attachment validation is not implemented.
- Test-case historical submission trail is not implemented.
- Multi-team session management UX is not implemented.

---

## 3) Gap Analysis (Session 1)

### Product Definition Gaps
- Persona #3 was undefined in original file; now framed as event admin/organizer.
- No explicit non-goals/scope boundaries were documented.
- No metric baselines/targets were defined.
- No constraints section existed (offline mode, device sharing, data retention, etc.).

### Execution/Delivery Gaps
- BACKLOG requires scenario and acceptance definition before implementation; this discipline is documented but needs consistent enforcement per task kickoff.
- Dependency-sensitive workstreams (B-001/B-002/E-001/F-001/F-004) risk merge conflicts without contract freezing.
- Step-type migration has unfinished validation and unimplemented measurement/evidence UI.

### UX/Workflow Risk Gaps
- Auto-scroll and jump-navigation could conflict if implemented independently.
- Notes-required policy semantics may vary by rule (fail/skip vs fully rule-driven), needs explicit decision lock.
- Team-switching and active-context clarity will become high-risk once multi-team support starts.

---

## 4) Risks (Session 1)

1. **Data integrity risk:** incomplete enforcement of explicit step outcomes/notes can allow ambiguous stage results.
2. **Persistence risk:** stage submission state can drift unless B-002.3 hardening is completed and regression-tested.
3. **Model migration risk:** ongoing step-type normalization can break UI assumptions if model contracts keep changing.
4. **Concurrency risk:** parallel agent work may collide on shared files (session service, step/result enums, submit flow).
5. **Scope creep risk:** attachments/evidence/measurement can expand rapidly without bounded acceptance criteria.

---

## 5) Key Questions for Next Sessions

1. Should notes be required strictly by configured rule only, or always on fail/skip by default when rule data is absent?
2. What is the canonical submit gate for a stage: all steps resolved, all required notes present, and (future) required evidence present?
3. For multi-team support, what should be restored on relaunch: last active team only, or last team + last stage position?
4. What minimal metadata is required for historical submissions (author, timestamp, device, evidence refs)?
5. What offline/retention policy is expected before server integration (local-only duration, export requirements)?

---

## 6) Session Sequencing Alignment (MULTI_SESSION_SYSTEM)

### Session 1 Deliverables (this document)
- Refined brief: complete.
- Gaps + risks: complete.
- Key questions: complete.

### Explicit Deferrals (per instruction)
- No UI design decisions yet.
- No architecture design decisions yet.

---

## 7) Original Workflow Skeleton (retained for continuity)

1. App definition
2. Personas
3. User stories
4. Gap analysis
5. Wireframes
6. UI mockups
7. Review
8. Prototype (optional)
9. Development prep

Common mistakes to avoid:
- Starting with UI too early
- Too many features too early
- Ignoring edge cases
- Designing for internal assumptions only
- Skipping iteration and validation


## 8) Backlog Integration + Task Start Plan (Immediate)

### What is now fully integrated from BACKLOG
- **B-002** is the immediate quality gate for reliable inspection behavior (explicit outcomes, notes-required enforcement, stage persistence).
- **F-000** is the explicit migration epic that closes unfinished `measurement`/`evidence` support before attachment features.
- **F-001/F-002** remain blocked by F-000 completion; **F-004** depends on B-002 stability.

### How to start tasks now (no UI/architecture design yet)
1. **Kick off B-002.1 (Outcome state enforcement)**
   - Document test scenarios + acceptance checklist directly in task notes/PR body.
   - Implement submit-gate validation for unresolved outcomes (`pass/fail/skip` required per step).
   - Add Swift Testing unit coverage for unresolved-outcome blocking.
2. **Then B-002.2 (Notes-required enforcement)**
   - Lock rule-driven notes requirement semantics.
   - Add inline + submit-time validation tests.
3. **Then B-002.3/B-002.4 (Persistence + regression tests)**
   - Verify same-team stage persistence after relaunch with deterministic reload behavior.
4. **Start F-000 only after B-002 baseline is green**
   - Execute **F-000.1** first (Phase 2A validation closure).
   - Continue to **F-000.2** (Phase 2B promotions + minimal UI/result wiring).
   - Finish with **F-000.3** regression pack.

### Definition of Ready (DoR) for each task start
- Test scenarios written first.
- Acceptance criteria restated in implementation PR.
- File ownership/risk note for shared contracts (`TestStep`, result schema, session persistence).
- Swift Testing plan included before coding begins.

### Recommended first implementation slice
- **Start with B-002.1 in the next coding session** because it has smallest scope, unblocks deterministic submit gating, and reduces migration ambiguity before F-000.

---
