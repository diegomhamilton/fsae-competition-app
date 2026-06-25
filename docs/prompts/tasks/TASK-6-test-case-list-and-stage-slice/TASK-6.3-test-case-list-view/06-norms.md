# Norms Prompt

Apply the project norms to this task:

Task: `6.3 Implement the test case list view from bundled JSON content, grouped by stage sections and ordered by display order.`

Check the proposed work against these norms:

- SwiftUI views with small local UI state only
- Reuse existing design system and skeleton patterns
- TDD for extracted view helpers
- Feature scenarios as acceptance backbone
- Bundled JSON is the official offline source of truth
- Non-color status cues for progress, blockers, and badges
- Strings and accessibility identifiers must not be made worse, but the full cleanup belongs to TASK#6.6
- Row selection should expose coordinator-ready intent instead of burying navigation logic in rows
- Branch name is `codex/task-6.3-test-case-list-view`
- PR titles must start with `TASK#{TASK NUMBER}:`, using `TASK#6.3: Add test case list view`
- Commit titles must be 52 characters or fewer
- Do not build automatically; capture build and validation as user-run unless explicitly asked

Return any adjustments needed before implementation.

Expected PR title:

`TASK#6.3: Add test case list view`

Recommended commit title candidates:

- `Add TASK#6.3 prompt run`
- `Add test case list view`
- `Render sectioned test cases`
