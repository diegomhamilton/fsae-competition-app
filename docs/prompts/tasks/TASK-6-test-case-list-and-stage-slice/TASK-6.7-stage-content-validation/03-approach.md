# Approach Prompt

Given the requirements and entities for this task:

Task: `6.7 Manually validate Garage, EV, Egress, and Rain stage content against Design/Resources/InspectionEvent/*.json.`

Propose a manual-validation approach.

Include:

- How to confirm prerequisites from TASK#6.1 through TASK#6.6
- How to compare visible app content to bundled JSON source files
- How to cover positive, negative, and edge cases from the `.feature` file
- How to capture validation notes without claiming results that were not observed
- How to distinguish source-review checks from app-run checks
- How to prepare a PR validation note with `Summary`, `Scope`, `Notes`, and `Validation`

Preferred direction:

- Create a checklist that can be filled by the user after building/running locally.
- Include exact observed-result fields for each stage.
- Include a "not run" state when actual app validation is unavailable.
- Keep the task documentation-only until the user provides actual app evidence.

Do not build automatically. Name the exact user-run build or inspection signal the user should report back.
