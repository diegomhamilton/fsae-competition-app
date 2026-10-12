---
title: Simplified inspection UI
tags: [fsae, ios, ui, implementation]
---

# Simplified inspection UI

Open this folder as an Obsidian vault. Start with [[Plan.canvas|the vertical phase plan]]. Every phase replaces a predecessor with a focused component, then captures the resulting app for review.

The judge's path is **queue → focused test → review**. During execution, show the vehicle, current test, essential criteria, required input, and the next action. Keep the queue prominent, details in the top toolbar, and optional or exceptional actions under **+**. Successful autosave stays quiet; saving failures remain actionable.

## Delivery phases

1. [[Phases/00-workflow-and-baseline|Workflow and baseline]]
2. [[Phases/01-focus-context-and-details|Focus context and details]]
3. [[Phases/02-result-input-and-additions|Result input, +, and autosave]]
4. [[Phases/03-queue-and-review-return|Queue and review return]]
5. [[Phases/04-final-checks-and-pdf|Final checks and snapshot PDF]]

[[Workflow/Build-and-snapshot-workflow|Build and snapshot workflow]] · [[Workflow/Learnings-from-ios-bass-app|Evidence from ios-bass-app]] · [[Snapshots/README|Snapshot index]]

## Review rules

- Each feature has its own UI component. Remove its predecessor in the same implementation commit.
- Each task has actual simulator snapshots and a checkpoint note tied to the implementation commit.
- Capture normal input and changed states; include error or recovery states where the task changes them.
- The result component is defined by its behavior. It need not be forced into exactly three internal states.
- Preserve session switching as disabled. Keep deferred concurrency work outside this redesign.
- The final PDF includes the task snapshots, captions, and validation limits.

The design source is `../simplified-ui-redesign-plan.md`. The implementation authorization is the user's **Start!** request of 12 October 2026.
