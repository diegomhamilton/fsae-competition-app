# TASK#8 SPDD Operations Prompt Run

Task group: Dedicated UI Test and Snapshot PR

Purpose: add dedicated UI automation, launch fixtures, accessibility identifier assertions, Swift Testing-compatible snapshot tests, and coverage documentation after stable navigation hooks exist.

Primary prompt:

- `05-operations-summary.md`

Shared instruction highlight:

- `common-instructions.md`

Expected feature branch:

`codex/inspection-event-ui-tests`

Default PR strategy:

Use one dedicated UI-test PR unless project-file churn, launch fixture setup, UI automation flows, and snapshot baselines become too broad to review together. If the PR crosses 10 files, split fixture/setup, flow tests, accessibility assertions, snapshots, and documentation into task branches, then squash back into the feature branch.

Child prompt runs:

- `TASK-8.1-open-dedicated-ui-test-pr/`
- `TASK-8.2-ui-automation-launch-fixtures/`
- `TASK-8.3-ui-automation-flows/`
- `TASK-8.4-accessibility-identifier-checks/`
- `TASK-8.5-snapshot-tests/`
- `TASK-8.6-coverage-documentation/`

