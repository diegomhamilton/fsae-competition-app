# Requirements Prompt

You are helping with SPDD for this task:

Task: `8.4 Add dedicated UI automation checks that assert required controls and statuses are accessible by stable identifiers rather than localized labels.`

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
- Subtask: TASK#8.4
- Expected PR title: `TASK#8.4: Accessibility Identifier Checks`
- Feature branch: `codex/inspection-event-ui-tests`
- Suggested task branch: `codex/inspection-event-ui-tests-8-4-accessibility-identifier-checks`
- Operation summary: Assert controls and statuses by stable accessibility identifiers rather than localized labels.
- Likely files or targets: UI automation assertions; accessibility ID helpers
- Validation: Tests fail when required identifiers are missing or unstable.
- Split trigger: Split if app code needs identifier fixes.
- Common instructions:
- Start only after accessibility identifiers and stable navigation hooks exist.
- Keep UI automation in a dedicated PR separate from implementation slices.
- Prefer stable identifiers over localized labels.
- Use mock launch fixtures for positive, negative, and edge states.
- Use Swift Testing-compatible snapshot coverage for high-value stable states.
- Map coverage back to feature scenarios and personas.
- Split if project-file setup, fixtures, flow tests, and baselines exceed 10 files or become hard to review together.
