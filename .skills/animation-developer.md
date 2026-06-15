---
name: Animation Developer
domain: inspection-event
status: active
owners:
  - Developer
  - Tester
---

# Animation Developer Skill

## Purpose

Guide small, accessible animations for inspection outcome changes, pass/fail transitions, validation correction, and smooth test step switching without reducing clarity or accessibility.

## Use When

- Adding transitions between test steps or test cases.
- Animating pass, fail, pending, blocked, recheck, or sticker eligibility states.
- Highlighting validation correction targets.
- Reviewing snapshot or VoiceOver behavior around animated states.

## Required Inputs

- Related SwiftUI view or component file.
- Accessibility requirements from `.skills/accessibility.md`.
- Feature scenario and persona context for the interaction.

## Implementation Checklist

- Keep animations brief and tied to state changes the judge needs to understand.
- Never rely on motion alone to communicate pass, fail, blocked, recheck, or sticker eligibility state.
- Preserve text, icon, shape, and VoiceOver information during and after transitions.
- Avoid animations that delay submission, validation correction, or recheck review actions.
- Respect platform reduced-motion behavior where applicable.
- Keep snapshot states deterministic by testing final stable states, not transient frames.

## Expected Outputs

- State-driven SwiftUI animations or transitions.
- Accessible labels and values that remain valid after animated changes.
- Tester notes for any reduced-motion, snapshot, or UI-test consideration.

## Agent Usage

- Developer uses this skill when introducing visual transitions.
- Tester uses this skill to ensure animation does not obscure accessibility or validation behavior.
