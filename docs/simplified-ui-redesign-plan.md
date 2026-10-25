# Simplified inspection UI — reviewed design and implementation

Updated: 2026-10-12
Branch: `simplified-ui-redesign`
Phase: implementation complete; final validation and artifact delivery on 2026-10-12.

## Current snapshot

- `9a95d7a`: queue/focus/review UI implementation and focused validation tests.
- `96f0f5c`: signing settings, committed separately at the user's request.
- `102e6d9`: manual-validation task-list update, committed at the user's request.
- The screenshot has 21 labeled elements: 12 controls and nine text/status blocks. The combined vehicle/progress line contains three facts; counting those separately yields 23 elements. Decorative icons and the phone status bar are excluded.

## Judge priorities

Keep the vehicle, current test, essential criteria, required input, and next action clear. Show safety warnings whenever applicable. Make progress quiet and hide routine successful autosave status. Give the test queue a prominent standalone entry rather than bury it in an information card or secondary menu. Reveal required measurements, failure notes, or evidence when needed. Put View details in the top toolbar. Move optional inputs, early review, and exceptional actions behind secondary access. Unanswered tests should be neutral rather than display repeated blocking errors.

## User-directed result component

Combine Pass, Fail, and Save & next into one component. Its result input depends on the step: outcome selection, unit measurement, or photo/evidence input as supported by the step's requirements. A + button sits alongside the component in a horizontal row and provides optional notes/evidence and the options currently under More actions.

Behavior-driven progression (the implementation need not have exactly three states):

1. Input: show the required result controls and a neutral status.
2. Ready: once required input is valid, replace the status with Save & next test. Keep a concise result summary and a way to edit it rather than retain a competing set of result buttons.
3. Saving/confirmation: replace the action with saving feedback, briefly confirm success, and open the next test. On failure, retain the result and offer retry without advancing.

Autosaved draft values and a confirmed result are different concepts. The action must wait for required fields and persistence. A failure outcome must reveal its required notes before the component becomes ready. Photo capture here is a design requirement; the existing app's mock attachment action is not real capture.

Implementation follows the official schema: measurements supplement outcome when required; photo-only input does not invent an outcome. Valid input becomes a concise editable summary and the primary save action.

## Latest element decisions from human review

- Test queue (11): prominent, directly accessible, and separate from vehicle/progress/save information. Do not place it inside the + menu.
- Saved on this device (7): hide during normal operation. Show an actionable save failure with retry. The result component can still show transient Saving feedback to prevent duplicate confirmation and briefly confirm successful advancement; do not add a persistent saved badge.
- View details (8): top toolbar access to full instructions, rules, and references.
- Review results (12): early review remains available through +; review must have an explicit Back to test action restoring the same vehicle, test, step, and entered values. Arriving at review automatically after the last test must also permit returning to that last test. Opening a result for correction must retain a return path to review. Previewing review never submits results.
- Step navigation (14): omit Step 1 of 1 for single-step tests; retain step navigation for multi-step cases.
- Missing-outcome message (18): show only after an attempted incomplete action, not on initial display. Keep required-field help close to the relevant input.
- Blocked (19): remove the routine badge. Show specific failure feedback only when there is an actual failure, rather than labeling an unanswered test Blocked. A recorded Fail result should show its result and required note, not imply that saving failed.
- Check/type badge (20): available only as a DEBUG option, positioned to the left of the test-case description. This does not hide safety warnings, which remain visible in normal use.
- Generic local-draft subtitle (21): remove.

## Reviewed layout now implemented

1. Top toolbar: a labeled Test queue entry on the leading side, View details on the trailing side. Keep this row separate from the context line.
2. Context: current test name, then vehicle identity and quiet test progress. Do not repeat a large stage heading.
3. Task: the essential test description/criteria, plus any applicable safety warning. A DEBUG-only type badge may precede the description.
4. Result: the adaptive result component alongside +. Required measurements, failure notes, or evidence appear here only when needed by this test.
5. Failure feedback: an inline message with a corrective action only when needed. No persistent successful-save label, routine Blocked badge, or initial validation error.

The + menu includes notes/evidence, existing exceptional actions, and early review. Test queue and View details remain independently visible. Session navigation and the dense overview belong outside the execution screen.

The user authorized this layout for implementation on 2026-10-12.

## Deferred and excluded work

- Concurrency cleanup remains deferred. Preserve `concurrency_warnings` and `codex/stash-concurrency-warnings` at `1ae3b99`. Its worktree is clean, so there are no uncommitted changes to put in a Git stash. No concurrency commit or merge was made on this UI branch.
- Session switching/reset/history is excluded from this redesign. The user disabled it because it was not working properly. Preserve the existing branch/worktree, and do not re-enable or integrate it during UI work.
- The persistence worktree was deleted at the user's request. Its existing branch history was retained; the worktree's staged rollback was not integrated.
- The three .orig merge backups were deleted at the user's request.
- Mutation test output and the copied-history file pbcopy remain local and are ignored by Git.

## Design-review folder summary

