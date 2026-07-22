---
name: Accessibility
domain: inspection-event
status: active
owners:
  - Tester
  - Developer
  - Documenter
---

# Accessibility Skill

## Purpose

Guide technical inspection event work so judges can complete login, session selection, stage inspection, validation correction, submission, team switching, and recheck review with stable identifiers, VoiceOver, contrast, and non-color cues.

## Use When

- Adding or changing user-actionable controls, navigation destinations, status indicators, validation summaries, recheck indicators, sticker eligibility indicators, or evidence controls.
- Writing XCUITests that locate UI by accessibility identifier.
- Reviewing VoiceOver flow completion or non-color status cues.
- Documenting accessibility behavior in a PR.

## Required Inputs

- `inspection-event-accessibility-localization` spec.
- Current SwiftUI view or component file.
- Related `.feature` scenario.
- Persona context from `.skills/personas/judge.md` and `.skills/personas/student.md`.

## Implementation Checklist

- Define stable accessibility identifiers separately from localized labels.
- Give each editable field a unique identifier and verify tests use those identifiers, not placeholder text or nearby labels, to enter data.
- Add identifiers for session rows, stage rows, test case rows, test step controls, validation summaries, submission controls, recheck actions, and sticker eligibility statuses.
- Ensure VoiceOver can identify the active team, stage, test case, invalid step, failed test case, recheck state, and save or submit action.
- Pair color with text, icon, or shape for passed, failed, pending, blocked, recheck required, and sticker eligible states.
- Give energized EV steps meaningful text such as `CAUTION: ENERGIZED` and an equivalent accessibility label or value.
- Keep accessibility labels, hints, and values in structured `Strings` enums with visible strings.
- Verify validation summaries announce the blocker and allow navigation to the first invalid step.

## Expected Outputs

- Identifier constants or helpers with stable names.
- VoiceOver labels, hints, and values for critical controls and statuses.
- XCUITest coverage that queries identifiers rather than localized labels.
- XCUITest or manual field-identity coverage for forms where two controls share the same keyboard type, layout, or value type.
- Manual validation notes for keyboard, VoiceOver, status cues, and blocked submission correction.

## Agent Usage

- Tester uses this skill to define identifier, VoiceOver, and accessible flow coverage.
- Developer uses this skill while adding SwiftUI accessibility modifiers.
- Documenter uses this skill to document accessibility conventions and validation evidence.
