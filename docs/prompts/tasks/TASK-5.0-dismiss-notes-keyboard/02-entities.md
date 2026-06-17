# Entities Prompt

Given this task:

Task: `5.0 In separate PR: Fix bug in which keyboard is not dismissable while editing Notes text input.`

Identify the domain and UI entities involved.

For each entity, describe:

- Responsibility
- Key fields or state
- Relationships to other entities
- Whether it is immutable content, mutable draft state, UI state, service state, or test fixture data

Include at least:

- Judge
- Notes input
- `InspectionTestStep`
- Draft note text
- Focus state
- Keyboard dismissal action
- Done or save navigation action

Use the project's inspection-event language, but keep the task scoped to keyboard dismissal and note-editing ergonomics.
