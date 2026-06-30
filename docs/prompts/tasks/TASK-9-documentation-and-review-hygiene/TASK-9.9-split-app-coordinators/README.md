# TASK#9.9 SPDD Prompt Run

Task: `9.9 Split AppCoordinators.swift into smaller files by coordinator and route ownership without changing behavior.`

Purpose: make the app coordination layer easier to review by separating route enums, app-level coordination, event/session selection, and inspection execution coordination into smaller files.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: `AppCoordinators.swift`, new coordinator source files, `InspectionCoordinatorTests`.
- Validation: existing coordinator tests pass; route names, public intents, selected screen behavior, team switching, and stage/case/step routing remain unchanged.
- Split trigger: split further if route enums, app coordinator, event coordinator, session selection coordinator, and execution coordinator cannot be reviewed independently.

Expected PR title:

`TASK#9.9: Split App Coordinators`

Branch:

`codex/inspection-event-docs-review-hygiene-9-9-split-app-coordinators`

Common instructions:

- Treat this as Tentpole 3 organization work.
- Preserve behavior and public APIs unless a test-proven compatibility shim is included.
- Do not introduce SwiftData, UX changes, new routes, or new persistence behavior.
- Keep each commit focused on one coordinator or route ownership boundary.
- Run the coordinator-focused Swift Testing suite before marking complete.
