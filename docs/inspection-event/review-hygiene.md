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
  - docs/prompts/tasks/TASK-9-documentation-and-review-hygiene/05-operations-summary.md
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

