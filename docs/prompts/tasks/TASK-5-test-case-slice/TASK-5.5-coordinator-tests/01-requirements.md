# Requirements Prompt

You are helping with SPDD for this task:

Task: `5.5 Add coordinator tests for opening a test case, opening a test step, applying edits, and returning edits to the parent test case.`

Describe the essence of the requirement in one clear sentence.

Then list:

- User-visible outcome for a judge moving from a stage/list context into a test case and test step
- Acceptance source, especially `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature` and the scenarios `Open test case from stage` and `Open test step from test case` from the OpenSpec execution spec
- Required coordinator behavior
- Required test coverage using Swift Testing
- Active draft handoff behavior between parent test case and child test step
- Out of scope behavior
- Completion signal

Keep this focused on what must be true, not how to build it.

Context:

- The task belongs to the Test Case Slice.
- Keep the scope to opening a test case from a stage/list context, opening a test step from that test case, applying draft edits, and returning the edited draft to the parent test case.
- If production coordinator types do not exist yet, add only the smallest testable coordinator or coordinator contract needed for this slice.
- Do not implement full app/session coordinators planned for task `7.x`.
- Do not add UI tests; the UI test PR is later.
- Do not build automatically.
