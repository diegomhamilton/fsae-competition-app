# TASK#9.3 SPDD Prompt Run

Task: `9.3 Add short tutorials for adding a new inspection JSON fixture, adding a new validation rule, adding a new accessibility identifier, and adding a new persona scenario.`

Purpose: Add short operational tutorials for common inspection-event extension tasks.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: Tutorial docs
- Validation: Each tutorial has prerequisite, steps, validation, and follow-up.
- Split trigger: Split tutorials if examples require code changes.

Expected PR title:

`TASK#9.3: Tutorials`

Branch:

`codex/inspection-event-docs-review-hygiene-9-3-tutorials`

Common instructions:

- Use YAML frontmatter for title, domain, feature, status, owners, source files, and related scenarios.
- Write documentation in technical report style when explaining architecture and workflow.
- Keep tutorials short and task-oriented.
- Every implementation PR uses Summary, Scope, Notes, and Validation.
- Include manual validation notes, test command output, linked feature scenarios, and squash-merge guidance.
- Keep one feature branch and one PR per major feature by default.
- Split into task branches only when review context becomes too broad.
