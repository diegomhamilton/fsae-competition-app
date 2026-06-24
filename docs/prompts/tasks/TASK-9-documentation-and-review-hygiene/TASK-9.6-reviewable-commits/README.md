# TASK#9.6 SPDD Prompt Run

Task: `9.6 Split tasks across distinct commits so each completed task or tightly related task pair has a reviewable checkpoint.`

Purpose: Define task-sized commit guidance so each checkpoint is reviewable.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: Commit plan docs; PR notes
- Validation: Commit list maps to tasks and validation.
- Split trigger: Split branches if commits are still too hard to review in one PR.

Expected PR title:

`TASK#9.6: Reviewable Commits`

Branch:

`codex/inspection-event-docs-review-hygiene-9-6-reviewable-commits`

Common instructions:

- Use YAML frontmatter for title, domain, feature, status, owners, source files, and related scenarios.
- Write documentation in technical report style when explaining architecture and workflow.
- Keep tutorials short and task-oriented.
- Every implementation PR uses Summary, Scope, Notes, and Validation.
- Include manual validation notes, test command output, linked feature scenarios, and squash-merge guidance.
- Keep one feature branch and one PR per major feature by default.
- Split into task branches only when review context becomes too broad.
