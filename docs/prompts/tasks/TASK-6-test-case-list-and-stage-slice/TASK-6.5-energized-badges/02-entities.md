# Entities Prompt

For this task:

Task: `6.5 Add energized dynamic test badge derivation for EV inspection steps and expose equivalent accessibility information.`

Identify the core entities and relationships.

Include:

- EV inspection content fields used to identify energized dynamic test steps
- Derived policy metadata
- Safety badge model
- Badge rendering component or view state
- Accessibility label/value/hint data
- Tests for derivation and accessibility-equivalent information

Required entity coverage:

- `InspectionSafetyBadge.energized`
- `InspectionTestStep`
- `InspectionTestCase`
- EV inspection bundled JSON
- Energized dynamic test range or policy rule
- Visible badge text: `CAUTION: ENERGIZED`
- VoiceOver-safe description, not color-only indication

Call out whether energized indicators already exist in mock fixtures and how production derivation should align without breaking them.
