# TASK#7 Common Instructions

Use these instructions across every TASK#7 operation prompt.

- Start from OpenSpec design and `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature`.
- Keep Application Support JSON storage scoped by event, team, session, stage, and test case ID.
- Persist each in-progress test case as its own JSON draft file.
- Treat an existing `InspectionEventStore` as incomplete until app coordinators and SwiftUI views are linked to it for draft save/restore.
- Keep the first store/coordinator/view integration PR focused on draft save/restore; exclude stage submission wiring from that PR.
- Keep submitted snapshots immutable and grouped in a team-specific folder.
- Treat TASK#7.10, TASK#7.11, and TASK#7.12 as Tentpole 2 continuation work, not Task 7 foundation work.
- Use actor isolation for persistence and event-store mutation.
- Treat successful signposts as intervals unless the implementation adds explicit success events for point-in-time queries.
- Add failing tests before implementation for coordinators, persistence, store behavior, and submissions. Recheck and sticker eligibility tests belong to Tentpole 2.
- Keep SwiftUI views small and coordinator-backed; do not move flow logic into views.
- Record PR descriptions with `Summary`, `Scope`, `Notes`, and `Validation`.
- Prefer task-sized commits. Split into task branches if a PR crosses more than 10 files or mixes high-complexity contexts.
- Do not mark TASK#7.12 complete without actual manual validation evidence, and track that validation under Tentpole 2.
