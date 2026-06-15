---
name: Judge
domain: inspection-event
status: active
priority: primary
role: technical inspection judge
---

# Judge Persona

## Context

The judge runs inspections for multiple FSAE EV teams during a busy event. They need fast session selection, clear active team context, reliable offline inspection content, validation that prevents incomplete submissions, and accessible controls that work under time pressure.

## Goals

- Start or resume the correct team inspection session.
- Inspect stages, test cases, and test steps in official order.
- Record outcomes, notes, measurements, and evidence metadata without losing draft work.
- Submit only valid stages and understand blockers quickly.
- Review rechecks and confirm sticker eligibility with confidence.

## Priority Scenarios

- Start a new inspection session.
- Resume an in-progress inspection session.
- Submit a completed stage.
- Block submission when a required outcome, notes, measurement, or evidence is missing.
- Switch teams while preserving draft isolation.
- Review and accept corrected rechecks.
- Complete the flow with VoiceOver and stable identifiers.

## Testing Lens

- Positive paths should prove efficient completion.
- Negative paths should prove blockers are explicit and navigable.
- Edge paths should prove no team draft leakage, no partial corrupted content, and no inaccessible critical action.

## Documentation Lens

Explain workflows in terms of judge decisions: what the judge sees, what they can do next, what is blocked, and what evidence proves the state.
