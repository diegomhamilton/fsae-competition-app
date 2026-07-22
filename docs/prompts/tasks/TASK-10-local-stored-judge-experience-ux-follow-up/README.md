# TASK#10 SPDD Operations Prompt Run

Task group: Local Full-Suite Session Version

Purpose: deliver the smallest working local version where a user can create a team, start and complete a full inspection test suite without attaching evidence, reset an active session if needed, and review past executions with start/end timestamps.

Tentpole 2 scope note:

- Current branch state marks TASK#10.0, TASK#10.1, and TASK#10.2 complete. Do not reorder those completed tasks.
- TASK#10.3 is complete in `codex/milestone-10-design-review`. TASK#10.4 is the next implementation task and owns the local team catalog plus no-default-mock production launch.
- Keep Task 10 lean. Move broad UX polish, guided navigation, camera/gallery/Files evidence input, media storage, recheck service, sticker eligibility, stopwatch timing, UI automation, snapshots, and EV enhancements to Parking Lot 12.
- Evidence-required controls may remain visible, but evidence attachment input and attachment validation do not block completion in the Task 10 working version.
- Use one OpenSpec task as one branch and one PR. Do not combine multiple Task 10 tasks into one PR.

Delivery target:

- 5 remaining Task 10 PRs:
  1. `10.4` Local team catalog and no-default-mock launch.
  2. `10.5` Session lifecycle with start/end timestamps and relaunch restore.
  3. `10.6` Full-suite execution without evidence attachments.
  4. `10.7` Reset and past execution history.
  5. `10.8` Actual token and time tracking for Task 10 PRs.

Tracking artifact:

- `task-10-full-suite-session-plan.xlsx`

Primary prompt:

- `05-operations-summary.md`

Shared instruction highlight:

- `common-instructions.md`

Expected branch pattern:

`codex/task-10-<task-number>-<short-slug>`

Default PR strategy:

One OpenSpec task = one branch = one PR. Keep task-internal commits reviewable, include tests with the behavior they prove, and squash-merge the PR. If a task starts to contain two independently shippable outcomes, split the task in OpenSpec before coding instead of making one large PR.

Child prompt runs:

- `[complete] TASK-10.1-ux-audit/`
- `[complete] TASK-10.2-stable-context-copy/`
- `[complete] TASK-10.3-guided-navigation/`
- `[next] TASK-10.4-local-team-catalog/`
- `TASK-10.5-session-lifecycle-timestamps/`
- `TASK-10.6-no-evidence-full-suite/`
- `TASK-10.7-reset-and-history/`
- `TASK-10.8-token-time-tracking/`

Parking Lot 12 prompt sources:

- `../TASK-7-session-submission-and-recheck-flow/TASK-7.10-recheck-service/`
- `../TASK-7-session-submission-and-recheck-flow/TASK-7.11-sticker-eligibility/`
- `../TASK-7-session-submission-and-recheck-flow/TASK-7.12-manual-validation/`
- former `TASK-10.4-step-metadata-layout/`
- former `TASK-10.5-actionable-validation-blockers/`
- former `TASK-10.6-pending-semantics/`
- former `TASK-10.7-notes-evidence-labels/`
- former `TASK-10.8-camera-evidence-metadata/`
- former `TASK-10.9-egress-stopwatch/`
- former `TASK-10.10-focused-tests-manual-validation/`
