# Approach Prompt

Given the requirements and entities for this task:

Task: `6.5 Add energized dynamic test badge derivation for EV inspection steps and expose equivalent accessibility information.`

Propose an implementation approach.

Include:

- How to inspect EV bundled JSON and identify the derivation rule
- Where to place the derivation so views receive explicit badge metadata
- How to preserve explicit badges from mock fixtures and content
- How to expose accessibility-equivalent text through existing badge/view-state patterns
- How to test derivation without relying on SwiftUI snapshots
- How to avoid overreaching into the full TASK#6.6 accessibility identifier sweep

Preferred direction:

- Keep badge derivation near content normalization or model helper logic, not buried in a SwiftUI row body.
- Merge derived badges with explicit content badges without duplication.
- Add unit tests for EV energized detection and non-EV/non-energized exclusions.
- Add a focused view helper test if badge accessibility text is produced by view state.

Do not build automatically. Name the exact command the user can run when ready to verify the implementation.
