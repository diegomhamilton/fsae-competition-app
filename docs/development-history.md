---
title: Development History — Technical Inspection Event
domain: meta
status: active
owners: [documenter-agent]
doc_hooks:
  upstream: [.git/logs/HEAD, openspec/changes/technical-inspection-event-development-plan/tasks.md, docs/prompts/tasks/]
  downstream: [docs/README.md, CLAUDE.md]
---

# Development History

Knowledge-base digest of how the FSAE Competition App (technical inspection event) was built, reconstructed from the git reflog, the OpenSpec 8-phase roadmap (`openspec/changes/technical-inspection-event-development-plan/tasks.md`), and the SPDD prompt-run index under `docs/prompts/tasks/`.

The app was built as a sequence of vertical feature slices — **test step → test case → stage → session/submission** — each mapped to a numbered OpenSpec phase, each delivered through task branches folded into feature branches and merged to `develop` via PRs.

## Timeline of Development Phases

All dates are June–July 2026, inferred from reflog timestamps (`steer/review_plan_june_24th` anchors June 24).

### Phases 1–3: Planning, Agents, Skills/Personas (mid-June)
- Branch `implement-open-spec-pattern` (~June 14): OpenSpec fixtures, Gherkin `.feature` acceptance scenarios (`inspection_event_use_cases.feature`), and answers to open plan questions.
- Branch `add-github-workflow`: instructions to split work into different PRs — the origin of the branching/PR convention below.
- Roadmap phases 1 (planning PR), 2 (`.agents/` files: architect, tester, planner, developer, documenter), and 3 (`.skills/` and persona files) are all complete.

### Phase 4: Test Step Slice (mid-June)
- Branch `codex/inspection-event-test-step-tests` (~June 14): unit tests fixed to conform to the model, manual validation recorded, a discovered bug fed back into the plan.
- All 4.x tasks complete: `InspectionTestStep`/`InspectionOutcome`/`MeasurementValue` models, mock JSON fixtures, async fixture loader, test-step view refactor, accessibility identifiers, manual validation (4.7).

### Phase 5: Test Case Slice (~June 16–23)
- Branch `create_prompts_for_spdd` (~June 16): SPDD prompt templates introduced; task 5.0 (notes keyboard dismissal bug) fixed on `codex/fix-notes-keyboard-dismissal` as a separate PR.
- Fan-out of per-task branches: `codex/task-5.1-test-case-model-tests`, `codex/task-5.2-test-case-fixtures`, `codex/task-5.3-test-case-models`, `codex/task-5.4-validation-service`, `codex/task-5.5-coordinator-tests`, `codex/task-5.6-test-case-view`, `codex/task-5.7-test-case-validation`. Prompt-run commits were cherry-picked between task branches to keep each branch's scope clean.
- ~June 23: `InspectionValidationService` implemented and refactored to per-issue handlers (5.4); coordinator tests landed (5.5, dropping the premature UI test target); test-case view merged (5.6).
- **5.7 (manual validation of the Test Case view against `.feature` cases) is the only unchecked item in Phase 5.** Its branch was created but no commits landed.

### Phase 6: Test Case List and Stage Slice (~June 24)
- Branch `codex/inspection-event-stage-content` (June 24): test plan, bundled-resource path fix, unit-test fixes.
- Plan checkpoint on `steer/review_plan_june_24th` (local storage plan update).
- Feature branch `feature/task_6_test_case_stage` with task branch `codex/task-6.4-stage-content` rebased onto it (`FullStageView` rendering real stage content). All 6.x tasks complete, including manual validation of Garage, EV, Egress, and Rain stage JSON (6.7).

### Phase 7: Session and Submission Flow Foundation (~June 24–29)
- Branch `codex/task-7-persistence`: TASK#7.2–7.4 test-case JSON draft persistence (actor-isolated, Application Support folder tree), TASK#7.5 team submission snapshots, plus an actor-isolation design note split onto `codex/actor-isolation-design-note`.
- Feature branch `feature/task-7-validation` (June 26–29) assembled the coordinator task branches by merge: `codex/inspection-event-session-flow-7-6-coordinators`, `...7-7-inspection-event-store`, `...7-8-coordinator-backed-views`, `...7-9-submission-snapshot-service`; then draft persistence instrumentation and coordinator–event-store linking.
- 7.10–7.12 (recheck service, sticker eligibility, end-to-end manual validation) were **moved to Tentpole 2 / Phase 10** rather than implemented here.

