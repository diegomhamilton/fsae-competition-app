# Approach Prompt

Given the requirements and entities for this task:

Task: `6.1 Add failing unit tests for InspectionStage, InspectionSection, bundled JSON decoding, display ordering, stable IDs, unsupported step type errors, and malformed JSON failures.`

Propose a test-first approach.

Include:

- How to read existing model tests before adding new tests
- How to keep this task test-only
- How to choose focused unit test names that map to `.feature` scenarios or OpenSpec requirements
- How to cover bundled JSON without adding the production service in this task
- How to represent malformed JSON and unsupported step type cases in tests
- How to make failures useful for TASK#6.2 implementation
- How to avoid duplicating the later view, accessibility, and manual validation work from TASK#6.3 through TASK#6.7

Preferred direction:

- Add a new Swift Testing file such as `InspectionStageContentTests.swift`.
- Use representative bundled JSON resources to define the official ordering contract.
- Use small inline decoder inputs or test fixtures for malformed JSON and unsupported step type failures.
- Assert stable IDs and order through model-level APIs, not SwiftUI views.
- Expect the tests to fail until `InspectionStage`, `InspectionSection`, and decoding/error behavior are implemented.

Do not build automatically. Name the exact command the user can run when they are ready to verify the failing-test checkpoint.
