# Approach Prompt

Given the requirements and entities for this task:

Task: `7.3 Define Codable JSON schemas for test case draft files and immutable submitted test case/stage snapshot files, including schema version, event ID, team ID, session ID, stage ID, test case ID, updated timestamp, outcomes, notes, measurements, evidence metadata, validation summary, and recheck references.`

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

Define Codable v1 draft and submission snapshot schemas with explicit IDs, timestamps, validation, evidence, and recheck references.

Validation expectation:

Swift Testing Codable round-trip and malformed-payload checks.

Split trigger:

Split if schema migration or compatibility logic grows beyond initial v1 shape.

Do not build automatically unless explicitly asked.
