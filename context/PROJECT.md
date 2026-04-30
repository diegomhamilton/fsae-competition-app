# PROJECT — FSAE Inspection Checklist iOS App (Reset Planning Baseline)

## Product goal
Build a reliable iOS inspection workflow for Formula SAE judges that is deterministic, fast in the field, and resilient across relaunches.

## Scope baseline
- Stage-based inspections with explicit step outcomes.
- Notes, measurement, and evidence capture with rule-based validation.
- Per-team persistence and later multi-team management.
- Historical traceability of submissions.

## Planning strategy (from reset)
We are restarting planning from first principles and will deliver in this order:
1. **User Stories** (behavior contracts)
2. **Flows** (path + validation logic)
3. **Screens** (flow-driven screen/state map)
4. **Architecture** (MVVM contracts ready for implementation)

## Source of truth
- Backlog reset and feature sequencing: `context/BACKLOG.md`
- End-to-end planning execution plan: `context/DESIGN_PLAN.md`

## Constraints
- Do not start UI mockups before stories/flows are stable.
- Do not lock architecture before screen/state mapping exists.
- Every implementation item must trace back to a story, flow, and architecture contract.
