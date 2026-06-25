# Approach Prompt

Given the requirements and entities for this task:

Task: `7.7 Implement InspectionEventStore as an actor-isolated event/session source of truth with scoped queries by event, team, session, user access, and the JSON file persistence service.`

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

Implement actor-isolated InspectionEventStore with scoped event/team/session/user queries backed by persistence.

Validation expectation:

Swift Testing for scoped queries, access isolation, and async mutation behavior.

Split trigger:

Split from coordinators if store APIs are still changing.

Do not build automatically unless explicitly asked.
