---
title: "Phase 1 — Focus context and details"
phase: 1
status: complete
tags: [phase, swiftui, focus]
---

# Phase 1 — Focus context and details

[[../Home|Project home]] · [[../Plan.canvas|Vertical plan]]

## Goal

Give the judge a quiet execution screen with a prominent queue entry, top-toolbar details access, current test and vehicle, essential criteria, and applicable safety warnings.

## Tasks

- [x] Extract the focused context and instructions into dedicated UI components.
- [x] Place **Test queue** independently in the toolbar and **View details** at the top.
- [x] Keep progress quiet and omit single-step navigation.
- [x] Keep the type badge only behind a DEBUG option, to the left of the description.
- [x] Capture focus and the details return control.

## Component and predecessor

Replace the large repeated stage heading, generic local-draft subtitle, stacked context/queue/save card, routine type and Blocked badges, and single-step label in the same feature commit. Full rules and references remain accessible through details; safety warnings remain visible normally.

## Required evidence

- Focus screenshot before an outcome is entered, with no initial blocking feedback.
- Details screenshot showing full instructions or rules and an obvious return action.
- A DEBUG badge screenshot only if that optional display is demonstrated.
- Visual inspection for clipping, competing headings, control size, and contrast.

## Completion record

- Commit: the component checkpoint containing this note.
- Snapshots: [[../Snapshots/01-context-details/README|Context and details evidence]].
- Validation: direct Xcode 26.2 build passed; three images passed boot rejection and visual inspection. Result-card validation is removed in Phase 2.

Previous: [[00-workflow-and-baseline|Phase 0]]. Next: [[02-result-input-and-additions|Phase 2 — Result input, +, and autosave]].
