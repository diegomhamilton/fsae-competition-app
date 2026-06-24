# Approach Prompt

Given the requirements and entities for this task:

Task: `7.12 Manually validate start, resume after app relaunch, submit, blocked submit, team switch, recheck, sticker eligibility, per-test-case JSON files, and team submission folders against the .feature file.`

Propose an approach that keeps the PR reviewable.

Include:

- The smallest useful implementation or documentation slice
- Test-first steps using Swift Testing where code behavior is involved
- Dedicated UI automation only when this task is part of TASK#8
- Manual validation ownership and evidence to capture
- How the work maps back to the feature scenarios or OpenSpec specs
- What remains out of scope for a follow-up PR
- When to split into a task branch

Preferred operation:

Prepare and run manual validation for the full local session, submission, recheck, sticker, and JSON-folder workflow.

Validation expectation:

User-run app evidence only; static review can prepare checklist.

Split trigger:

Keep as documentation/validation PR if implementation evidence is not available.

Do not build automatically unless explicitly asked.
