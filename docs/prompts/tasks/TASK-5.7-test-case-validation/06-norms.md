# Norms Prompt

Apply the project norms to this task:

Task: `5.7 Manually validate the Test Case view with mock JSONs and record positive, negative, and edge cases from the .feature file.`

Check the proposed work against these norms:

- Manual validation evidence must map back to the `.feature` file
- Positive, negative, and edge cases must be explicitly labeled
- Stable accessibility identifiers must be checked separately from localized labels where the UI exposes them
- Energized safety badges must have visible and VoiceOver-equivalent signals
- Ordered step display must be checked against fixture order
- Missing outcomes, failed-note requirements, invalid measurements, and missing evidence must remain validation blockers
- PR titles must start with `TASK#5.7:`
- Each task must be split into reviewable commits with commit titles of 52 characters or fewer
- Commits must not intentionally leave the project in a non-compiling state
- Do not build the code automatically; capture build and validation as user-run unless the user explicitly asks the agent to build
- A checklist alone is not completion of OpenSpec TASK#5.7

Return any adjustments needed before implementation.

Expected PR title:

`TASK#5.7: Validate test case view`

Recommended commit title candidates:

- `Add TASK#5.7 prompt run`
- `Add test case validation checklist`

