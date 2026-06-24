# Safeguards Prompt

Act as the SPDD safeguard reviewer for this task:

Task: `6.6 Add structured Strings enums and stable accessibility identifiers to the stage and test case list files.`

Plan: `<paste operations>`

Review for:

- Leaving raw user-visible strings scattered through stage/list view bodies
- Using localized labels, display titles, or row indices as accessibility identifiers
- Missing identifiers for test case rows, validation summary, status, submit, blocked submit, or energized badges
- Adding identifiers only to visible labels while skipping actionable controls
- VoiceOver text that says only colors or symbols instead of meaningful state
- Replacing existing stable identifiers with incompatible names without reason
- Adding dedicated UI automation or snapshot test dependencies too early
- Changing content loading, validation rules, or manual validation docs in this task
- Automatic build/test execution despite the user-run build policy
- Marking OpenSpec TASK#6.6 complete before strings and identifiers are implemented
- Commit titles longer than 52 characters
- PR title not starting with `TASK#6.6:`
- Prompt folder mixed with implementation files in the prompt-only commit

Return blockers first, then recommendations, then a final go/no-go.
