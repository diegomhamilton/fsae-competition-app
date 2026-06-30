# TASK#7 Common Instructions

Use these instructions across every TASK#7 operation prompt.

- Start from OpenSpec design and `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature`.
- Keep Application Support JSON storage scoped by event, team, session, stage, and test case ID.
- Persist each in-progress test case as its own JSON draft file.
- Treat an existing `InspectionEventStore` as incomplete until app coordinators and SwiftUI views are linked to it for draft save/restore.
- Keep the first store/coordinator/view integration PR focused on draft save/restore; exclude stage submission wiring from that PR.
- Keep submitted snapshots immutable and grouped in a team-specific folder.
- Use actor isolation for persistence and event-store mutation.
- Treat successful signposts as intervals unless the implementation adds explicit success events for point-in-time queries.
- Add failing tests before implementation for coordinators, persistence, store behavior, submissions, rechecks, and sticker eligibility.
- Keep SwiftUI views small and coordinator-backed; do not move flow logic into views.
- Record PR descriptions with `Summary`, `Scope`, `Notes`, and `Validation`.
- Prefer task-sized commits. Split into task branches if a PR crosses more than 10 files or mixes high-complexity contexts.
- Do not mark TASK#7.12 complete without actual manual validation evidence.