### Phase 9 and process work: Tentpoles, Organization, Bug Fixes (June 29 – July 5)
- `codex/spdd-tentpole-prompts` (June 29): SPDD prompts reorganized into tentpoles 0–4 → **PR #58** ("Organize SPDD prompts into tentpoles"). See `docs/prompts/tasks/README.md` for the tentpole index.
- `codex/inspection-event-organization` (June 29–30): behavior-neutral source reorganization → **PR #59** ("Organize inspection event source directory"); a follow-up-plans breakdown commit was later reverted (July 4–5).
- July 5 bug-fix branches: `codex/fix-55-sync-test-case-picker` → **PR #61** ("Fix test case picker draft sync"); `codex/fix-56-dashboard-stage-status` → **PR #62** ("Fix dashboard stage status from drafts").
- **PR #63** ("Add Mutation tests workflow and expand coverage after gaps indicated by tests") is the current `develop` HEAD.
- (PR #60 does not appear in the local reflog; it was likely merged directly on GitHub.)

## Current State

**Complete**
- Phases 1–4 fully (planning, agent files, skills/personas, test step slice).
- Phase 5 except task 5.7.
- Phases 6 and 7 fully (stage content; session/submission foundation, with 7.10–7.12 deferred to Phase 10 by design).
- Phase 9 fully (documentation frontmatter, architecture report, tutorials, PR template hygiene, Tentpole 3 organization passes: `Common/UI`, `AppCoordinators.swift` split, `ContentView.swift` split).
- Recent hardening: mutation-testing workflow and coverage expansion (PR #63).

**Pending**
- **Task 5.7** — manual validation of the Test Case view with mock JSONs (positive/negative/edge cases from the `.feature` file).
- **Phase 8 (entirely)** — dedicated UI test and snapshot PR: launch fixtures, UI automation for the full judge flow, identifier-based accessibility assertions, snapshot tests, coverage-to-scenario documentation.
- **Phase 10 (Tentpole 2)** — local stored judge UX follow-up, including the relocated 7.10 `RecheckService`, 7.11 sticker eligibility, 7.12 end-to-end manual validation, plus UX polish, camera evidence, and egress stopwatch timing.
- **Phase 11** — parking lot (token-usage process review, EV inspection enhancements).

## Branching / PR Workflow Convention

Observed consistently in the reflog and codified in roadmap rules 9.5–9.6:

1. `develop` is the integration branch; it only ever advances by `pull: Fast-forward` after PRs merge remotely (squash-merge on GitHub, per the planner-agent convention).
2. One **feature branch and one PR per major feature** by default (`feature/task_6_test_case_stage`, `feature/task-7-validation`); split into **task branches** (`codex/task-N.M-<slug>`) only when file changes or review context grow too broad.
3. Task branches are folded back into their feature branch by merge (Phase 7: 7.6–7.9 merges) or rebase (Phase 6: `codex/task-6.4-stage-content` rebased onto `feature/task_6_test_case_stage`); cherry-picks keep prompt-run commits on the right task branch (Phase 5).
4. Bug fixes get their own short-lived PRs referencing issue numbers (`codex/fix-55-...` → PR #61, `codex/fix-56-...` → PR #62), matching task 5.0's "separate PR" precedent.
5. Each task or tightly related pair gets its own commit (reviewable checkpoints), and PRs use the PR 1 description template (`Summary`, `Scope`, `Notes`, `Validation`) with manual validation notes.
6. Every implementation slice is preceded by SPDD prompt runs stored under `docs/prompts/tasks/TASK-N-*/` (chain: requirements → entities → approach → structure → operations → norms → safeguards), grouped by tentpole (see `docs/prompts/tasks/README.md`).

Recent PR ledger: #58 tentpole prompt organization, #59 source organization, #61 picker draft-sync fix, #62 dashboard stage-status fix, #63 mutation tests workflow.
