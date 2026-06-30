# Approach Prompt

Given the requirements and entities for this task:

Task: `7.9 Implement SubmissionSnapshotService for immutable stage submission snapshots backed by the team submission JSON folder.`

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

Implement immutable stage submission snapshot creation backed by team submission JSON folders after coordinators/views already use InspectionEventStore for draft save/restore.

Validation expectation:

Swift Testing for snapshot creation, immutability, and team path placement; do not backfill coordinator/view draft wiring here.

Split trigger:

Split if persistence cleanup, recheck creation, or coordinator/view store integration gets mixed in.

Do not build automatically unless explicitly asked.
