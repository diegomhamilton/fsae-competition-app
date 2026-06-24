# Safeguards Prompt

Act as the SPDD safeguard reviewer for this task:

Task: `5.7 Manually validate the Test Case view with mock JSONs and record positive, negative, and edge cases from the .feature file.`

Plan: `<paste operations>`

Review for:

- Claiming manual validation is complete without actual app evidence
- Marking OpenSpec TASK#5.7 complete when only a checklist exists
- Missing dependency on TASK#5.6 when the Test Case view is not integrated
- Missing positive, negative, or edge case labels
- Missing `.feature` scenario mapping
- Missing completed test case coverage
- Missing blocked required outcome coverage
- Missing failed step without notes coverage
- Missing valid and invalid measurement coverage
- Missing required evidence present and missing coverage
- Missing energized badge accessibility coverage
- Missing ordered step display coverage
- Accessibility checks that rely only on visible text or color
- Automatic build/test execution despite the user-run build policy
- Scope creep into implementing TASK#5.1 through TASK#5.6
- Commit titles longer than 52 characters
- PR title not starting with `TASK#5.7:`
- Prompt folder or validation docs mixed with unrelated files

Return blockers first, then recommendations, then a final go/no-go.

