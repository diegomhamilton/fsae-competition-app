# Approach Prompt

Given the requirements and entities for this task:

Task: `10.3 Refactor judge navigation so Sessions, Team, and Stage are the top-level landmarks, remove the standalone Case tab, and make Stage contain the case UI with dominant next-action and focused one-step editing.`

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

Implement the guided navigation refactor from `Design/Flows/InspectionEvents/JUDGE_NAVIGATION_FLOW_PROPOSAL.md`, keeping `Sessions`, `Team`, and `Stage` as top-level landmarks while Stage owns case-level execution UI.

Validation expectation:

Swift Testing for route transitions plus manual checks for one-step cases, multi-step cases, relaunch restore, empty states, and VoiceOver.

Split trigger:

Split if route model changes and Stage/Case UI composition cannot be reviewed together.

Do not build automatically unless explicitly asked.
