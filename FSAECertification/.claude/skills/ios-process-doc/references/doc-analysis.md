# Document Analysis Strategy

Used by `ios-process-doc` during Phase 1.

## Reading strategy by document type

### PDF / Technical specification
1. Read the full document
2. Identify section headers as potential domain areas
3. Extract tables — they often map directly to entity properties
4. Look for numbered/bulleted lists as enum candidates
5. Note explicit data types, units, or constraints

### Certification checklist
1. Top-level categories → likely `@Model` entities
2. Each checklist item → likely a child entity (e.g. `ChecklistItem`-style)
3. Pass/Fail, Yes/No fields → `Bool`
4. Numeric measurements → `Double` or `Int` with optional unit string
5. Required vs optional items → non-optional vs optional Swift properties

### Markdown / plain text spec
1. `##` headers → entity or section boundaries
2. Tables → property lists
3. Code blocks → may contain existing data shapes to match
4. Bullet lists under a heading → child relationships or enum values

## Entity extraction rules

- **Do** extract nouns with multiple properties as `@Model` candidates
- **Do** extract fixed value sets (e.g. "Pass, Fail, N/A") as Swift enums
- **Do not** create a model for a concept with only one property — use a plain property instead
- **Do not** invent properties not present in the document

## Property type mapping

| Document concept | Swift type |
|---|---|
| Free text | `String` |
| Yes/No, Pass/Fail | `Bool` |
| Whole number / count | `Int` |
| Measurement / decimal | `Double` |
| Date / timestamp | `Date` |
| Fixed set of values | `enum` (raw `String`) |
| Optional / "if applicable" | wrap in `?` |

## Ambiguity flags — always surface these in Phase 1

- Property name is unclear or maps to multiple Swift types
- Relationship direction is ambiguous (who owns whom?)
- Document uses the same term for different concepts
- A checklist item could be either a property or a child entity
- Numeric field has no clear unit or precision requirement
