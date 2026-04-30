# BACKLOG (RESET BASELINE)

## Purpose
This backlog is reset to a clean baseline focused on rebuilding product planning in the right order:
1) user stories,
2) flows,
3) screens,
4) architecture,
5) implementation.

## Feature analysis from previous backlog (what we keep)
The prior backlog contained 7 meaningful product capabilities. These are retained, but reordered by dependency and product value:

1. **Inspection integrity core** (from B-002)
   - Explicit outcomes (`pass/fail/skip`), notes policy, submit gating, and stage persistence.
2. **Step-type completeness** (from F-000)
   - Full `measurement` and `evidence` support in data, UI, and persistence.
3. **Evidence attachments** (from F-001/F-002)
   - Attach files to steps and enforce required evidence by rule.
4. **Session scale-up** (from F-004)
   - Multi-team session handling on one device.
5. **Inspection history** (from F-003)
   - Historical submissions per test case.
6. **In-stage speed improvements** (from B-001/E-001)
   - Auto-scroll + jump-to-next-unfilled navigation.
7. **Stability/testing foundation** (cross-cutting)
   - Swift Testing coverage and schema regression checks for every major feature.

---

## Planning-first roadmap (new)

### P0 — Product Design Inputs (must complete before implementation-heavy work)
- **P0.1 User stories baseline**
  - Write canonical stories for judge, reviewer, and admin personas.
  - Define acceptance outcomes per story.
- **P0.2 Flow map baseline**
  - Convert stories into end-to-end flows (happy path + error paths).
- **P0.3 Screen inventory baseline**
  - Derive screen list from flows with ownership per flow step.
- **P0.4 Architecture baseline (MVVM SwiftUI)**
  - Define domain boundaries, state ownership, and persistence contracts.

### P1 — Core inspection correctness
- **P1.1 Outcome/notes enforcement + submit gating** (formerly B-002 core)
- **P1.2 Stage persistence hardening + regression tests**

### P2 — Step-type migration completion
- **P2.1 Measurement support end-to-end**
- **P2.2 Evidence step support end-to-end**
- **P2.3 Type-specific validation test pack**

### P3 — Evidence and attachments
- **P3.1 Step-level attachments**
- **P3.2 Required evidence-by-rule enforcement**

### P4 — Multi-team and historical context
- **P4.1 Multi-team session switching**
- **P4.2 Test-case submission history timeline**

### P5 — Workflow acceleration
- **P5.1 Auto-scroll after result**
- **P5.2 Jump-to-next-unfilled controls**

---

## Dependency order (reset)
- P0 -> P1 -> P2 -> P3 -> P4 -> P5
- P3 depends on P2.
- P4 depends on stable P1 persistence contracts.
- P5 should be implemented after P1 to avoid rework in stage navigation behavior.

---

## Rules of execution
1. Every implementation item must reference at least one user story from P0.1.
2. Every item must include flow impact (which flow + step changes).
3. Every item must include screen impact (which screen states change).
4. Every item must include architecture impact (ViewModel/service/model/persistence).
5. Swift Testing coverage is required for any domain or persistence change.
