# Approach Prompt

Given this task and entities:

Task: `5.2 Add mock JSON fixtures for representative test cases with one step, multiple steps, measurement steps, required evidence, failed notes, and energized badges.`

Entities: `<paste entity summary>`

Propose a high-level implementation approach.

Include:

- Files or areas likely affected
- Test-first or fixture-first strategy for a fixture-only task
- Existing patterns to follow from `MockInspectionTestSteps/*.json` and `MockInspectionTestStepFixtureLoader.swift`
- Swift 6 / Concurrency considerations if a loader is touched
- Accessibility and localization considerations
- Manual validation path
- Collaboration points with TASK#5.1 and TASK#5.3

Do not write code yet. Explain the solution shape and collaboration points.

Constraints:

- Prefer a dedicated fixture folder such as `MockInspectionTestCases` if it fits existing patterns.
- Keep fixtures decodable by future `InspectionTestCase` work without forcing production decoding now.
- Include stable IDs, display order, title, rule references, and ordered steps in every test case fixture.
- Use representative steps that match existing `InspectionTestStep` JSON field names.
- Do not build automatically. The user owns build and validation unless explicitly requested.
