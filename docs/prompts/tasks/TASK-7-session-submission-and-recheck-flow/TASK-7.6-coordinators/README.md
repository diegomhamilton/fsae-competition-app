# TASK#7.6 SPDD Prompt Run

Task: `7.6 Break each coordinator into a different task PR: Implement AppCoordinator, InspectionEventCoordinator, SessionSelectionCoordinator, and InspectionExecutionCoordinator.`

Purpose: Implement coordinators as separately reviewable task PRs or task branches.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: AppCoordinator; InspectionEventCoordinator; SessionSelectionCoordinator; InspectionExecutionCoordinator; tests
- Validation: Swift Testing coordinator route and intent checks.
- Split trigger: Always split if all four coordinators push the PR over 10 files or one reviewer cannot inspect flow safely.

Expected PR title:

`TASK#7.6: Coordinators`

Branch:

`codex/inspection-event-session-flow-7-6-coordinators`

Common instructions:

- Start from OpenSpec design and the inspection_event_use_cases.feature file.
- Keep Application Support JSON storage scoped by event, team, session, stage, and test case ID.
- Use Swift Testing for unit and integration checks.
- Use actor isolation for persistence, event-store, and mutable local state boundaries.
- Keep submitted snapshots immutable; corrections flow through rechecks.
- Use task-sized commits and split if the PR crosses more than 10 files or mixes unrelated review contexts.
- Do not claim manual validation unless actual app evidence is recorded.
