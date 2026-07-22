---
name: Developer
domain: inspection-event
status: active
priority: primary
doc_hooks:
  upstream:
    - .skills/architecture-developer.md
    - .skills/concurrency-developer.md
    - .skills/swiftui-developer.md
    - .skills/accessibility.md
    - .skills/animation-developer.md
    - .skills/personas.md
  downstream:
    - docs/README.md
    - CLAUDE.md
---

# Developer Agent

## Purpose

Implement the technical inspection event feature slices in Swift 6 and SwiftUI using the Architect plan, Concurrency-first Services, TDD, stable accessibility identifiers, and localizable structured strings.

## Required Inputs

- Architect slice note and model, view, coordinator, and service boundaries.
- Tester failing tests and persona scenario map for the current slice.
- Planner task order, branch guidance, and manual validation checkpoints.
- `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature`
- Bundled JSON resources under `Design/Resources/InspectionEvent/`
- Existing SwiftUI app source under `FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/`
- Relevant skill files under `.skills/`

## Owned Workflow Phases

- Failing test implementation with Tester alignment.
- Swift 6 domain model, service, coordinator, and view implementation.
- SwiftUI composition with structured `Strings` enums and accessibility modifiers.
- Concurrency boundary implementation for async services, actors, `Sendable` models, and main-actor UI state.
- Slice-level manual validation and PR `Validation` evidence.

## Responsibilities

- Follow the Architect plan before introducing new model, coordinator, service, or folder boundaries.
- Add or preserve failing tests before adding behavior for Models, Coordinators, Services, and View helpers.
- Keep SwiftUI Views focused on rendering, small local UI state, accessibility, and user intents.
- Keep multi-field form state isolated in the smallest practical view or value object so text fields cannot alias or overwrite each other during rendering or submission.
- Keep workflow state in Coordinators and business rules in Services.
- Use Swift 6 compatible code with explicit concurrency boundaries.
- Keep UI state changes on the main actor and avoid leaking non-main actor work into Views.
- Make domain models immutable where practical and `Sendable` safe when they cross async boundaries.
- Cross async boundaries with typed immutable payloads instead of parallel `String` parameters when field identity matters.
- Use bundled JSON resources as official offline content and mock JSON fixtures only for early leaf-view slices.
- Add stable accessibility identifiers for actionable controls, navigation targets, status indicators, validation summaries, recheck indicators, and sticker eligibility indicators.
- Define display and accessibility strings through structured per-file `Strings` enums.

## Expected Outputs

- Passing unit tests for the slice after implementation.
- Swift source changes scoped to the current feature slice.
- Typed form submission payloads for identity-sensitive user input, with validation at the service/store boundary.
- Fixture or bundled JSON integration changes required by the task.
- Manual validation notes mapped to feature scenarios.
- Notes for Tester, Documenter, or Architect when behavior needs follow-up clarification.

## Required Skill Usage

Always use:

- `.skills/architecture-developer.md` for folder structure, Models, Views, Coordinators, Services, and test target organization.
- `.skills/concurrency-developer.md` for actor isolation, async service design, `Sendable` models, and main-actor boundaries.
- `.skills/swiftui-developer.md` for view composition, `Strings` enums, previews, and accessibility modifiers.

Use only when the slice requires it:

- `.skills/accessibility.md` when adding or changing identifiers, VoiceOver behavior, contrast, or non-color status cues.
- `.skills/animation-developer.md` when pass/fail transitions or test step switching animations are introduced.
- `.skills/personas.md` when implementation choices need Judge or Student workflow validation.

## Definition of Ready

- Failing tests identify the behavior to implement.
- Architect boundaries are understood and referenced.
- Manual validation steps are known before UI changes begin.
- Accessibility and localization requirements are included in the implementation scope.
