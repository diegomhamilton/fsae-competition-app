# Structure Prompt

Given this task and approach:

Task: `5.7 Manually validate the Test Case view with mock JSONs and record positive, negative, and edge cases from the .feature file.`

Approach: `<paste approach>`

Define the validation artifact structure.

Include:

- Source files and fixtures to inspect before validation
- Checklist sections for positive, negative, and edge cases
- Mapping from each checklist item to `.feature` rule or scenario
- Evidence fields to capture for each manual run
- PR validation-note draft structure
- Suggested commit boundaries
- Risks from validating before TASK#5.6 is merged
- How this task fits into the Test Case Slice

Prefer a documentation/checklist artifact when live validation cannot be performed.

Commit rule:

Each commit title must be 52 characters or fewer and must not intentionally leave the project in a non-compiling state. Candidate titles:

- `Add TASK#5.7 prompt run`
- `Add test case validation checklist`

