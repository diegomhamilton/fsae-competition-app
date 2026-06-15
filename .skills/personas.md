---
name: Personas
domain: inspection-event
status: active
owners:
  - Tester
  - Documenter
  - Planner
---

# Personas Skill

## Purpose

Use technical inspection event personas to prioritize realistic scenarios, validation language, documentation examples, and manual review notes.

## Priority Personas

- Judge: primary priority for inspection, validation, accessibility, recheck review, team switching, and submission flows.
- Student: primary priority for failed issue clarity, correction review, recheck status, and sticker readiness.

## Secondary Personas

- Professor: secondary persona for compliance, teaching, and review traceability.
- Fans: secondary persona for public-facing event clarity where relevant.
- Sponsors: secondary persona for event professionalism and status confidence where relevant.

## Persona Files

- `.skills/personas/judge.md`
- `.skills/personas/student.md`
- `.skills/personas/professor.md`
- `.skills/personas/fans.md`
- `.skills/personas/sponsors.md`

## Use When

- Drafting positive, negative, and edge tests.
- Writing manual validation checklists.
- Reviewing validation summaries, recheck language, sticker eligibility language, and accessibility labels.
- Adding tutorials or documentation examples.

## Workflow

- Start with Judge needs for every implementation slice.
- Add Student needs whenever the slice affects failed cases, rechecks, evidence, submissions, history, or sticker eligibility.
- Use Professor, Fans, and Sponsors only to broaden documentation or non-primary stakeholder impact.
- Link persona-driven examples back to `.feature` scenarios where practical.

## Expected Outputs

- Persona notes in test plans and PR validation where the persona changes scenario selection.
- Documentation examples that clarify stakeholder impact.
- Manual validation notes that confirm the priority persona flow is understandable.