- `design_review` is a clean registered worktree at `0157377`, the source organization change associated with PR #59. It splits the app into App, Common/UI, feature folders, coordinators, and test support, with organization and review documentation. The commit is already an ancestor of this UI branch. There is no uncommitted design proposal to recover there.
- `m10-design-review` is not a registered worktree. It contains an Xcode project configuration and workspace metadata, with no Swift source or design document. Its project file matches the older signing configuration, not the newly committed development team. It does not contain a separate UI redesign.

## Implementation checkpoints

- `9832364`: build workflow, isolated fixtures, vertical Obsidian Canvas, and baseline.
- `9f62aac`: focus context, toolbar details, safety and DEBUG-only badge.
- `d0ad464`: result input/action, optional additions, real evidence storage, autosave and confirmation gates; predecessor views removed.
- `c5bb76b`: ordered queue navigation and shared confirmed-result status; old checklist removed.
- `b002245`: compact review, explicit return/correction paths, flag resolution and real draft-preserving submission; old private panels and no-op submission removed.
- `94156a5`: startup catalog restoration regression repaired; full scheme passes (138 tests / 141 cases). Release build passes.
- `dcd9f3b`: native camera and photo source chooser replacing the library-only entry; evidence actor moved into Services.

Each feature includes its task snapshots and validation note. The complete delivery evidence is in [the Obsidian vault](simplified-ui-vault/Home.md). GitHub issue #72 stays open; queue section navigation is implemented locally, while its exact content mapping and physical accessibility scenario remain to be verified. No push or GitHub issue update was performed.

Delivery: 34 accepted snapshots in `output/pdf/simplified-ui-redesign-snapshots.pdf` (36 rendered and visually checked pages), plus the native vertical Canvas in the completed vault.


## Approved follow-up - 2026-10-15

The judge accepted the dynamic interaction proposals. Prioritize transforming inputs (including an expanding note editor), preserving queue/review position, and coordinated saved/progress/next-test transitions. Include larger typography and controls and preserve the rounded queue style. The remaining accepted ideas are recorded as follow-up tasks in **11. UI Improvements**, items **11.8-11.9**, in the OpenSpec task list. [Scope, PDF page references, and acceptance criteria](simplified-ui-vault/Phases/05-dynamic-interactions.md).

This update records prioritization only; the new interaction pass is not implemented. The existing PDF and completed source checkpoints remain the reference baseline.


## Implementation scope and PR sequence - 2026-10-15

The user approved implementing improvements **1-10**, including the previously deferred large measurement input, photo previews, and whole-card review editing. Improvements **11-15 remain deferred**. The [PR and implementation plan](simplified-ui-vault/Workflow/Implementation-plan-1-to-10.md) sequences an existing-redesign foundation PR followed by three implementation PRs: focused inputs (1-4, 8-9), navigation/review continuity (5-6, 10), and next-test transitions (7). Each slice replaces predecessor components, captures its task states, and records validation. This record plans the work; no new app implementation or PR publication is included in this update.

## Native Liquid Glass buttons — 2026-10-25

Action buttons share `inspectionButtonStyle()`, which configures SwiftUI's native `.glass` button style with regular glass, an 18% color tint, a rounded rectangle with the previous Pass/Fail corner radius of 24 points, and the large control size. SwiftUI owns padding, pressed feedback, disabled appearance, and interaction behavior. The app applies this as its default; Pass/Fail override only their red/green tint. Toolbar actions, including Add Team and sheet dismissal, use the same configuration and hide the additional toolbar glass background.

Tappable navigation/review rows, photo previews, and embedded editing controls retain their content layouts. System back navigation, confirmation dialogs, and camera/photo picker controls keep platform presentation. No workflow, labels, or accessibility identifiers change.

Manual review checklist: Sessions → Add Team (toolbar and form); Team → Open stage and Complete Session (including disabled state); inspection Pass/Fail, Save & next, secondary actions, photo choices, and review actions. Confirm matching corners, readable text, and native press feedback.

Validation: generic iOS Simulator build succeeded for arm64 and x86_64; `git diff --check` passed. Visually inspected Add Team and the isolated Pass/Fail inspection fixture in the running iPhone 17 Pro simulator. Remaining interactive checklist items require manual review.

The test information action now lives in the focused test's top-right toolbar. It retains its View details label, accessibility identifier, details sheet, and saving-state guard; the test heading no longer contains a separate info control.

Follow-up: Add Team's cancellation toolbar button uses an explicit xmark symbol with the accessible Cancel label to avoid an empty icon-only toolbar presentation. The info sheet's Debug display section and step type badge now obey Internal Settings → Show debug actions (and remain excluded from release builds).

Tab-bar return fix: visibility is owned by the persistent stage navigation state, rather than the departing test destination. The bar becomes visible when the route returns to the stage queue. Added the isolated `queue-return` simulator replay with native tabs and an animated pop. The generic simulator build passed; frame inspection showed the tab bar returning during the navigation transition. User confirmed the reviewed fixes worked. No physical-device installation was performed by this chat.
