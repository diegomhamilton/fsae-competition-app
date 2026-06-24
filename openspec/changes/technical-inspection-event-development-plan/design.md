## Context

The app is currently a SwiftUI prototype under `FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/` with mock models and screens for session selection, active team dashboard, full stage, step detail, and team switching. The inspection event behavior is specified by `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature`, and the official offline inspection content exists as stage JSON files under `Design/Resources/InspectionEvent/`.

The target workflow is judge-first: authenticate, select or resume a team session, inspect stages in official order, record outcomes/notes/measurements/evidence, submit valid stage snapshots, and track any failed test case as a recheck until the team fixes the issue and a judge reviews it. Inspection stickers are available only after required stages and rechecks are complete.

This change is a development plan, not the full implementation. The first implementation slices must remain small and manually reviewable: Test Step view from mock JSONs, Test Case view from mock JSONs, then Test Case list and stage views from bundled JSONs.

## Goals / Non-Goals

**Goals:**

- Define a Swift 6, SwiftUI, Concurrency-first architecture using MVC: Models, Views, Coordinators, and Services.
- Preserve the existing SwiftUI screens as the starting UI shape while replacing mock state with domain-backed state over incremental PRs.
- Use the `.feature` file as the primary acceptance source for every implementation phase and test scenario.
- Define concrete classes, services, coordinators, unit tests, XCUITests, snapshot tests, documentation, agents, and skill files.
- Separate UI test integration into a dedicated PR after the model/coordinator/service foundations are stable.
- Require localizable strings through structured `Strings` enums in each view or component file.
- Require accessibility identifiers and VoiceOver-complete flows from the first UI-facing slices.

**Non-Goals:**

- Implement production authentication, cloud sync, or remote event APIs in the initial plan.
- Add real camera/file attachment storage before metadata-only evidence and validation are stable.
- Merge UI tests into every implementation PR; they are planned as a dedicated PR with clear coverage boundaries.
- Rewrite the entire UI before validating the incremental inspection flow.
- Replace the bundled JSON resources with a network content system.

## Decisions

### Use MVC With Coordinators and Services

Decision:
- Models represent immutable inspection content, mutable session draft state, validation results, submissions, rechecks, teams, and stickers.
- Views remain SwiftUI value views with small local UI state only.
- Coordinators own navigation, flow state, and user intents such as login completion, team selection, stage submission, recheck review, and team switching.
- Services provide async boundaries for content loading, session persistence, validation, submission snapshot creation, recheck management, and authentication stubs.

Rationale:
- This matches the requested MVC shape while keeping SwiftUI views testable and previewable.
- Coordinators avoid placing event workflow logic inside individual views.
- Services make Concurrency-first work explicit and keep future persistence or API migration isolated.
- A single actor-isolated event store can still be the source of truth. The important boundary is that reads and writes go through scoped queries and access policy, not unscoped mutable view state.

Alternatives considered:
- MVVM was already discussed in older docs, but the requested plan is MVC with Coordinators and Services.
- Unscoped global UI state would simplify early prototypes but would make it easier to accidentally mix active team/session context. A single store is acceptable when it filters data by user access and scopes operational queries by event, team, and session.

### Define Core Classes Around Inspection Event Language

Proposed Models:
- `InspectionEvent`, `InspectionTeam`, `InspectionSession`, `InspectionStage`, `InspectionSection`, `InspectionTestCase`, `InspectionTestStep`
- `InspectionOutcome`, `MeasurementValue`, `EvidenceAttachmentMetadata`, `InspectorNote`
- `StageDraft`, `TestCaseDraft`, `TestStepDraft`, `ValidationIssue`, `SubmissionSnapshot`
- `RecheckItem`, `RecheckStatus`, `InspectionStickerEligibility`

Proposed Coordinators:
- `AppCoordinator`: launch, login state, root flow.
- `InspectionEventCoordinator`: selected event, active team/session, high-level routing.
- `SessionSelectionCoordinator`: start/resume team sessions.
- `InspectionExecutionCoordinator`: stage/test case/test step navigation, submission intents, validation correction routing, recheck review, and sticker eligibility routing.

Proposed Services:
- `AuthenticationService`: async mock login boundary for now.
- `InspectionContentService`: async load/decode bundled `InspectionEvent/*.json`.
- `InspectionValidationService`: validates required outcomes, failed-step notes, measurement ranges, and evidence requirements.
- `InspectionEventStore`: actor-isolated event/session source of truth with scoped queries by event, team, session, user access, and durable local JSON persistence.
- `TestCaseJSONPersistenceService`: reads and writes one JSON file per in-progress test case under Application Support and groups submitted snapshots by team.
- `SubmissionSnapshotService`: creates immutable submitted stage snapshots.
- `RecheckService`: derives and updates recheck items from failed test cases.
- `AccessibilityAuditSupport`: centralizes identifier conventions for tests without leaking test logic into views.

### Persist Test Cases as Application Support JSON

