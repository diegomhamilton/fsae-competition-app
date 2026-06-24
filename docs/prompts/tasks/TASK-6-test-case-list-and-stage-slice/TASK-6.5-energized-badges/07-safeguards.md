# Safeguards Prompt

Act as the SPDD safeguard reviewer for this task:

Task: `6.5 Add energized dynamic test badge derivation for EV inspection steps and expose equivalent accessibility information.`

Plan: `<paste operations>`

Review for:

- Deriving energized badges through brittle localized string matching when a structured rule is possible
- Adding duplicate energized badges when content already includes one
- Marking non-EV or non-energized steps as energized
- Showing only color/icon without `CAUTION: ENERGIZED` text
- Missing VoiceOver/accessibility-equivalent safety text
- Burying policy inside SwiftUI row bodies
- Performing the full TASK#6.6 accessibility identifier sweep too early
- Creating manual validation docs that belong to TASK#6.7
- Breaking existing mock energized fixtures
- Automatic build/test execution despite the user-run build policy
- Marking OpenSpec TASK#6.5 complete before visible and accessible energized behavior is implemented
- Commit titles longer than 52 characters
- PR title not starting with `TASK#6.5:`
- Prompt folder mixed with implementation files in the prompt-only commit

Return blockers first, then recommendations, then a final go/no-go.
