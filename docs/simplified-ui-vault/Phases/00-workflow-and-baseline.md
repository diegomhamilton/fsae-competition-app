---
title: "Phase 0 — Workflow and baseline"
phase: 0
status: complete
tags: [phase, workflow, baseline]
---

# Phase 0 — Workflow and baseline

[[../Home|Project home]] · [[../Plan.canvas|Vertical plan]]

## Goal

Learn the proven iOS build and snapshot workflow from ios-bass-app, retain a consistent simulator and build location, and capture the current screen before replacing components.

## Tasks

- [x] Record the active branch and baseline commit without integrating deferred work.
- [x] Confirm the Xcode version, scheme, available simulator destination, and validation tool availability once.
- [x] Create the checkpoint and screenshot helpers.
- [x] Build or test the baseline; boot, install, and launch as separate observable steps.
- [x] Capture and visually inspect the baseline execution screen.

## Component and predecessor

This is a workflow task. It changes no execution component. Its evidence becomes the comparison point for the old title, stacked queue/context/save card, status badges, separate input/action controls, and crowded secondary links replaced in phases 1–3.

## Required evidence

- Baseline screenshot with the current vehicle and test visible.
- Baseline source commit, branch, Xcode, scheme, simulator model/OS, and build/test result in its checkpoint note.
- Explicitly distinguish unavailable XcodeBuildMCP from direct Xcode validation.
- A known, stable DerivedData path and one simulator retained throughout the checkpoint.

## Completion record

- Commit: `9832364` (workflow and baseline).
- Snapshots: [[../Snapshots/00-baseline/README|baseline execution]].
- Validation: Xcode 26.2 build passed. Direct Xcode CLI fallback used because XcodeBuildMCP is unavailable. Dedicated FSAE UI Review simulator retained after rejecting a capture of an unrelated app on the earlier shared simulator.

Next: [[01-focus-context-and-details|Phase 1 — Focus context and details]].
