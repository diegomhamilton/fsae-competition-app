---
title: "Phase 1 — Focus context and details"
phase: 1
status: planned
tags: [phase, swiftui, focus]
---

# Phase 1 — Focus context and details

[[../Home|Project home]] · [[../Plan.canvas|Vertical plan]]

## Goal

Give the judge a quiet execution screen with a prominent queue entry, top-toolbar details access, current test and vehicle, essential criteria, and applicable safety warnings.

## Tasks

- [ ] Extract the focused context and instructions into dedicated UI components.
- [ ] Place **Test queue** independently in the toolbar and **View details** at the top.
- [ ] Keep progress quiet and omit single-step navigation.
- [ ] Keep the type badge only behind a DEBUG option, to the left of the description.
- [ ] Capture focus and the details return path.

## Component and predecessor

Replace the large repeated stage heading, generic local-draft subtitle, stacked context/queue/save card, routine type and Blocked badges, and single-step label in the same feature commit. Full rules and references remain accessible through details; safety warnings remain visible normally.

## Required evidence

- Focus screenshot before an outcome is entered, with no initial blocking feedback.
- Details screenshot showing full instructions or rules and an obvious return action.
- A DEBUG badge screenshot only if that optional display is demonstrated.
- Visual inspection for clipping, competing headings, control size, and contrast.

## Completion record

- Commit: pending
- Snapshots: pending
- Validation: pending

Previous: [[00-workflow-and-baseline|Phase 0]]. Next: [[02-result-input-and-additions|Phase 2 — Result input, +, and autosave]].
