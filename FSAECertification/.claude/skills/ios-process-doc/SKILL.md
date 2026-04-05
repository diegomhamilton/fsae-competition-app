---
name: ios-process-doc
description: Processes input documents (technical specifications, certification checklists, PDFs, markdown files, CSVs) and translates their domain structure into Swift source changes for an iOS SwiftData project. Use when user provides a document and says "process this spec", "apply this checklist to the app", "read this document and create models", "implement this spec", or "update the app based on this file".
metadata:
  author: dmh
  version: 1.0.0
  category: ios-development
---

# iOS Process Document

Reads an input document and applies its domain structure to the project as Swift source changes.

## Instructions

### Phase 1: Read and Summarise (required — never skip)

1. Read the document at the provided path.
2. Apply the reading strategy from `references/doc-analysis.md` for the document type.
3. Produce a structured summary:
   - **Entities** — domain nouns that could become `@Model` classes
   - **Properties** — per entity: name, Swift type, optionality, constraints
   - **Relationships** — one-to-many, optional references between entities
   - **Enumerations** — fixed value sets
   - **Business rules** — validation, completion criteria, ordering
   - **Ambiguities** — anything unclear that needs user input before proceeding

4. Present the summary and wait for explicit user confirmation before continuing.

### Phase 2: Mapping Plan (required — never skip)

After Phase 1 confirmation, produce a mapping plan:
- Entities to **create** (new `@Model`) vs **update** (extend existing)
- Service methods to add or extend
- Screens and components to create or update
- Explicit list of any decisions that require user input

Present the plan and wait for explicit user approval before writing any files.

### Phase 3: Apply Changes

Once approved:
- **New entities** → follow the `ios-scaffold` skill pattern for each
- **New properties** → edit the `@Model` class and its `init`
- **New service methods** → extend the existing `*Service.swift`
- **UI changes** → update the relevant row or detail view
- **Schema** → register all new `@Model` types in the app entry point

## Rules

- Never skip Phase 1 or Phase 2 — always get sign-off before writing files
- Never invent properties or relationships not present in the source document
- Surface all ambiguities in Phase 1 — do not silently resolve them
- Prefer editing existing files over creating new ones when extending an entity
- Use Swift Testing framework if tests are requested — never XCTest

## Examples

**User:** "Process this PDF: /path/to/rules.pdf"
→ Read → summarise entities/properties → confirm → plan → approve → apply.

**User:** "Apply this checklist spec to the app"
→ Same three-phase flow starting from the provided document.

## Common Issues

**Document has no clear entities:** Ask the user to identify the primary domain objects before Phase 2.

**Ambiguous property types:** Surface in Phase 1 summary with suggested Swift types — never assume.