Decision:
- In-progress test case drafts are persisted as individual JSON files in `FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)`.
- The storage layout is scoped by event, team, session, stage, and test case so draft state can be restored after app relaunch without leaking between teams.
- Submitted stage/test case snapshots are immutable JSON records stored in a team-specific submissions folder.
- A representative layout is:

```text
Application Support/
  FSAEInspectionChecklist/
    events/<event-id>/
      teams/<team-id>/
        sessions/<session-id>/
          drafts/<stage-id>/<test-case-id>.json
          submissions/<submission-id>/
            stage-snapshot.json
            test-cases/<test-case-id>.json
          rechecks/<recheck-id>.json
```

Rationale:
- One file per test case makes autosave, restore, diffing, and corruption recovery easier to reason about than one large mutable session blob.
- Application Support is the correct local app-owned location for durable operational data that should survive relaunch but is not user-facing document content.
- Team-specific folders make manual debugging and future sync/export work safer because team context is encoded in the path as well as the JSON payload.
- JSON keeps the initial storage inspectable while preserving a migration path to SwiftData, SQLite, or remote sync behind the same service boundary later.

Implementation notes:
- JSON payloads include a schema version, event ID, team ID, session ID, stage ID, test case ID, updated timestamp, step outcomes, notes, measurement values, evidence metadata, validation summary, and relevant recheck references.
- Writes should be atomic and actor-isolated.
- App relaunch restore should rebuild active session draft state from these files before coordinators present resumable teams.
- Submitted snapshot files are append-only from the user's perspective; corrections happen through recheck records and later accepted submissions, not by mutating historical snapshots.

### Build in Three Manual Validation Slices First

Decision:
1. Test Step view from mock JSONs.
2. Test Case view from mock JSONs.
3. Test Case list and stage views from bundled JSONs.

Rationale:
- Each slice is small enough to manually validate, snapshot, and unit test.
- The order moves from leaf detail to list composition, reducing ambiguity in models and validation.
- The flow keeps a clean worktree and gives reviewers stable checkpoints before full session behavior.

### Treat Rechecks as Failed Test Cases

Decision:
- Any failed `InspectionTestCase` becomes a `RecheckItem`.
- A recheck remains open until the team fixes the issue and a judge reviews and accepts the corrected test case.
- Sticker eligibility reads from submitted stage snapshots and open recheck state.

Rationale:
- The requested behavior maps directly to the JSON test case model.
- Failed test cases are more useful to judges and teams than failed individual UI controls because test case IDs map to rules and stage context.

### Use Feature File as Test Backbone

Decision:
- Unit, UI, and snapshot test names must reference the relevant `.feature` tags or scenario titles where practical.
- Positive, negative, and edge cases must cover start/resume, validation blocking, measurements, evidence, team switching, history, offline stages, and energized badges.

Rationale:
- The feature file is the clearest shared source for user-facing acceptance.
- It gives each agent a stable behavioral contract.

### Keep UI Tests in a Dedicated PR

Decision:
- Unit tests land with the code they prove.
- XCUITests and snapshot coverage are integrated in a dedicated PR after identifiers, navigation, and mock data hooks are stable.

Rationale:
- UI test setup can create project churn. Isolating it keeps implementation PRs reviewable and preserves a clean commit history.

### Use Agent and Skill Files as First-Class Planning Artifacts

Decision:
- PR 1 creates the plan proposal and highlights agent usage by workflow phase.
- PR 2 adds `.agents/*.md` files for Architect, Tester, Planner, Developer, and Documenter agents, with explicit skill usage.
- PR 3 adds `.skills/*.md` files for Accessibility, Concurrency Developer, SwiftUI Developer, Animation Developer, Architecture Developer, and Personas.

Rationale:
- The team wants dedicated agents and skills to guide the work. Creating them before implementation gives future task branches consistent instructions.

### Automate Feature PR Flow

Decision:
- Each major feature slice should use one feature branch and one PR by default.
- Feature branches should use a predictable name that includes the inspection-event area and feature slice, such as `codex/inspection-event-test-step`, `codex/inspection-event-test-case`, `codex/inspection-event-stage-content`, `codex/inspection-event-session-flow`, and `codex/inspection-event-ui-tests`.
- Tasks within a feature branch should be split across distinct commits. Each commit should complete a coherent task or tightly related task pair, include the relevant tests or fixture updates when practical, and avoid mixing unrelated implementation contexts.
- Task branches should be created only when a feature PR grows across too many file contexts or review concerns. Examples include separating model/service changes from large SwiftUI refactors, Xcode project churn, generated fixtures, or documentation-only follow-ups.
- When task branches are needed, they should branch from the active feature branch and use a nested name such as `codex/inspection-event-test-step-models` or `codex/inspection-event-session-flow-rechecks`.
- Prefer a single PR per major feature. Task branches should be squash-merged into the feature branch before the feature PR is submitted or updated for review.
- PR descriptions should reuse the PR 1 structure:

```md
## Summary

<Brief feature outcome and why it matters.>

## Scope

- <Primary code, test, fixture, documentation, and accessibility changes.>

## Notes

- <Design decisions, known limitations, follow-up slices, or review context.>

## Validation

- `<test or validation command>`
- <Manual validation notes mapped to feature scenarios where relevant.>
```

