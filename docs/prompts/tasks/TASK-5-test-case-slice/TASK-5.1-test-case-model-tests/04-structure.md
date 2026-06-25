# Structure Prompt

Given this task and approach:

Task: `5.1 Add failing unit tests for InspectionTestCase, ordered steps, rule references, draft aggregation, blocker counts, and test case progress.`

Approach: `<paste approach>`

Define the implementation structure.

Include:

- Tests involved
- Any tiny test-only helper fixtures involved
- Production models, coordinators, services, fixtures, or views intentionally not changed
- Dependencies between existing step model types and planned test case model expectations
- Suggested commit boundaries
- Risks from failing-test commits and project compile policy
- How this task fits into the current OpenSpec Test Case Slice

Preferred structure:

- Add or extend a Swift Testing test file in the existing unit test target.
- Keep helper data local to the test file when practical.
- Reference planned type and API names clearly enough for TASK#5.3 and TASK#5.4 to implement.
- Use feature scenario names in test names or nearby comments where practical.

Commit rule:

Each commit title must be 52 characters or fewer.

Recommended commit title candidates:

- `Add TASK#5.1 prompt run`
- `Add test case model tests`
- `Add failing test case tests`

Compilation policy note:

This task explicitly asks for failing tests. If the repository policy forbids committing non-compiling code, prefer tests that compile but fail at runtime against stubbed expectations only if that can be done without production changes. If that is not possible without production model implementation, report the tension clearly before committing implementation edits.
