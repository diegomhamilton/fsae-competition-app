# TASK#10.4 SPDD Prompt Run

Task: `10.4 Add a local team catalog and no-default-mock production launch. A user can create a team entry with display name and car number, and MockInspectionData.teams remains available only for tests, previews, or explicit debug fixtures.`

Purpose: replace user-facing seeded teams with a local judge-created team catalog while preserving mock teams for tests, previews, and debug fixtures.

Branch: `codex/task-10-4-local-team-catalog`

Expected PR title: `TASK#10.4: Local Team Catalog`

Run prompts in this order:

1. Requirements: read common instructions, OpenSpec tasks/design, `.feature` scenarios for team roster/session start, and current session/store/view files.
2. Entities: identify team model, catalog persistence, session selector state, app factory, preview/test fixture boundaries, and accessibility identifiers.
3. Approach: add failing tests first for empty production catalog, created team persistence, display-name/car-number field identity, car number validation, and mock-team confinement.
4. Structure: keep catalog state in Models/Services/Store, team creation intent in coordinators, and SwiftUI entry in `SessionSelectorView`.
5. Operations: implement, validate with `xcodebuild`, update OpenSpec checkbox, commit, push, and open a draft PR automatically.
6. Norms: preserve Swift 6 concurrency, structured `Strings` enums, stable identifiers, and Judge-first manual validation notes.
7. Safeguards: do not seed production teams, do not remove mock fixtures from tests/previews, and do not combine TASK#10.5 behavior.

Agent/skill/tool mapping: use `../common-instructions.md`.

Validation:

- User can create a team with display name and car number.
- Use distinct values such as display name `Solar Hawks` and car number `42`, then confirm `displayName == Solar Hawks`, `carNumber == 42`, the session row displays both in the intended places, and persisted catalog JSON keeps the fields separate.
- A clean production launch starts with an empty team catalog.
- `MockInspectionData.teams` is referenced only from tests, previews, or explicit debug fixtures.
- Manual validation maps to `Start a new inspection session for a team` and `Resumable sessions are clearly identified`.
