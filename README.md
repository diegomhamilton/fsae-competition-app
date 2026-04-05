# FSAE Inspection Checklist

An iOS app for conducting **Formula SAE Electric Vehicle technical inspections**. Inspectors walk through all official FSAE inspection stages, recording pass/fail verdicts and notes against each test case with full rule references.

---

## Features

- **6 inspection stages** covering the full FSAE EV technical inspection sequence
- **Unified test case model** — every item, whether a single requirement or a multi-step dynamic test, follows the same structure
- **Typed test steps** — each step is tagged as a requirement, instruction, precondition, or note, and rendered distinctly in the UI
- **Pass / Fail / N/A verdicts** per test case with optional inspector notes
- **Safety badges** — dynamic test items (EV101–EV120) carry a visible "CAUTION: ENERGIZED" badge
- **Progress tracking** with a per-stage completion ring
- **Offline-first** — all checklist data is bundled in the app; no network connection required

---

## Inspection Stages

| # | Stage | Items |
|---|-------|-------|
| 1 | Garage Inspection | Driver equipment, fire extinguishers, wet tires |
| 2 | Body Inspection | Bodywork, harness, aerodynamics, driver fit |
| 3 | Chassis Inspection | Structure, suspension, brakes, SES items |
| 4 | EV Inspection | Full electrical system — 120 items including accumulator, charger, shutdown circuit, dynamic tests |
| 5 | Egress Test | Timed driver exit procedure |
| 6 | Rain Test | IMD validation and water spray procedure |

---

## Architecture

The app follows a **Model / Service / ViewModel / UI** layered architecture using SwiftData for persistence.

```
FSAEInspectionChecklist/
├── Models/
│   ├── InspectionTemplate.swift    — one per inspection stage (seed data)
│   ├── InspectionSection.swift     — grouping within a stage
│   ├── TestCase.swift              — a single inspectable item
│   ├── TestStep.swift              — typed step within a test case
│   ├── InspectionSession.swift     — an active inspection event
│   └── TestCaseResult.swift        — verdict per test case per session
│
├── Services/
│   ├── InspectionSeedService.swift     — loads bundled JSON into SwiftData on first launch
│   ├── InspectionSessionService.swift  — creates/fetches/deletes inspection sessions
│   └── TestCaseResultService.swift     — reads and writes per-item verdicts and notes
│
├── ViewModels/
│   ├── ActiveSessionViewModel.swift        — session creation and stage progress
│   ├── InspectionStageViewModel.swift      — section/item listing and sorting
│   └── TestCaseDetailViewModel.swift       — step display and verdict entry
│
├── UI/
│   ├── Screens/
│   │   ├── ActiveSessionView.swift     — entry point; lists all stages with progress
│   │   ├── InspectionStageView.swift   — items list for one stage
│   │   └── TestCaseDetailView.swift    — step viewer, verdict picker, notes editor
│   └── Components/
│       ├── StageCardView.swift     — progress ring + stage title row
│       ├── TestCaseRowView.swift   — item row with status icon and badges
│       └── TestStepRowView.swift   — single step rendered by type
│
└── Resources/
    └── Seed/
        ├── 01_garage_inspection.json
        ├── 02_body_inspection.json
        ├── 03_chassis_inspection.json
        ├── 04_ev_inspection.json
        ├── 05_egress_test.json
        └── 06_rain_test.json
```

### Data Model

```
InspectionTemplate  ──< InspectionSection  ──< TestCase  ──< TestStep
                                                   │
InspectionSession   ──< TestCaseResult  >──────────┘
```

- **Templates, sections, test cases, and steps** are read-only seed data loaded once from bundled JSON.
- **`InspectionSession`** and **`TestCaseResult`** are the only user-writable records. One `TestCaseResult` is created per test case when a session starts, with an initial status of `.pending`.

### TestStep types

| Type | Rendered as |
|------|-------------|
| `.requirement` | Primary body text |
| `.instruction` | Numbered action step |
| `.precondition` | Highlighted prerequisite block |
| `.note` | Dimmed callout |

---

## Seeding

Checklist data is sourced from CSV files in `InspectionCSV/` and pre-transformed into the 6 JSON files under `Resources/Seed/`. On first launch, `InspectionSeedService` loads these into SwiftData. The seed is version-gated via `UserDefaults` and will not re-run unless the version number is incremented.

To update checklist content, edit the seed JSON files and bump `seedVersion` in `InspectionSeedService.swift`.

---

## Requirements

- iOS 17+ / macOS 14+
- Xcode 15+
- Swift 5.9+

No third-party dependencies.

---

## Testing

Unit tests are written using **Swift Testing** (`import Testing`) against an in-memory `ModelContainer`. See [`unit_test_plan.md`](unit_test_plan.md) for the full list of 73 scenarios across 6 test suites.

```
FSAEInspectionChecklistTests/
└── (tests TBD — see unit_test_plan.md)
```

---

## Project files reference

| File | Purpose |
|------|---------|
| `InspectionCSV/` | Source CSV files from the FSAE official inspection sheets |
| `unit_test_plan.md` | Full unit test plan — 73 scenarios across 6 suites |
