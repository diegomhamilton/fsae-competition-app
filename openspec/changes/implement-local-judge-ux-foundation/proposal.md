# Implement Local Judge UX Foundation

## Why

After Task 9 organization and Task 10 design review, the first Task 10 implementation slice should make the existing local stored inspection flow feel clear and usable before adding larger completion features.

This slice focuses on Task 10.1 through Task 10.7: context clarity, prototype-copy cleanup, primary judge actions, compact step/test-case layout, actionable validation blockers, pending/incomplete semantics, and notes/evidence labels.

## What Changes

- Polish session, dashboard, stage, test case, step, and team-switch screens for a judge completing local stored inspections.
- Replace prototype copy with stable event/team/session/stage/test-case context.
- Make validation blockers actionable and persist corrections immediately to test case JSON drafts.
- Clarify incomplete required-step state separately from judge-selected outcomes.
- Improve notes and evidence labels across empty, required, present, and edit states.
- Add focused tests and manual validation for the UX foundation behavior.

## Impact

- Views and view-state helpers under the feature-owned tree will change.
- Persistence and validation service boundaries may be touched only where needed for immediate draft persistence and blocker focus.
- Camera evidence, rechecks, sticker eligibility, stopwatch timing, and broad UI automation remain outside this slice.

