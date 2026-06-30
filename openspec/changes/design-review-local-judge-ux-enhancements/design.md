# Design

## Review Inputs

The design review must read:

- `openspec/changes/technical-inspection-event-development-plan/tasks.md`
- `openspec/changes/technical-inspection-event-development-plan/design.md`
- `docs/inspection-event/organization-plan.md`
- `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature`
- Current SwiftUI views under `Features/SessionFlow`, `Features/StageExecution`, `Features/TestCaseExecution`, and `Features/TestStepExecution`.

## Review Questions

The review should answer:

- Does the proposed Task 10 flow let a judge complete a fully local stored inspection without prototype copy or dead-end states?
- Is each screen clear about active event, team, session, stage, test case, and saved draft state?
- Are validation blockers actionable and traceable to the missing control?
- Is incomplete state visually distinct from judge-selected outcomes?
- Does evidence capture persist metadata without overcommitting to final media storage policy?
- Do rechecks and sticker eligibility preserve immutable submission history?
- Does stopwatch timing satisfy egress measurement requirements without replacing manual override?

## Output Decisions

The design review should produce decisions for:

- Navigation and context hierarchy.
- Validation focus behavior.
- Pending versus incomplete outcome semantics.
- Notes and evidence label vocabulary.
- Evidence metadata storage boundaries.
- Recheck item lifecycle and review policy.
- Sticker eligibility calculation inputs.
- Stopwatch timing model and accessibility announcements.

## Acceptance Gate

Task 10 implementation may begin only after the design review states:

- Approved scope for the UX foundation slice.
- Approved scope for completion enhancements.
- Known deferrals and storage-policy limits.
- Required tests and manual validation commands.

