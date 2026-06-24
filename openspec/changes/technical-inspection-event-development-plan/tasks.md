## 1. Planning PR

- [x] 1.1 Open PR 1 with `proposal.md`, `design.md`, `tasks.md`, and capability specs for the technical inspection event development plan.
- [x] 1.2 In PR 1, document the full judge flow from mock login to session selection, stage inspection, submission, rechecks, and sticker eligibility.
- [x] 1.3 In PR 1, highlight agent usage for each phase: Architect, Tester, Planner, Developer, and Documenter.
- [x] 1.4 In PR 1, reference `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature` as the source for acceptance scenarios.
- [x] 1.5 In PR 1, define the required PR sequence and note that UI tests are integrated in a dedicated PR.

## 2. Agent Files PR

- [x] 2.1 Open PR 2 to add `.agents/architect.md` with MVC architecture responsibilities based on the `.feature` file.
- [x] 2.2 Add `.agents/tester.md` with persona-driven unit, UI, snapshot, positive, negative, and edge-case responsibilities.
- [x] 2.3 Add `.agents/planner.md` with incremental feature slicing, feature branch naming, task-sized commits, optional task branch splitting, PR 1 description template usage, manual validation checkpoints, squash merge, and documented git workflow responsibilities.
- [x] 2.4 Add `.agents/developer.md` with Swift 6, SwiftUI, Concurrency-first, TDD, and Architect-plan implementation responsibilities.
- [x] 2.5 Add `.agents/documenter.md` with YAML frontmatter, technical report style, feature impact, use case, and tutorial responsibilities.
- [x] 2.6 Verify every agent file names required inputs, outputs, owned workflow phases, and skill usage.

## 3. Skill and Persona Files PR

- [x] 3.1 Open PR 3 to add `.skills/accessibility.md` covering identifiers, VoiceOver, contrast, non-color status cues, and accessible flow completion.
- [x] 3.2 Add `.skills/concurrency-developer.md` covering actor isolation, async services, Sendable-safe models, and main-actor UI boundaries.
- [x] 3.3 Add `.skills/swiftui-developer.md` covering view composition, structured localizable `Strings` enums, previews, and accessibility modifiers.
- [x] 3.4 Add `.skills/animation-developer.md` covering pass/fail transitions and smooth test step switching without reducing accessibility.
- [x] 3.5 Add `.skills/architecture-developer.md` covering folder structure, Models, Views, Coordinators, Services, and test target organization.
- [x] 3.6 Add `.skills/personas.md` plus persona markdown files for Judge, Student, Professor, Fans, and Sponsors, with Judge and Student marked priority.

## 4. Test Step Slice

- [x] 4.1 Add failing unit tests for `InspectionTestStep`, `InspectionOutcome`, `MeasurementValue`, evidence metadata, accessibility identifier helpers, and localizable string key helpers.
- [x] 4.2 Add mock JSON fixtures for representative check, measurement, evidence-required, energized, passing, failing, pending, and edge-case test steps.
- [x] 4.3 Implement Swift 6 domain models for test steps and draft step state.
- [x] 4.4 Implement a mock async fixture loader for test step JSONs.
- [x] 4.5 Refactor the existing step detail UI into a test-step view backed by model data and structured `Strings` enums.
- [x] 4.6 Add accessibility identifiers and VoiceOver labels for outcome controls, notes, measurement input, evidence controls, safety badges, and done actions.
- [x] 4.7 Manually validate the Test Step view with mock JSONs and record the result in the PR description.

## 5. Test Case Slice

- [x] 5.0 In separate PR: Fix bug in which keyboard is not dismissable while editing Notes text input.
- [x] 5.1 Add failing unit tests for `InspectionTestCase`, ordered steps, rule references, draft aggregation, blocker counts, and test case progress.
- [x] 5.2 Add mock JSON fixtures for representative test cases with one step, multiple steps, measurement steps, required evidence, failed notes, and energized badges.
- [x] 5.3 Implement test case models and draft state composition from test step drafts.
- [x] 5.4 Implement `InspectionValidationService` rules for missing outcome, failed note requirement, invalid measurement, and missing evidence.
- [x] 5.5 Add coordinator tests for opening a test case, opening a test step, applying edits, and returning edits to the parent test case.
- [x] 5.6 Refactor the existing stage step card pattern into a test case view that renders ordered steps and validation summaries.
- [ ] 5.7 Manually validate the Test Case view with mock JSONs and record positive, negative, and edge cases from the `.feature` file.

