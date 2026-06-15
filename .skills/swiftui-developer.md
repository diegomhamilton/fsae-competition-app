---
name: SwiftUI Developer
domain: inspection-event
status: active
owners:
  - Developer
  - Tester
  - Documenter
---

# SwiftUI Developer Skill

## Purpose

Guide SwiftUI implementation for inspection event screens with composable views, structured localizable `Strings` enums, previews, and accessibility modifiers.

## Use When

- Refactoring `SessionSelectorView`, `ActiveTeamDashboardView`, `FullStageView`, `StepOverviewView`, or `TeamSwitchConfirmationView`.
- Building test step, test case, stage list, validation, recheck, or sticker eligibility components.
- Adding visible text, accessibility text, previews, or view helper logic.

## Required Inputs

- Current SwiftUI file and design system conventions.
- Architect boundary note for the current slice.
- Accessibility requirements from `.skills/accessibility.md`.
- Tester unit and UI coverage expectations.

## Implementation Checklist

- Keep Views as value views focused on rendering, user intents, accessibility, and small local UI state.
- Move workflow decisions to Coordinators and business rules to Services.
- Break complex screens into small components only when it improves readability or test seams.
- Define user-visible text and accessibility text in structured per-file `Strings` enums.
- Keep stable accessibility identifiers separate from localized labels.
- Add previews for representative states such as pending, passing, failing, blocked, recheck required, and sticker eligible where practical.
- Make validation summaries, measurements, evidence controls, safety badges, and submit actions testable by identifiers.
- Avoid animation or visual states that hide required information from VoiceOver.

## Expected Outputs

- Composable SwiftUI views that render from domain-backed state.
- Structured `Strings` enums for visible and accessibility copy.
- Preview states that support manual review.
- View helper tests for presentation logic when the logic is nontrivial.

## Agent Usage

- Developer uses this skill during SwiftUI implementation.
- Tester uses this skill to identify view helper, preview, identifier, and snapshot seams.
- Documenter uses this skill to explain SwiftUI and localization conventions.
