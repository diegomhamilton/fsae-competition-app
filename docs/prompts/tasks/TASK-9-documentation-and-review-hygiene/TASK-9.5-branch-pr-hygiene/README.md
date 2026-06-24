# TASK#9.5 SPDD Prompt Run

Task: `9.5 Keep one feature branch and one PR per major feature by default; split into task branches only when file changes or review contexts become too broad.`

Purpose: Document branch and PR split rules for feature branches and short-lived task branches.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: Workflow docs; prompt docs
- Validation: Branch plan identifies split thresholds.
- Split trigger: Split when a PR exceeds 10 files or combines unrelated domains.

Expected PR title:

`TASK#9.5: Branch PR Hygiene`

Branch:

`codex/inspection-event-docs-review-hygiene-9-5-branch-pr-hygiene`

Common instructions:

- Use YAML frontmatter for title, domain, feature, status, owners, source files, and related scenarios.
- Write documentation in technical report style when explaining architecture and workflow.
- Keep tutorials short and task-oriented.
- Every implementation PR uses Summary, Scope, Notes, and Validation.
- Include manual validation notes, test command output, linked feature scenarios, and squash-merge guidance.
- Keep one feature branch and one PR per major feature by default.
- Split into task branches only when review context becomes too broad.
