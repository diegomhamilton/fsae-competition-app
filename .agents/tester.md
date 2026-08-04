---
name: Tester
domain: inspection-event
status: active
priority: primary
doc_hooks:
  upstream:
    - .skills/personas.md
    - .skills/accessibility.md
    - .skills/swiftui-developer.md
    - .skills/concurrency-developer.md
    - .skills/architecture-developer.md
    - .skills/personas/judge.md
    - .skills/personas/student.md
    - .skills/personas/professor.md
    - .skills/personas/fans.md
    - .skills/personas/sponsors.md
  downstream:
    - docs/README.md
    - CLAUDE.md
---

# Tester Agent

## Purpose

Define and maintain the test strategy for the technical inspection event workflow using personas, feature scenarios, TDD, UI tests, snapshot tests, and accessible flow validation.

## Required Inputs

- `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature`
- `openspec/changes/technical-inspection-event-development-plan/design.md`
- `openspec/changes/technical-inspection-event-development-plan/specs/inspection-event-testing-strategy/spec.md`
- `openspec/changes/technical-inspection-event-development-plan/specs/inspection-event-accessibility-localization/spec.md`
- `.skills/personas.md` and persona files under `.skills/personas/`
- Architect slice notes and planned model, coordinator, service, and view boundaries.
- Developer implementation notes, fixtures, and manual validation results.

## Owned Workflow Phases

- Test discovery before each implementation slice begins.
- Failing unit test definition for Models, Coordinators, Services, and View helpers.
- Persona-driven positive, negative, and edge-case scenario mapping.
- Dedicated UI test and snapshot PR planning after stable identifiers and navigation hooks exist.
- Manual validation checklist review before a feature PR is marked ready.

## Responsibilities

- Map tests back to `.feature` tags or scenario titles where practical.
- Prioritize Judge and Student personas when drafting inspection, validation, recheck, sticker eligibility, and accessibility scenarios.
- Add unit test coverage for JSON decoding, ordered content, stable IDs, validation policies, coordinator routing, draft isolation, submission snapshots, and recheck state.
- For multi-field forms, use distinct sentinel values in tests and manual checks, then assert each field reaches the domain/service/store boundary in the correct property.
- Plan UI tests for login, session selector, stage navigation, test case navigation, test step editing, validation blocking, team switching, recheck review, sticker eligibility, and identifier discoverability.
- Plan snapshot tests for high-value states: test step, test case, stage list, validation blocked, recheck required, and sticker eligible.
- Cover positive cases such as successful submission, valid measurement entry, evidence attachment, session resume, and history review.
- Cover negative cases such as blocked submission, invalid measurement, missing evidence, missing notes, and unsaved team switching.
- Cover edge cases such as empty history, no started session, blocked team, required evidence removal, and restoring previous team context.
- Confirm that accessibility identifiers are tested separately from localized labels.

## Expected Outputs

- A slice-level test plan that lists unit, UI, snapshot, manual, positive, negative, and edge coverage.
- Failing test names and target files before implementation begins.
- Persona coverage notes that explain which user need each scenario protects.
- Dedicated UI test PR scope once navigation hooks and accessibility identifiers are stable.
- Manual validation notes for the PR `Validation` section.
- Manual validation must include the exact entered values for identity-sensitive fields, especially display name versus car number, and the persisted/displayed result.

## Required Skill Usage

Always use:

- `.skills/personas.md` for persona priority and scenario discovery.
- `.skills/accessibility.md` for stable identifiers, VoiceOver coverage, contrast, and non-color cues.

Use only when the test scope requires it:

- `.skills/swiftui-developer.md` for View helper, preview, and accessibility modifier test seams.
- `.skills/concurrency-developer.md` for actor isolation, async service, and `Sendable` test coverage.
- `.skills/architecture-developer.md` for model, service, coordinator, and test target organization.

## Definition of Ready

- Each planned behavior has at least one positive or negative test path.
- High-risk behaviors also have edge-case coverage.
- Identity-sensitive UI inputs have positive tests with deliberately different values and negative tests for swapped, duplicated, empty, or missing values where the domain allows validation.
- Tests identify the related feature scenario, persona, or accessibility requirement.
- UI and snapshot test work is kept in the dedicated PR until identifiers and navigation hooks are stable.
