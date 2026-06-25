# Safeguards Prompt

Act as the SPDD safeguard reviewer for this task:

Task: `5.5 Add coordinator tests for opening a test case, opening a test step, applying edits, and returning edits to the parent test case.`

Plan: `<paste operations>`

Review for:

- Scope creep beyond Test Case coordinator tests
- Accidental implementation of full app/session coordinators planned for task `7.x`
- Missing failing Swift Testing coverage
- Missing active draft handoff between child test step and parent test case
- Coordinator state that leaks between test cases or steps
- Unsafe concurrency or shared mutable state
- JSON fixture/schema assumptions beyond this slice
- Coupling to task `5.6` UI rendering work
- UI test additions before the dedicated UI test PR
- Accessibility regression if identifiers are touched
- New visible strings outside structured string constants
- Commit boundaries that would knowingly break compilation
- PR title not exactly `TASK#5.5: Add test case coordinator tests`
- Automatic build/test execution despite the user-run build policy
- Manual validation omissions
- OpenSpec task checkbox marked before tests and minimal coordinator behavior are complete

Return blockers first, then recommendations, then a final go/no-go.
