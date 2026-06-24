# Approach Prompt

Given this task and entities:

Task: `5.7 Manually validate the Test Case view with mock JSONs and record positive, negative, and edge cases from the .feature file.`

Entities: `<paste entity summary>`

Propose a high-level validation approach.

Include:

- Files or areas likely read for context
- How to confirm whether TASK#5.6 is integrated on the active branch
- Mock JSON fixtures needed for representative test cases
- Feature scenarios to map into positive, negative, and edge cases
- Accessibility checks for energized badge, validation summary, ordered steps, and actionable controls
- PR validation-note format
- Manual validation path

Do not write code yet. Explain the validation shape and collaboration points.

Required case coverage:

- Completed test case
- Missing required outcome
- Failed step without notes
- Valid measurement
- Invalid measurement
- Required evidence present
- Required evidence missing
- Energized badge accessibility
- Ordered step display

Constraints:

- Do not build automatically; user owns builds and manual app validation unless they explicitly ask Codex to run them.
- If actual manual app validation cannot be performed, prepare a ready-to-run checklist and PR validation-note draft, and clearly state that validation is not complete.
- If the Test Case view is only available on a task branch and not on `develop`, base the checklist on the expected integrated TASK#5.6 branch and note that dependency.

