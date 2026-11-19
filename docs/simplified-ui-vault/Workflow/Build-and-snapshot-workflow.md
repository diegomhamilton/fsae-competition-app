---
title: Build and snapshot workflow
tags: [workflow, ios, validation, screenshots]
---

# Build and snapshot workflow

[[../Home|Project home]] · [[Learnings-from-ios-bass-app|Source evidence]]

Use `tools/ui-validation/checkpoint.sh` from any working directory. It does not change branches, commit, or combine the entire simulator workflow into a hidden operation. Run each step and inspect its result before the next.

## Configure once

From the FSAE repository root:

```sh
export FSAE_DEVELOPER_DIR=/Applications/Xcode26-2.app/Contents/Developer
export FSAE_DERIVED_DATA=/tmp/FSAESimplifiedUIDerivedData
export FSAE_SIMULATOR_ID=07400928-689C-439C-A2A9-4734BFF9B89B
tools/ui-validation/checkpoint.sh status
tools/ui-validation/checkpoint.sh version
tools/ui-validation/checkpoint.sh destinations
tools/ui-validation/checkpoint.sh devices
```

Discover once and retain a single simulator for the checkpoint. The identifier is a local example, not a portable assumption. `FSAE_PROJECT`, `FSAE_SCHEME`, `FSAE_BUNDLE_ID`, `FSAE_APP_PATH`, and `FSAE_RESULT_BUNDLE` are also configurable. The helper prints commands with shell quoting; it never prints the entire environment.

## Focused iteration

```sh
export FSAE_RESULT_BUNDLE=/tmp/FSAESimplifiedUI-focused.xcresult
tools/ui-validation/checkpoint.sh test FSAEInspectionChecklistTests/TestCaseCoordinatorTests
```

Pass additional suite names as separate arguments. Use a fresh result-bundle path when rerunning; Xcode refuses to overwrite an existing bundle. Capture full output to a local log when needed and keep concise results in the checkpoint note.

## Final tests or build-only evidence

```sh
export FSAE_RESULT_BUNDLE=/tmp/FSAESimplifiedUI-final.xcresult
tools/ui-validation/checkpoint.sh test
tools/ui-validation/checkpoint.sh summary /tmp/FSAESimplifiedUI-final.xcresult
```

The test action builds the app. Do not run another full build solely to install it. If only build evidence is needed for an intermediate snapshot, run `checkpoint.sh build` and explicitly say tests were not run for that checkpoint. Full validation reports the authoritative completed test summary, distinguishing parameterized cases where available.

## Boot, install, and capture

```sh
tools/ui-validation/checkpoint.sh boot
tools/ui-validation/checkpoint.sh ready
tools/ui-validation/checkpoint.sh install
tools/ui-validation/checkpoint.sh launch <the actual DEBUG review arguments>
tools/ui-validation/checkpoint.sh capture docs/simplified-ui-vault/Snapshots/<task>/01-focus.png
```

The boot command skips an already booted device. Readiness is a separate required step because the Simulator window is not proof of completed initialization. Recheck after tests: XCTest may use a clone and shut down the base device. Install the tested DerivedData product. Launch uses `--terminate-running-process` and forwards supplied arguments to the app; use the exact fixtures added by the implementation rather than inventing an unsupported argument.

Capture validates boot state and runs the boot-screen checker only after the image exists. Exit `2` from the checker rejects a likely boot image; relaunch and recapture after readiness. An accepted image still requires visual inspection for correct state, clipping, stale content, and unrelated sensitive information. Stop at the first failed step and resume from the last proven boundary.

## Task checkpoint note

For each feature task, create `Snapshots/<task>/README.md` and actual ordered screenshots. Record:

- Task goal and predecessor removed in its implementation commit.
- Implementation commit and branch.
- Validation method, command/recipe, Xcode, scheme, stable DerivedData, simulator model and OS.
- One retained simulator and completed boot readiness.
- Exact tests, counts, failures, and result-bundle location where available.
- Launch arguments and screenshot captions describing what each image actually demonstrates.
- Confirmation that screenshots match the reviewed implementation and were visually inspected.
- Known limits or unfinished interaction/hardware checks.

One build/test owner controls simulator mutations while implementation is frozen. Parallel read-only review is safe; a source edit during validation requires fresh evidence. Root owns task screenshot notes and the snapshot index. Phase notes and `Plan.canvas` link to that evidence.

## Delivery

Each component's feature commit adds the component and removes its predecessor. Preserve deferred concurrency work and disabled session switching. At final delivery, refresh stale captures, render and inspect the snapshot PDF, and update phase notes with source commits and evidence links.
