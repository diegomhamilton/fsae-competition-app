---
name: ios-scaffold
description: Scaffolds a complete vertical slice for a new SwiftData entity in an iOS project following a Model / Service / ViewModel / UI layered architecture. Creates all layer files and registers the model. Use when user says "scaffold a new entity", "add a new model", "create a new feature", "add [EntityName] to the app", or wants to extend the app with a new domain object.
metadata:
  author: dmh
  version: 1.0.0
  category: ios-development
---

# iOS Scaffold

Scaffolds a complete vertical slice for a new SwiftData entity following the project's layered architecture.

## Instructions

### Step 1: Confirm entity details

Before creating any file, ask the user:
- Entity name (PascalCase, e.g. `InspectionSection`)
- Properties: name, Swift type, optional or required
- Relationships to existing models (if any)

Do not proceed until confirmed.

### Step 2: Create the vertical slice

Consult `references/architecture.md` for the project's source layout and exact code patterns for each layer. Create files in this order:

1. **Model** — `@Model` class with confirmed properties + `createdAt: Date`
2. **Service** — CRUD methods wrapping `ModelContext`
3. **ViewModel (List)** — `@Observable`, mutation methods, `errorMessage: String?`
4. **ViewModel (Detail)** — `@Observable`, item-level mutations, `errorMessage: String?`
5. **Screen (List)** — `@Query` for reactive reads, `NavigationStack`, lazy `.task` service config
6. **Screen (Detail)** — detail layout, lazy `.task` service config
7. **Row Component** — list row with primary and secondary text

### Step 3: Register the model

Add `{Entity}.self` to the app's `ModelContainer` schema.

## Rules

- Never create files before Step 1 is confirmed
- Use `@Observable` — never `ObservableObject`
- `@Query` lives in Views for reactive reads; ViewModels handle mutations only
- Configure services lazily via `.task` — never in `init`
- All `ModelContext` operations are implicitly `@MainActor`
- Do not add properties or relationships beyond what the user explicitly confirmed
- Use Swift Testing framework if tests are requested — never XCTest

## Examples

**User:** "Scaffold an InspectionSection entity"
→ Ask for properties → confirm → create 7 files → register model.

**User:** "Add a VehicleRule model with title and a status enum"
→ Confirm enum cases → create full slice.

## Common Issues

**App crashes at launch:** New model not added to the `Schema` array in the app entry point.

**Relationship not cascade-deleting:** Add `@Relationship(deleteRule: .cascade)` on the parent side.
