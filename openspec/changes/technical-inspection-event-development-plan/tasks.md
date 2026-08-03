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
- [x] 6.2 Implement `InspectionContentService` as an async service that loads the six bundled inspection JSON resources.
- [x] 6.3 Implement the test case list view from bundled JSON content, grouped by stage sections and ordered by display order.
- [x] 6.4 Refactor `FullStageView` to render real stage content, stage progress, validation blockers, and submit controls from model state.
- [x] 6.5 Add energized dynamic test badge derivation for EV inspection steps and expose equivalent accessibility information.
- [x] 6.6 Add structured `Strings` enums and stable accessibility identifiers to the stage and test case list files.
- [x] 6.7 Manually validate Garage, EV, Egress, and Rain stage content against `Design/Resources/InspectionEvent/*.json`.

## 7. Session and Submission Flow Foundation

- [x] 7.1 Add failing coordinator tests for mock login completion, session selector routing, start session, resume session, stage selection, team switching, and restored context.
- [x] 7.2 Add failing persistence tests for storing each in-progress test case as its own JSON file under `FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)`, scoped by event, team, session, stage, and test case ID.
- [x] 7.3 Define Codable JSON schemas for test case draft files and immutable submitted test case/stage snapshot files, including schema version, event ID, team ID, session ID, stage ID, test case ID, updated timestamp, outcomes, notes, measurements, evidence metadata, validation summary, and recheck references.
- [x] 7.4 Implement an actor-isolated JSON file persistence service that creates the Application Support folder tree, writes each test case draft atomically, deletes or archives stale draft files after submission, and restores drafts after app relaunch.
- [x] 7.5 Group each team's submission files in a team-specific Application Support folder so submitted snapshots, rechecks, and sticker eligibility can be reviewed without mixing team contexts.
- [x] 7.6 Break each coordinator into a different task PR: Implement `AppCoordinator`, `InspectionEventCoordinator`, `SessionSelectionCoordinator`, and `InspectionExecutionCoordinator`.
- [x] 7.7 Implement `InspectionEventStore` as an actor-isolated event/session source of truth with scoped queries by event, team, session, user access, and the JSON file persistence service.
- [x] 7.8 Merge into 7.6 PRs w/ coordinator: Bind `SessionSelectorView`, `ActiveTeamDashboardView`, `FullStageView`, `StepOverviewView`, and `TeamSwitchConfirmationView` to coordinator-backed state.
- [x] 7.9 Implement `SubmissionSnapshotService` for immutable stage submission snapshots backed by the team submission JSON folder.
- [x] 7.10 Moved to Tentpole 2: Implement `RecheckService` so failed test cases create open recheck items and accepted reviews close them.
- [x] 7.11 Moved to Tentpole 2: Implement sticker eligibility calculation from submitted stages and open rechecks.
- [x] 7.12 Moved to Tentpole 2: Manually validate start, resume after app relaunch, submit, blocked submit, team switch, recheck, sticker eligibility, per-test-case JSON files, and team submission folders against the `.feature` file.

## 8. Dedicated UI Test and Snapshot PR

- [ ] 8.1 Open a dedicated UI test PR after accessibility identifiers and stable navigation hooks exist.
- [ ] 8.2 Add dedicated UI automation launch fixtures for positive, negative, and edge states using mock data.
- [ ] 8.3 Add dedicated UI automation coverage for login, session selector, stage navigation, test case navigation, test step editing, validation blocking, team switching, recheck review, and sticker eligibility.
- [ ] 8.4 Add dedicated UI automation checks that assert required controls and statuses are accessible by stable identifiers rather than localized labels.
- [ ] 8.5 Add snapshot tests for test step, test case, stage list, validation blocked, recheck required, and sticker eligible states where practical.
- [ ] 8.6 Document UI test coverage back to the `.feature` scenarios and personas.

## 9. Documentation and Review Hygiene

- [x] 9.0 Read Tentpole 3 from TASK-12 at `docs/prompts/tasks/TASK-12-spdd-2026-06-29-tentpoles` and update Task 9 tasks. Prioritize the new folder structure described in `### Organization Design`.
- [x] 9.1 Add or update documentation files with YAML frontmatter for title, domain, feature, status, owners, source files, and related scenarios.
- [x] 9.2 Write a technical report style overview of the inspection event architecture, recheck behavior, testing approach, accessibility conventions, and localization conventions.
- [x] 9.3 Add short tutorials for adding a new inspection JSON fixture, adding a new validation rule, adding a new accessibility identifier, and adding a new persona scenario.
- [x] 9.4 Ensure each implementation PR uses the PR 1 description template with `Summary`, `Scope`, `Notes`, and `Validation`, including manual validation notes, test command output, linked `.feature` scenarios, and squash-merge guidance.
- [x] 9.5 Ensure rule "Keep one feature branch and one PR per major feature by default; split into task branches only when file changes or review contexts become too broad"
- [x] 9.6 Ensure rule "Split tasks across distinct commits so each completed task or tightly related task pair has a reviewable checkpoint."
- [x] 9.7 Add the Tentpole 3 organization plan with the target `App`, `Common`, `Features`, and `TestSupport` tree, plus a dry-run table mapping current files to proposed destinations, import risks, ownership risks, and validation checks.
- [x] 9.8 Perform the first behavior-neutral organization pass for `Common/UI`, starting with `DesignSystem.swift` and `KeyboardDismissBar.swift`, preserving public symbols and existing UI behavior.
- [x] 9.9 Split `AppCoordinators.swift` into smaller route and coordinator ownership files without changing route names, public intents, selected screen behavior, team switching, or stage/case/step routing.
- [x] 9.10 Split `ContentView.swift` into smaller root composition, tab composition, binding helper, and empty-state files without changing top-level tabs or current navigation behavior.