## 6. Test Case List and Stage Slice

- [x] 6.1 Add failing unit tests for `InspectionStage`, `InspectionSection`, bundled JSON decoding, display ordering, stable IDs, unsupported step type errors, and malformed JSON failures.
- [ ] 6.2 Implement `InspectionContentService` as an async service that loads the six bundled inspection JSON resources.
- [ ] 6.3 Implement the test case list view from bundled JSON content, grouped by stage sections and ordered by display order.
- [ ] 6.4 Refactor `FullStageView` to render real stage content, stage progress, validation blockers, and submit controls from model state.
- [ ] 6.5 Add energized dynamic test badge derivation for EV inspection steps and expose equivalent accessibility information.
- [ ] 6.6 Add structured `Strings` enums and stable accessibility identifiers to the stage and test case list files.
- [ ] 6.7 Manually validate Garage, EV, Egress, and Rain stage content against `Design/Resources/InspectionEvent/*.json`.

## 7. Session, Submission, and Recheck Flow

- [ ] 7.1 Add failing coordinator tests for mock login completion, session selector routing, start session, resume session, stage selection, team switching, and restored context.
- [ ] 7.2 Break each coordinator into a different task PR: Implement `AppCoordinator`, `InspectionEventCoordinator`, `SessionSelectionCoordinator`, and `InspectionExecutionCoordinator`.
- [ ] 7.3 Implement `InspectionEventStore` as an actor-isolated event/session source of truth with scoped queries by event, team, session, and user access.
- [ ] 7.4 Merge into 7.2 PRs w/ coordinator: Bind `SessionSelectorView`, `ActiveTeamDashboardView`, `FullStageView`, `StepOverviewView`, and `TeamSwitchConfirmationView` to coordinator-backed state.
- [ ] 7.5 Implement `SubmissionSnapshotService` for immutable stage submission snapshots.
- [ ] 7.6 Implement `RecheckService` so failed test cases create open recheck items and accepted reviews close them.
- [ ] 7.7 Implement sticker eligibility calculation from submitted stages and open rechecks.
- [ ] 7.8 Manually validate start, resume, submit, blocked submit, team switch, recheck, and sticker eligibility flows against the `.feature` file.

## 8. Dedicated UI Test and Snapshot PR

- [ ] 8.1 Open a dedicated UI test PR after accessibility identifiers and stable navigation hooks exist.
- [ ] 8.2 Add XCUITest launch fixtures for positive, negative, and edge states using mock data.
- [ ] 8.3 Add XCUITests for login, session selector, stage navigation, test case navigation, test step editing, validation blocking, team switching, recheck review, and sticker eligibility.
- [ ] 8.4 Add XCUITests that assert required controls and statuses are accessible by stable identifiers rather than localized labels.
- [ ] 8.5 Add snapshot tests for test step, test case, stage list, validation blocked, recheck required, and sticker eligible states where practical.
- [ ] 8.6 Document UI test coverage back to the `.feature` scenarios and personas.

## 9. Documentation and Review Hygiene

- [ ] 9.1 Add or update documentation files with YAML frontmatter for title, domain, feature, status, owners, source files, and related scenarios.
- [ ] 9.2 Write a technical report style overview of the inspection event architecture, recheck behavior, testing approach, accessibility conventions, and localization conventions.
- [ ] 9.3 Add short tutorials for adding a new inspection JSON fixture, adding a new validation rule, adding a new accessibility identifier, and adding a new persona scenario.
- [ ] 9.4 Ensure each implementation PR uses the PR 1 description template with `Summary`, `Scope`, `Notes`, and `Validation`, including manual validation notes, test command output, linked `.feature` scenarios, and squash-merge guidance.
- [ ] 9.5 Keep one feature branch and one PR per major feature by default; split into task branches only when file changes or review contexts become too broad.
- [ ] 9.6 Split tasks across distinct commits so each completed task or tightly related task pair has a reviewable checkpoint.
