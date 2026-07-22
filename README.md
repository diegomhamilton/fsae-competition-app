# FSAE Inspection Checklist

An iOS app for conducting **Formula SAE Electric Vehicle technical inspections**. Inspectors select or resume a team session, walk through the official FSAE inspection stages, and record pass/fail/N/A verdicts, notes, measurements, and evidence metadata against each test case with full rule references.

This is based on the Inspection Sheet PDF document available in the `context/` folder.

---

## Documentation

- [Inspection event technical overview](docs/inspection-event/README.md)
- [Current system map](docs/system-map.md)
- [Inspection event tutorials](docs/inspection-event/tutorials.md)
- [Review hygiene and PR rules](docs/inspection-event/review-hygiene.md)
- [Tentpole 3 organization plan](docs/inspection-event/organization-plan.md)

---

## Features

- **6 inspection stages** covering the full FSAE EV technical inspection sequence
- **Unified test case model** — every item, whether a single requirement or a multi-step dynamic test, follows the same structure
- **Typed test steps** — each step is tagged as a requirement, instruction, precondition, or note, and rendered distinctly in the UI
- **Session-based judge workflow** — Sessions, Team, and Stage are the top-level landmarks, with test cases and focused step editing inside the Stage flow
- **Pass / Fail / N/A verdicts** with optional judge notes, measurements, and evidence metadata
- **Local draft persistence** — in-progress test case work is stored as scoped JSON draft files
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
