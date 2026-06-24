# Requirements Prompt

You are helping with SPDD for this task:

Task: `9.3 Add short tutorials for adding a new inspection JSON fixture, adding a new validation rule, adding a new accessibility identifier, and adding a new persona scenario.`

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

- Macro-task: TASK#9 Documentation and Review Hygiene
- Subtask: TASK#9.3
- Expected PR title: `TASK#9.3: Tutorials`
- Feature branch: `codex/inspection-event-docs-review-hygiene`
- Suggested task branch: `codex/inspection-event-docs-review-hygiene-9-3-tutorials`
- Operation summary: Add short operational tutorials for common inspection-event extension tasks.
- Likely files or targets: Tutorial docs
- Validation: Each tutorial has prerequisite, steps, validation, and follow-up.
- Split trigger: Split tutorials if examples require code changes.
- Common instructions:
- Use YAML frontmatter for title, domain, feature, status, owners, source files, and related scenarios.
- Write documentation in technical report style when explaining architecture and workflow.
- Keep tutorials short and task-oriented.
- Every implementation PR uses Summary, Scope, Notes, and Validation.
- Include manual validation notes, test command output, linked feature scenarios, and squash-merge guidance.
- Keep one feature branch and one PR per major feature by default.
- Split into task branches only when review context becomes too broad.
