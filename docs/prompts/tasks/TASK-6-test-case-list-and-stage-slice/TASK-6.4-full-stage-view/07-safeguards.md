# Safeguards Prompt

Act as the SPDD safeguard reviewer for this task:

Task: `6.4 Refactor FullStageView to render real stage content, stage progress, validation blockers, and submit controls from model state.`

Plan: `<paste operations>`

Review for:

- Rendering mock stage arrays instead of JSON-backed stage content
- Reimplementing validation rules inside `FullStageView`
- Allowing submit when required outcomes, failed notes, measurements, or evidence are invalid
- Losing first-invalid routing data
- Burying navigation or submit policy inside row views
- Rewriting unrelated session, recheck, or sticker flow
- Implementing energized derived badge policy from TASK#6.5 too early
- Performing the TASK#6.6 strings/accessibility sweep too early
- Creating manual validation docs that belong to TASK#6.7
- Color-only progress or blocked-submit state
- Automatic build/test execution despite the user-run build policy
- Marking OpenSpec TASK#6.4 complete before real stage content, progress, blockers, and submit controls are wired
- Commit titles longer than 52 characters
- PR title not starting with `TASK#6.4:`
- Prompt folder mixed with implementation files in the prompt-only commit

Return blockers first, then recommendations, then a final go/no-go.
