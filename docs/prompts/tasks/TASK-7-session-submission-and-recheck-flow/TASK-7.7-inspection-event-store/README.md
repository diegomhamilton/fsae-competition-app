# TASK#7.7 SPDD Prompt Run

Task: `7.7 Verify or implement InspectionEventStore as an actor-isolated event/session source of truth with scoped queries by event, team, session, user access, and the JSON file persistence service.`

Purpose: Verify or implement actor-isolated InspectionEventStore with scoped event/team/session/user queries backed by persistence. If the store already exists, focus on missing APIs/tests needed by coordinator/view draft save/restore.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: InspectionEventStore; query models; store tests
- Validation: Swift Testing for scoped queries, access isolation, async mutation behavior, and explicit success events if success must be queried outside signpost intervals.
- Split trigger: Split from coordinators if store APIs are still changing.

Expected PR title:

`TASK#7.7: Inspection Event Store`

Branch:

`codex/inspection-event-session-flow-7-7-inspection-event-store`

Common instructions:

- Start from OpenSpec design and the inspection_event_use_cases.feature file.
- Keep Application Support JSON storage scoped by event, team, session, stage, and test case ID.
- Use Swift Testing for unit and integration checks.
- Use actor isolation for persistence, event-store, and mutable local state boundaries.
- Treat successful signposts as intervals unless explicit success events are added.
- Keep submitted snapshots immutable; corrections flow through rechecks.
- Use task-sized commits and split if the PR crosses more than 10 files or mixes unrelated review contexts.
- Do not claim manual validation unless actual app evidence is recorded.
