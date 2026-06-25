# Safeguards Prompt

Act as the SPDD safeguard reviewer for this task:

Task: `5.2 Add mock JSON fixtures for representative test cases with one step, multiple steps, measurement steps, required evidence, failed notes, and energized badges.`

Plan: `<paste operations>`

Review for:

- Scope creep beyond fixture JSON
- Missing representative case category
- JSON fixture/schema assumptions
- Incompatibility with existing `InspectionTestStep` fixture shape
- Missing stable IDs, display order, title, rule references, or ordered steps
- Duplicate IDs that would make future decoding ambiguous
- Accidental implementation of production model decoding before TASK#5.3
- Missing linkage to `inspection-event-json-content`
- Missing feature-scenario coverage for measurement, evidence, failed notes, and energized badges
- Commit boundaries that would knowingly break compilation
- PR title not starting with `TASK#5.2:`
- Automatic build/test execution despite the user-run build policy
- Manual validation omissions

Return blockers first, then recommendations, then a final go/no-go.