Rationale:
- A feature branch per major feature keeps implementation review centered on one useful product outcome.
- Task-sized commits make reviewer history useful without forcing every task into its own PR.
- Task branches keep large features workable without forcing every internal split to become a long-lived public PR.
- Reusing PR 1's description format makes each PR easy to scan and keeps validation visible.
- Squash-merging task branches into the feature branch preserves a readable history while allowing incremental development.

## Risks / Trade-offs

- [Risk] The current JSON schema does not encode every validation policy, such as required evidence or measurement ranges. -> Mitigation: add mock policy fixtures first, then introduce explicit metadata extensions only through reviewed specs.
- [Risk] Coordinators can become too broad if every screen action is routed upward. -> Mitigation: keep coordinators focused on flow and intents; keep validation and persistence in services.
- [Risk] Accessibility identifiers can drift from localized labels. -> Mitigation: identifiers must be stable constants separate from display strings and covered by XCUITests.
- [Risk] Snapshot tests can be brittle across simulator/runtime changes. -> Mitigation: limit snapshots to high-value states and keep them in the dedicated UI-test PR.
- [Risk] Multi-agent documentation can become decorative. -> Mitigation: each agent file must list responsibilities, required inputs, expected outputs, and phase ownership.
- [Risk] Recheck state can conflict with immutable submission history. -> Mitigation: submitted snapshots remain immutable; rechecks create review records that reference the failed test case and later accepted state.
- [Risk] Feature PRs can become too broad if models, services, views, fixtures, tests, and docs all churn at once. -> Mitigation: split work into task-sized commits first, then use short-lived task branches only when review context remains mixed, and squash those branches back into the feature branch.

## Migration Plan

1. Add planning artifacts in PR 1 without changing app behavior.
2. Add `.agents/*.md` in PR 2, including each agent's role, required inputs, outputs, and skill references.
3. Add `.skills/*.md` and persona files in PR 3.
4. Implement the Test Step view slice with mock JSON fixtures, models, coordinator intent tests, view helper tests, accessibility identifiers, and localized string enums.
5. Implement the Test Case view slice by composing steps and validation summaries.
6. Implement the Test Case list and stage views by loading bundled JSON through `InspectionContentService`.
7. Add session selection, active team routing, Application Support JSON persistence, submissions, and rechecks incrementally after the stage list is stable.
8. Add XCUITests and snapshot tests in a dedicated PR.
9. Add step-view and general UX follow-up work for camera evidence capture, egress stopwatch timing, and inspection ergonomics after the core flow is stable.

Rollback strategy:
- Planning PRs can be reverted independently.
- Implementation feature branches should be squash-merged into the target branch so a failing slice can be reverted without disrupting later planning artifacts.
- Implementation tasks should be committed separately on the feature branch so each completed task has a reviewable checkpoint before the final feature PR is prepared.
- Short-lived task branches should be squash-merged into their parent feature branch before the feature PR is finalized.
- Services should keep mock JSON fixtures available to restore manual validation even if bundled JSON loading fails.

## Open Questions

- What authentication shape should replace the initial mock login: local judge profile, event-provided credentials, or a future remote service?
Answer:
- Use a local judge profile for now.
- Keep `AuthenticationService` as an async mock boundary so event-provided credentials or a future remote service can replace the local profile later without changing the inspection flow.

- Should evidence remain metadata-only for the first full workflow, or should camera/file picker integration be included before recheck review?
Answer:
- Keep evidence metadata-only for the first full workflow.
- Use a temporary "Add fake attachment" action that creates `EvidenceAttachmentMetadata` records without camera, photo library, file picker, or storage integration.

- Should recheck review require the same judge, any judge, or a lead judge role?
Answer:
- Make recheck review policy judge-selectable per recheck or session policy.
- Support at least two policy values initially: a specific judge and any judge.
- Defer lead judge role enforcement until role-based access is introduced.

- Where should finalized sticker records live once sticker eligibility is achieved?
Answer:
- Store finalized sticker records with the inspection event data and expose them through applicable team views.
- Surface sticker status in team-level inspection event submissions/history so judges can trace eligibility back to submitted stages and resolved rechecks.

- Which snapshot testing library should be adopted for Swift 6 once the test target is introduced?
Answer:
- Adopt `pointfreeco/swift-snapshot-testing` for the dedicated UI test and snapshot PR.
- Rationale: it supports Swift Package Manager, Swift Testing and XCTest-style usage, image snapshots, textual snapshots, JSON/property-list snapshots, and custom strategies. Swift Package Index currently reports release `1.19.2`, Swift 6.0 through 6.3 build compatibility, and zero data race safety errors.
- Use it only from test targets. Start with a narrow set of high-value SwiftUI states: test step, test case, stage list, validation blocked, recheck required, and sticker eligible.
- Pin the package with an up-to-next-major requirement from the latest compatible release available when the UI-test PR starts.
