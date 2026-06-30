---
title: Inspection Event Extension Tutorials
domain: technical-inspection
feature: inspection-event
status: active
owners:
  - Documenter
  - Developer
source_files:
  - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/InspectionEvent
  - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/Validation/ValidationService.swift
  - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/InspectionContent/Models/InspectionModels.swift
  - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/TestSupport/Fixtures/MockInspectionTestStepFixtureLoader.swift
  - .skills/personas.md
related_scenarios:
  - Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature
---

# Inspection Event Extension Tutorials

## Add an Inspection JSON Fixture

Prerequisite: identify the stage, section, test case, and step IDs from the official inspection content.

Steps:

1. Add or update a JSON file under `FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/InspectionEvent/` for app-bundled content, or `Design/Resources/InspectionEvent/` for design-source content.
2. Preserve stable IDs, display order, rule references, badges, step types, and required metadata.
3. Add or update Swift Testing coverage for decoding, ordering, stable IDs, unsupported step types, and malformed JSON behavior.
4. Confirm the stage renders through `InspectionContentService` without falling back to mock data.

Validation:

- Run the content service/model test suite.
- Manually compare the fixture to the related feature scenario and official design resource.

Follow-up:

- If the fixture introduces a new policy field, update the OpenSpec JSON content spec before relying on it in validation.

## Add a Validation Rule

Prerequisite: define the user-facing blocked state and the feature scenario that proves it.

Steps:

1. Add a failing test to `InspectionValidationServiceTests.swift` for the missing or invalid condition.
2. Extend `InspectionValidationService` with the narrowest rule needed.
3. Return a `ValidationIssue` that identifies the affected test case, step, message, and route back to correction.
4. Update view-helper tests if blocker counts, status text, or first-blocker routing changes.

Validation:

- Run validation service tests and any stage/test case view-state tests touched by the rule.
- Record manual validation for the blocked and corrected paths in the PR.

Follow-up:

- Add UI automation for the rule in Task 8 once stable identifiers cover the affected control.

## Add an Accessibility Identifier

Prerequisite: identify the control or status in a feature scenario and confirm whether it is user-actionable, navigational, or a validation/status surface.

Steps:

1. Add the identifier as a stable constant near the view or helper that owns the UI.
2. Apply `.accessibilityIdentifier(...)` to the SwiftUI element that UI automation should locate.
3. Keep visible strings and accessibility labels separate from the identifier.
4. Add or update view-helper tests for identifier construction if the identifier is dynamic.

Validation:

- Inspect the view code for stable constants.
- Run view-helper or coordinator tests that cover the route to the control.

Follow-up:

- Add dedicated UI automation in Task 8 to assert the identifier is discoverable.

## Add a Persona Scenario

Prerequisite: choose whether the scenario serves the priority Judge or Student persona, or a secondary Professor, Fans, or Sponsors perspective.

Steps:

1. Add the scenario to the relevant persona markdown file or feature scenario map.
2. Link the scenario to `inspection_event_use_cases.feature` when it affects app behavior.
3. Identify whether the scenario needs unit tests, manual validation, UI automation, or documentation only.
4. Keep non-primary personas focused on stakeholder impact, not new workflow requirements.

Validation:

- Confirm the persona scenario names the actor, goal, system response, and evidence to capture.
- Check that any implementation follow-up is represented in OpenSpec tasks or a prompt folder.

Follow-up:

- Promote repeated persona feedback into feature scenarios before changing app behavior.
