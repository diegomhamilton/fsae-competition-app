---
title: Inspection Event Review Hygiene
domain: technical-inspection
feature: inspection-event
status: active
owners:
  - Planner
  - Documenter
source_files:
  - openspec/changes/technical-inspection-event-development-plan/design.md
  - docs/maintenance.md
  - .github/PULL_REQUEST_TEMPLATE.md
related_scenarios:
  - Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature
---

# Inspection Event Review Hygiene

## Pull Request Description

Every implementation PR should use these sections:

```md
## Summary

<What changed and why it matters to inspection-event delivery.>

## Scope

- <Code, tests, fixtures, docs, accessibility identifiers, or source organization changed>
- <OpenSpec task IDs and feature scenarios referenced>

## Notes

- <Design decisions, known limits, deferred work, branch split context, or squash guidance>

## Validation

- `<test or inspection command>`: <result>
- Manual validation: <scenario, data, device or simulator, outcome>
- Feature scenarios: <linked tags or scenario titles>
```

The `Validation` section must include command output summaries, manual validation notes when UI behavior is touched, linked feature scenarios, and any known gaps.

## Branch Rule

Keep one feature branch and one PR per major feature by default. Use a predictable branch name such as `codex/inspection-event-stage-content` or `codex/inspection-event-docs-review-hygiene`.

Split into short-lived task branches only when the review context becomes too broad. Good split signals include more than about ten unrelated files, mixed domains such as persistence plus UI layout, Xcode project churn mixed with feature logic, or generated fixtures mixed with behavior changes.

Task branches should branch from the active feature branch and squash back into it before the feature PR is finalized. The feature PR remains the review unit unless the task branch represents a truly independent product outcome.

## Commit Rule

Split work across task-sized commits. Each completed task, or tightly related task pair, should have a reviewable checkpoint that includes its tests, fixtures, documentation, or manual validation notes where practical.

Good commit scopes:

- Add failing tests for a model/service rule.
- Implement the model/service rule that satisfies those tests.
- Move one behavior-neutral ownership boundary.
- Add one tutorial or PR hygiene document.
- Update OpenSpec task checkboxes after the implementation evidence exists.

Avoid commits that mix unrelated behavior, broad formatting, generated files, and documentation rewrites. If the commit cannot be summarized in one direct sentence, split it.

## Squash Guidance

Feature PRs may preserve task-sized internal commits while under review. Before merge, squash task branches into the feature branch and use the PR description to preserve the meaningful checkpoints, validation commands, and scenario links.


## Documentation review

Update current documentation with behavior changes. Delete obsolete phase plans, completed prompt output and old evidence collections; put remaining acceptance gaps in the active backlog/validation checklist. Store PR-specific commands and evidence in the PR rather than creating dated repository reports.

## Planning an implementation slice

Use the reusable SPDD chain below for unfinished work in the [active backlog](../../openspec/changes/technical-inspection-event-development-plan/tasks.md). Start from the [system map](../system-map.md), relevant capability spec, role guidance and behavioral scenarios. Keep decisions and acceptance requirements in maintained documentation or OpenSpec; do not commit completed prompt runs or copied chat handoffs.

Run Requirements, Entities, Approach, Structure, Operations, Norms and Safeguards in that order. Replace placeholders with the current task and preceding step’s result.

### Requirements Prompt

You are helping with SPDD for this task:

Task: `<paste task>`

Describe the essence of the requirement in one clear sentence.

Then list:

- User-visible outcome
- Acceptance source, especially `.feature` scenarios if relevant
- Required behavior
- Out of scope behavior
- Completion signal

Keep this focused on what must be true, not how to build it.

### Entities Prompt

Given this task:

Task: `<paste task>`

Identify the domain entities involved.

For each entity, describe:

- Responsibility
- Key fields or state
- Relationships to other entities
- Whether it is immutable content, mutable draft state, UI state, service state, or test fixture data

Use the project's inspection-event language: stages, sections, test cases, test steps, outcomes, measurements, evidence, validation, submissions, rechecks, sessions, teams, and judges.

### Approach Prompt

Given this task and entities:

Task: `<paste task>`

Entities: `<paste entity summary>`

Propose a high-level implementation approach.

Include:

- Files or areas likely affected
- Test-first strategy
- Existing patterns to follow
- SwiftUI / Swift 6 / Concurrency considerations
- Accessibility and localization considerations
- Manual validation path

Do not write code yet. Explain the solution shape and collaboration points.

### Structure Prompt

Given this task and approach:

Task: `<paste task>`

Approach: `<paste approach>`

Define the implementation structure.

Include:

- Models, views, coordinators, services, fixtures, and tests involved
- Dependencies between them
- Suggested commit boundaries
- Risks from coupling or ordering
- How this task fits into the current OpenSpec slice

Prefer the existing MVC + Coordinators + Services architecture.

### Operations Prompt

Given this task, approach, and structure:

Task: `<paste task>`

Structure: `<paste structure>`

Decompose this into concrete, reviewable operations.

For each operation, include:

- Exact action
- Expected files or test targets
- Verification command or manual check
- Build ownership: agent-run, user-run, or not applicable
- Manual validation notes to capture when the user will build or inspect locally
- Commit boundary and a proposed commit title of 52 characters or fewer
- Whether the operation can be committed without breaking compilation
- Done condition

Make the operations small enough for TDD and task-sized commits.

Do not build the code automatically. Specify the exact user-run build or inspection signal the user should report back, and keep the agent's verification to static review unless the user explicitly asks the agent to build.

When a task will become a PR, include the PR title in this format:

`TASK#{TASK NUMBER}: <short task summary>`

### Norms Prompt

Apply the project norms to this task:

Task: `<paste task>`

Check the proposed work against these norms:

- TDD for models, services, coordinators, and view helpers
- Swift 6 and Concurrency-first boundaries
- SwiftUI views with small local UI state only
- Structured `Strings` enums for localizable text
- Stable accessibility identifiers separate from localized labels
- Feature scenarios as acceptance backbone
- One feature branch / PR per major slice unless review context gets too broad
- PR titles must start with `TASK#{TASK NUMBER}:` using the OpenSpec task number, for example `TASK#5.1: Add test case model tests`
- Each task must be split into reviewable commits with commit titles of 52 characters or fewer
- Commits must not intentionally leave the project in a non-compiling state
- Do not build the code automatically; capture build and validation as user-run unless the user explicitly asks the agent to build
- Manual validation notes in PR description

Return any adjustments needed before implementation.

### Safeguards Prompt

Act as the SPDD safeguard reviewer for this task:

Task: `<paste task>`

Plan: `<paste operations>`

Review for:

- Scope creep
- Missing failing tests
- Accessibility gaps
- Localization gaps
- Unsafe concurrency or shared mutable state
- JSON fixture/schema assumptions
- Incomplete validation paths
- PR review risk
- Manual validation omissions

Return blockers first, then recommendations, then a final go/no-go.
