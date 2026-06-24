# Approach Prompt

Given the requirements and entities for this task:

Task: `6.3 Implement the test case list view from bundled JSON content, grouped by stage sections and ordered by display order.`

Propose an implementation approach.

Include:

- How to consume `InspectionContentService` or injected loaded stage content
- How to keep the view focused on grouped test case presentation
- How to preserve useful skeleton styling without broad redesign
- How to separate list rendering from full-stage submission logic
- How to add unit tests for view helpers or row state where practical
- How to leave detailed accessibility identifiers and structured string cleanup to TASK#6.6 without blocking future UI tests

Preferred direction:

- Add a small view-state/helper layer only if it reduces SwiftUI body complexity.
- Render sections and test case rows in model display order.
- Surface rule references, visible status/progress, and safety badges already present in content.
- Use closures or coordinator-ready intents for row selection rather than owning navigation policy in the row.

Do not build automatically. Name the exact command the user can run when ready to verify the implementation.
