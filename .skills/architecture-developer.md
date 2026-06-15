---
name: Architecture Developer
domain: inspection-event
status: active
owners:
  - Architect
  - Developer
  - Tester
---

# Architecture Developer Skill

## Purpose

Guide the technical inspection event MVC structure, folder organization, model boundaries, view placement, coordinator flow ownership, service responsibilities, and test target organization.

## Use When

- Introducing Models, Views, Coordinators, Services, or Tests for an inspection event slice.
- Deciding file placement for test step, test case, stage content, session flow, recheck, or sticker eligibility work.
- Reviewing whether workflow logic belongs in a View, Coordinator, or Service.

## Required Inputs

- Architect agent notes for the current slice.
- `openspec/changes/technical-inspection-event-development-plan/design.md`
- Relevant capability spec files.
- Existing SwiftUI source structure under `FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/`

## Implementation Checklist

- Place inspection content and draft state in Models.
- Place SwiftUI rendering and interaction surfaces in Views.
- Place navigation, selected team/session/stage context, and user intents in Coordinators.
- Place async content loading, validation, snapshots, rechecks, authentication stubs, and persistence boundaries in Services.
- Keep bundled JSON loading behind `InspectionContentService`.
- Keep mutable event/session state scoped through an actor-isolated `InspectionEventStore`.
- Organize tests to mirror Models, Coordinators, Services, and View helpers.
- Keep UI tests and snapshot tests in the dedicated UI test PR after identifiers and navigation hooks are stable.

## Expected Outputs

- Folder and file placement recommendations.
- Clear ownership for each new type.
- Test target placement guidance.
- Architecture risks or assumptions called out before implementation.

## Agent Usage

- Architect uses this skill to define slice boundaries.
- Developer uses this skill when adding or moving source files.
- Tester uses this skill to locate unit, UI, and snapshot coverage.
