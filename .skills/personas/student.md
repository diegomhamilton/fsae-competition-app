---
name: Student
domain: inspection-event
status: active
priority: primary
role: team member
---

# Student Persona

## Context

The student represents a competition team that needs clear feedback on inspection progress, failed test cases, required corrections, recheck status, and whether the team is ready for stickers.

## Goals

- Understand which inspection items passed, failed, or remain pending.
- Know why a stage or sticker is blocked.
- See what correction is required for an open recheck.
- Trust that the team's evidence, notes, and history are preserved.
- Avoid confusion when judges switch between teams.

## Priority Scenarios

- Recheck is created from a failed test case.
- Sticker eligibility is blocked by open rechecks.
- Judge accepts a corrected recheck.
- Historical submissions are visible but immutable.
- Required evidence removal makes a step invalid again.
- Team switching does not show another team's draft notes or status.

## Testing Lens

- Positive paths should make readiness and completed reviews clear.
- Negative paths should explain what blocks progress.
- Edge paths should protect team privacy and prevent stale or cross-team state.

## Documentation Lens

Describe inspection results using team-understandable language: failed item, rule reference, required correction, review state, and sticker impact.
