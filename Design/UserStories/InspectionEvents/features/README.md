# Inspection Event Gherkin Features

These `.feature` files organize the inspection app use cases as Gherkin
behavior specifications.

## Files

- `inspection_event_use_cases.feature`: end-to-end inspection event workflows
  mapped to the existing Phase 1 user stories (`US-001` through `US-007`) and
  Phase 2 flows (`FL-001` through `FL-006`).

## Conventions

- Use one `Feature` per file.
- Use `Rule` sections to group scenarios by business rule.
- Keep scenarios focused on observable behavior.
- Preserve story and flow traceability with tags such as `@US-001` and
  `@FL-001`.
