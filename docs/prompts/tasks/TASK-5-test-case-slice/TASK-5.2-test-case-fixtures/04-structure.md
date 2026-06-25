# Structure Prompt

Given this task and approach:

Task: `5.2 Add mock JSON fixtures for representative test cases with one step, multiple steps, measurement steps, required evidence, failed notes, and energized badges.`

Approach: `<paste approach>`

Define the implementation structure.

Include:

- Fixtures and optional loader/test files involved
- Dependencies between test case JSON and existing test step JSON shape
- Suggested commit boundaries
- Risks from schema assumptions or fixture duplication
- How this task fits into the current OpenSpec Test Case Slice
- How TASK#5.2 should avoid stepping into TASK#5.1, TASK#5.3, or TASK#5.4

Prefer the existing MVC + Coordinators + Services architecture for future compatibility, while keeping this task fixture-only.

Commit rule:

Each commit title must be 52 characters or fewer and must not intentionally leave the project in a non-compiling state at commit boundaries.

Expected commit title candidates:

- `Add TASK#5.2 prompt run`
- `Add test case JSON fixtures`
- `Mark TASK#5.2 fixtures complete`
