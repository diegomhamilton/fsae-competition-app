# Project Roadmap:

* Milestone 1: Improve inspection feature
* Milestone 2: Integrate server database (written in Swift or Python)
* Milestone 3: Implement roles: judges, teams and competitors
* Milestone 4: Integrate dynamic events and ranking system
* Milestone 5: Integrate static events
* Milestone 6: Implement file submission feature

## Future goals:
* Milestone 7: Chat feature?

## Current focus (selected next task)

**Selected task:** Review steps and type of steps for each test case.

Why this next:
- It is the first unchecked dependency in the "Improve inspection feature" stream.
- Clarifying step types first will make attachments and required-attachment validation easier to implement next.

Initial implementation checklist:
- [x] Inventory current step types used by each inspection test case.
- [x] Propose normalized step type definitions and required fields.
- [x] Map old step types to normalized ones (breaking migration completed in seed data).
- [ ] Validate the new step model against sequential view behavior.
- [x] Remove legacy compatibility layer and enforce strict v2 step type decoding.
- [ ] Add `measurement` + `evidence` type handling in UI and result capture.

Reference: See `STEP_TYPE_MIGRATION_PLAN.md` for migration phases, mapping rules, and rollout strategy.

## Improve inspection feature

- [x] Implement sequential view in inspection stage: no need for user to click in test case to see it's details. One active test case should be displayed in stage list, user can still access the test case details: Automatically go to next step when submit result; Animate test step transition.
- [ ] Review steps and type of steps for each test case
- [ ] Add attachments to the step: images, documents.
- [ ] Gallery, files or camera
- [ ] Add required attachments to step
- [ ] Implement test case details history of past submissions