## 10. Local Full-Suite Session Version

- [x] 10.0 Track Tentpole 2 continuation items moved from Task 7. Recheck service, sticker eligibility, and broad manual validation were previously sequenced as 10.9, 10.10, and 10.11, then moved to Parking Lot 12 when Task 10 was narrowed to a working local full-suite session version without evidence attachments.
- [x] 10.1 Audit `SessionSelectorView`, `ActiveTeamDashboardView`, `FullStageView`, `TestCaseView`, `StepOverviewView`, and `TeamSwitchConfirmationView` for the minimum UX polish needed after Task 7 so a judge can complete a fully local, stored inspection without prototype copy, unclear navigation, or dead-end states.
- [x] 10.2 Replace prototype header/background treatment and "mock state" copy with stable event, team, stage, and test case context that survives relaunch restore and makes the active local session obvious.
- [x] 10.3 Refactor judge navigation so `Sessions`, `Team`, and `Stage` are the top-level landmarks, remove the standalone `Case` tab, and make Stage contain the case UI with guided test-case and step-detail routing for next-action work.
- [x] 10.4 Add a local team catalog and no-default-mock production launch. A user can create a team entry with display name and car number, and `MockInspectionData.teams` remains available only for tests, previews, or explicit debug fixtures.
- [x] 10.5 Add local session lifecycle for one team: start session, record `startedAt`, end/complete session, record `endedAt`, persist active session state, and restore the active session after relaunch.
- [x] 10.6 Allow a judge to run the full inspection test suite without attaching evidence. Evidence-required controls remain visible as deferred/metadata-only status, but evidence attachments do not block completion in this working version.
- [ ] 10.7 Add session recovery and history: reset an active session with confirmation, preserve past completed executions, show past sessions with start/end timestamps, and document the validation path for checking past executions.
- [ ] 10.8 Track actual token and time usage for each Task 10 PR while completing Task 10. Update `task-10-full-suite-session-plan.xlsx` with estimated tokens, actual input/output/total tokens, estimated time, actual time, branch, PR, and completion notes for 10.4 through 10.7.

## 11.
- [ ] 11.0 UI Improvements:
    11.0.1 "Add Team" should be a button that when clicked expanded the section to input team's name and number
    11.0.2 Stage View should show directly the same information that is currently seen in TestCaseView
    11.0.3 [x] Simplify the shared screen shell by removing redundant prototype eyebrow and header treatment while preserving event, team, stage, and test-case context.
    11.0.4 [x] Remove redundant active-team status pills and align the Sessions screen title/subtitle with the active inspection workflow.
    11.0.5 [x] Disable team-switch operations for the Task 10.6 PR while retaining team selection at session start.
- [ ] 11.1 Make validation blockers actionable by tapping or selecting a blocker to focus the missing outcome, note, measurement, or evidence control, then persist the correction immediately to the test case JSON draft.
- [ ] 11.2 Review `Pending` semantics so incomplete required steps are represented as derived draft state rather than a confusing judge decision.
- [ ] 11.3 Clarify notes and evidence states with labels such as "Add Evidence", "1 Evidence", "Required Evidence Missing", "Add Note", and "Edit Note".
- [ ] 11.4 Add camera capture, gallery/photo-library selection, Files import, attachment creation, and media-storage policy for evidence-required steps.
- [ ] 11.5 Implement `RecheckService` so failed test cases create open recheck items and accepted reviews close them.
- [ ] 11.6 Implement sticker eligibility calculation from submitted stages and open rechecks.
- [ ] 11.7 Add stopwatch-style timing support for egress-test measurement steps.

## 12. Parking Lot
- [ ] 12.1 Refactor step metadata layout to avoid wrapping/truncation in compact widths and larger Dynamic Type.
- [ ] 12.2 Add dedicated UI automation launch fixtures, workflow automation, accessibility identifier assertions, snapshots, and coverage documentation.
- [ ] 12.3 Review completed Task 10 token usage. Compare estimates, actual usage, code SHA at the time, and implementation outcomes to propose workflow changes that reduce token usage for similar future tasks.
- [ ] 12.4 Map EV safety context by test case and step, including energized warnings, accumulator-related cautions, and required PPE guidance where the inspection content or rule metadata supports it.
- [ ] 12.5 Design expandable rule reference presentation so long references such as `EV.7.5.5 / BR.4.6.1.1` can be reviewed without squeezing into small chips.
- [ ] 12.6 Add optional "Why this matters" or inspection hint content for dense EV checks, starting with temperature monitoring and maintenance plug foolproof-connection cases.
- [ ] 12.7 Decide whether EV-specific hints live in bundled inspection JSON, a separate reviewed metadata file, or future remote event content before implementing UI.
