---
title: Learnings from ios-bass-app
tags: [workflow, ios, evidence]
---

# Learnings from ios-bass-app

Read-only review completed on 12 October 2026. The source project was not modified. Its root is `/Users/dmh/Documents/Personal/Projetos/Meus Projetos/ios-bass-app`.

## Workflow evidence

| Source file in ios-bass-app | What is replicated here |
|---|---|
| `.agents/skills/ios-feature-validation/SKILL.md` | Freeze the reviewed source, run targeted tests during iteration, retain one simulator, install the tested product, and record exact validation limits. |
| `.agents/skills/ios-feature-validation/references/xcode-simulator-workflow.md` | Separate build/test, boot, readiness, install, launch, and capture so failures have a clear boundary. Recheck the base simulator after XCTest. |
| `.agents/skills/ios-feature-validation/scripts/check_screenshot.swift` | Reject likely Apple boot screens before visual review. The FSAE helper is adapted from this source. |
| `.agents/skills/ios-feature-validation/scripts/checkpoint.py` | Record commit/status and read authoritative `xcresulttool` summaries. The FSAE shell helper exposes separate status and summary commands. |
| `docs/snapshots/README.md` | One folder per task/checkpoint, ordered real image files, and a README tied to the demonstrated implementation commit. |
| `.github/workflows/ios.yml` | Disable parallel testing to avoid clone-related failures; preserve result bundles and logs. CI uses its own independently discovered simulator. |
| `docs/plan/reference/delivery-model.md` | Keep each task focused on one architectural concept or user-visible behavior, compiling and reviewable independently. |
| `BassPractice/UI/AppShellView.swift` | Use deterministic launch arguments to reach real review screens without depending on manual navigation. FSAE's review fixtures are DEBUG-only and use its actual components. |
| `.obsidian/core-plugins.json` and `.obsidian/app.json` | Open a folder as a vault, enable Canvas, and link notes directly to snapshot evidence. This vault adds a vertical-only native Canvas. |

Exact source examples:

- `/Users/dmh/Documents/Personal/Projetos/Meus Projetos/ios-bass-app/.agents/skills/ios-feature-validation/SKILL.md`
- `/Users/dmh/Documents/Personal/Projetos/Meus Projetos/ios-bass-app/.agents/skills/ios-feature-validation/references/xcode-simulator-workflow.md`
- `/Users/dmh/Documents/Personal/Projetos/Meus Projetos/ios-bass-app/docs/snapshots/2026-10-05_F0-2_simplified-practice-ui/README.md`
- `/Users/dmh/Documents/Personal/Projetos/Meus Projetos/ios-bass-app/docs/snapshots/2026-10-10_simplified-ui-build/README.md`
- `/Users/dmh/Documents/Personal/Projetos/Meus Projetos/ios-bass-app/.github/workflows/ios.yml`

## Current tool route and environment

XcodeBuildMCP is unavailable in the current session. Use direct Xcode tools and identify that method accurately in each checkpoint; direct-tool success is not an XcodeBuildMCP pass. Bass's stricter repository-local MCP preference is learning material, not an additional approval gate for the user's authorized FSAE implementation.

Bass's latest CI differs from an older reference recipe: it creates an iPhone 16 Pro on iOS 26.2 and runs `-parallel-testing-enabled NO`. Its recent local checkpoint used Xcode 26.2 because the selected Xcode 26.6 installation lacked a usable iOS platform. The confirmed local developer-directory example is `/Applications/Xcode26-2.app/Contents/Developer`.

FSAE's stable build location is `/tmp/FSAESimplifiedUIDerivedData`. The retained local simulator example is `34AA36AD-2704-4759-A347-01A023DEB371` (iPhone 17 Pro, iOS 26.2). These machine-specific settings remain configurable through `FSAE_DEVELOPER_DIR`, `FSAE_DERIVED_DATA`, and `FSAE_SIMULATOR_ID`; preflight them rather than assume they exist on another computer.

## Honest snapshot claims

The Bass checkpoint explicitly separated deterministic destination rendering from native touch interaction and physical audio testing. This redesign follows the same evidence rule. A seeded review fixture demonstrates the implemented screen and state; it alone does not prove camera capture, button interaction, real-device ergonomics, VoiceOver, or persistence failure recovery.

Implementation commits replace predecessor controls at the same time as introducing each component. Subsequent checkpoint notes cite those commits; documentation and screenshots must never imply an untested later source version.

Continue with [[Build-and-snapshot-workflow|the FSAE build and snapshot workflow]].
