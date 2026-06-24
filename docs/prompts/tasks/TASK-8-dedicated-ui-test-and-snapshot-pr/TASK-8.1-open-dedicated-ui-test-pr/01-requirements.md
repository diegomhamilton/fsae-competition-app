# Requirements Prompt

You are helping with SPDD for this task:

Task: `8.1 Open a dedicated UI test PR after accessibility identifiers and stable navigation hooks exist.`

Describe the essence of the requirement in one clear sentence.

Then list:

- User-visible or reviewer-visible outcome
- Acceptance source, especially `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature` when relevant
- Required behavior
- Out of scope behavior
- Completion signal
- PR review risk if this task grows too broad

Keep this focused on what must be true, not how to build it.

Context:

- Macro-task: TASK#8 Dedicated UI Test and Snapshot PR
- Subtask: TASK#8.1
- Expected PR title: `TASK#8.1: Open Dedicated UI Test PR`
- Feature branch: `codex/inspection-event-ui-tests`
- Suggested task branch: `codex/inspection-event-ui-tests-8-1-open-dedicated-ui-test-pr`
- Operation summary: Open the dedicated UI automation and snapshot PR only after stable accessibility and navigation prerequisites exist.
- Likely files or targets: PR description; prompt docs; prerequisite checklist
- Validation: Static prerequisite review against TASK#6 and TASK#7 outputs.
- Split trigger: Split if prerequisites are incomplete and require implementation fixes.
- Common instructions:
- Start only after accessibility identifiers and stable navigation hooks exist.
- Keep UI automation in a dedicated PR separate from implementation slices.
- Prefer stable identifiers over localized labels.
- Use mock launch fixtures for positive, negative, and edge states.
- Use Swift Testing-compatible snapshot coverage for high-value stable states.
- Map coverage back to feature scenarios and personas.
- Split if project-file setup, fixtures, flow tests, and baselines exceed 10 files or become hard to review together.
