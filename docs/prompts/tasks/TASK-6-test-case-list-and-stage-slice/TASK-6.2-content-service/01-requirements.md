# Requirements Prompt

You are helping with SPDD for this task:

Task: `6.2 Implement InspectionContentService as an async service that loads the six bundled inspection JSON resources.`

Describe the essence of the requirement in one clear sentence.

Then list:

- User-visible outcome for a judge opening official offline inspection content
- Acceptance source, especially `inspection-event-json-content` and `inspection-event-execution`
- Required behavior
- Out of scope behavior
- Completion signal

Keep this focused on what must be true, not how to build it.

Context:

- Branch: `codex/task-6.2-content-service`
- Expected PR title: `TASK#6.2: Add content service`
- This task depends on TASK#6.1 stage-content tests.
- The service must load Garage, Body, Chassis, EV, Egress, and Rain stage JSON resources in official display order.
- The service must fail with typed errors for missing, malformed, or unsupported bundled content rather than presenting partial corrupted official content.
- Do not implement the test case list view, `FullStageView`, energized badge derivation, structured view strings, accessibility identifiers, or manual validation docs in this task.
- Do not build automatically. The user owns build and validation unless explicitly requested.
