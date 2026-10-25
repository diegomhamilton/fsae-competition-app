---
title: Add Team first-focus input diagnostics
domain: inspection-event
feature: session-selection
status: investigating
owners:
  - Developer
  - Tester
source_files:
  - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/SessionFlow/Views/CreateTeamSheet.swift
related_scenarios:
  - Judge creates a local team and starts its inspection session
---

# Add Team first-focus input diagnostics

## Observed behavior — 2026-10-25

On a physical iPhone running iOS 26.6.1, launched from Xcode with the debugger attached, the first taps on Team display name fail to respond promptly. Switching to Car number produces system keyboard messages, including a gesture gate timeout and a negative-width `TUIKeyplane.right` constraint. After the initial delay, the view is responsive.

PR #104's autocorrection/focus changes did not resolve the reported physical-device problem. The keyboard warnings do not establish the operation responsible for the stall. No app constraints target the system keyboard layout guide. A normal simulator interaction succeeded both before and after #104, so simulator success is not evidence of a device fix.

## Controlled comparison

Use the same checkout and the same Debug build for both runs. Do not replace another session's device build during its review. No code adds keyboard warm-up, artificial delays, hidden text fields, or UIKit constraint overrides.

1. Run the usual `FSAEInspectionChecklist` scheme with the debugger attached. Open Sessions → Add Team, tap Team display name once, enter `UFPE Racing`, move to Car number, and enter `28`. Record first-focus delay separately from subsequent switching. Cancel to avoid persisting a diagnostic team.
2. Stop the debugging session. Launch the same installed app from the iPhone Home Screen and repeat. This is the simplest comparison and requires no installation.
3. For repeatable Xcode launches, select the shared `FSAEInspectionChecklist-DeviceValidation` scheme. Its Run action uses Debug with **Debug executable disabled**. The normal scheme and test debugging are unchanged. Repeat the same steps.
4. Record whether the device was connected over a cable or network, keyboard language/type, and whether the behavior occurs only on the first keyboard use after process launch or on every sheet presentation. If testing the transport, change only that variable after the debugger comparison.

The debugger is a hypothesis, not an established cause. A responsive standalone run narrows the issue to the development execution environment; it does not prove which debugger feature or transport caused it. A standalone stall requires a main-thread trace rather than another unmeasured input workaround.

## Trace if standalone still stalls

When the physical device is available, use Instruments' Time Profiler (or the available CPU Profiler template) with the same app build. Start recording before opening the sheet; reproduce a single first-focus delay and mark its interval. Inspect the app's main-thread call tree during that interval. Keep the trace local: it may include device and application metadata.

Classify the captured work before changing code: application work or repeated SwiftUI updates; keyboard/service initialization or synchronous IPC; or layout/presentation work. Compare the first focus with a later responsive focus in the same trace. Capture the stack, duration, build commit, OS version, launch/debugger mode, and transport. A symbolic constraint breakpoint may identify where the warning is emitted, but does not by itself measure the stall and can change timing.

## Current validation limits

The shared scheme is an investigation aid, not a shipped behavior change or a confirmed fix. No physical-device action was performed while the user reviewed PR #105. Standalone and attached-device trace results remain pending.

Apple's [Understanding hangs in your app](https://developer.apple.com/documentation/xcode/understanding-hangs-in-your-app) describes analyzing the main run loop and main-thread work to establish the cause of an interaction delay.
