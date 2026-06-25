## Why

The inspection event workflow needs a concrete implementation plan that can rebuild the app from the current SwiftUI mock views into a production-ready technical inspection tool. The plan must stay anchored to `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature`, use the bundled inspection JSON resources as the offline source of truth, and explicitly cover the path from login through stage submission, rechecks, and inspection sticker readiness.

## What Changes

- Define an incremental implementation plan for the technical inspection event centered on the existing `SessionSelectorView`, `ActiveTeamDashboardView`, `FullStageView`, `StepOverviewView`, and `TeamSwitchConfirmationView`.
- Establish a Swift 6, SwiftUI, and Concurrency-first MVC architecture using Models, Views, Coordinators, and Services.
- Add development slices in this order: Test Step view from mock JSONs, Test Case view from mock JSONs, then Test Case list and stage views from bundled JSONs.
- Persist each in-progress test case as an individual JSON file in the app's Application Support directory, scoped by event, team, session, stage, and test case ID.
- Group each team's submitted stage/test case snapshots in team-specific local JSON folders for review, rechecks, and sticker eligibility.
- Treat a recheck as any failed inspection test case from `Design/Resources/InspectionEvent/*.json`; teams must resolve the issue and review with a judge before receiving inspection stickers.
- Add a follow-up UX cleanup slice for step-view ergonomics, picture capture for evidence-required steps, and stopwatch timing for the egress test.
- Define a multi-agent delivery workflow with Architect, Tester, Planner, Developer, and Documenter agents, plus dedicated skill files for accessibility, concurrency, SwiftUI, animation, architecture, and personas.
- Require TDD for Models, Coordinators, Services, and View helpers, with UI tests and snapshot tests planned in a dedicated PR.
- Require accessibility identifiers, VoiceOver-ready flows, localized strings, and structured per-file string constant enums.
- Define documentation conventions using YAML frontmatter for better LLM indexing and technical report style.

## Capabilities

### New Capabilities

- `inspection-event-execution`: Covers login-to-session selection, active team inspection, stage/test case/test step navigation, Application Support JSON draft persistence, submission validation, snapshots, and recheck state transitions for technical inspection.
- `inspection-event-json-content`: Covers loading, decoding, validating, and presenting bundled inspection stage JSON files as the offline source of truth.
- `inspection-event-agent-workflow`: Covers the planned multi-agent implementation workflow, PR sequence, agent responsibilities, skills, persona usage, and git hygiene.
- `inspection-event-accessibility-localization`: Covers accessibility identifiers, VoiceOver navigation, color/contrast requirements, dedicated UI automation accessibility coverage, and localizable structured string constants.
- `inspection-event-testing-strategy`: Covers TDD requirements, unit test scope, UI test scope, snapshot testing, mock JSON fixtures, positive/negative/edge cases, and the dedicated UI-test PR.

### Modified Capabilities

- None.

## Impact

- Swift app source under `FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/`.
- Existing SwiftUI mock screens and design system.
- Bundled inspection data under `Design/Resources/InspectionEvent/*.json`.
- Acceptance scenarios in `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature`.
- Local JSON files written under the app's Application Support directory during session/submission implementation.
- Future documentation and planning files for `.agents/`, skill definitions, persona files, and implementation PR workflow.
- Test targets for Swift Testing unit/integration tests, dedicated UI automation, and snapshot tests once the Xcode project/test structure is introduced.
