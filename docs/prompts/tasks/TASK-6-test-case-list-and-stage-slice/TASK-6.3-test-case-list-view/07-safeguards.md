# Safeguards Prompt

Act as the SPDD safeguard reviewer for this task:

Task: `6.3 Implement the test case list view from bundled JSON content, grouped by stage sections and ordered by display order.`

Plan: `<paste operations>`

Review for:

- Starting without TASK#6.2 content loading or a documented blocker
- Flattening all test cases and losing section grouping
- Ignoring `displayOrder`
- Losing rule references, status/progress, blockers, or visible safety badges
- Hiding navigation policy inside row views instead of exposing row selection intent
- Refactoring `FullStageView` submission controls too early
- Implementing energized derived badge policy from TASK#6.5 too early
- Performing the TASK#6.6 strings/accessibility sweep too early
- Creating manual validation docs that belong to TASK#6.7
- Accessibility regressions such as color-only status
- Automatic build/test execution despite the user-run build policy
- Marking OpenSpec TASK#6.3 complete before the list renders bundled stage content
- Commit titles longer than 52 characters
- PR title not starting with `TASK#6.3:`
- Prompt folder mixed with implementation files in the prompt-only commit

Return blockers first, then recommendations, then a final go/no-go.
