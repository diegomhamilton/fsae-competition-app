# Structure Prompt

Given this task and approach:

Task: `5.3 Implement test case models and draft state composition from test step drafts.`

Approach: `<paste approach>`

Define the implementation structure.

Include:

- Models, draft types, fixtures, and tests involved
- Dependencies between `InspectionTestCase`, ordered `InspectionTestStep` values, and step draft state
- Suggested commit boundaries
- Risks from coupling test case progress to validation behavior too early
- How this task fits into the current OpenSpec Test Case Slice

Prefer the existing MVC + Coordinators + Services architecture while keeping this task in the model layer.

Commit rule:

Each commit title must be 52 characters or fewer and must not intentionally leave the project in a non-compiling state at commit boundaries.

Expected PR title:

`TASK#5.3: Implement test case models`

Build policy:

Do not build automatically. The user owns build and validation unless they explicitly ask Codex to run it.
