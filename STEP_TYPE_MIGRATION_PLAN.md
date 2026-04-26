# Step Type Migration Plan

## Goal

Normalize `TestStep.type` so the app can support:
- clear inspector guidance in sequential mode,
- attachment requirements per step,
- consistent reporting and future analytics.

Current source data in seed JSON files contains 280 total steps across 4 step types:
- `requirement`: 209
- `instruction`: 53
- `precondition`: 14
- `note`: 4

## Proposed normalized step type definition (v2)

We will evolve the model from broad content labels to behavior-oriented step types:

| v2 type | Purpose | Required fields | Optional fields |
|---|---|---|---|
| `gate` | Must be true before executing test actions. | `content` | `ruleRef`, `evidencePolicy` |
| `action` | Inspector/team action to perform during a test. | `content` | `expectedOutcome`, `evidencePolicy` |
| `check` | Verifiable compliance statement. | `content` | `ruleRef`, `expectedValue`, `evidencePolicy` |
| `context` | Non-blocking note, caution, or logistics info. | `content` | `severity` |
| `measurement` *(new)* | Numeric/boolean observation with explicit unit or threshold. | `content`, `expectedValue` | `unit`, `tolerance` |
| `evidence` *(new)* | Explicit attachment request (photo/doc/video). | `content`, `evidencePolicy` | `requiredCount`, `allowedMimeTypes` |

Notes:
- `measurement` and `evidence` are additive types for upcoming attachment/history work.
- Existing UI can still render these by grouping into existing icon/color families until dedicated UI is added.

## Migration strategy (breaking change by design)

This is an unreleased project, so we intentionally **do not preserve legacy step type values**.
We migrate source data and code directly to v2.

### Phase 0 — Inventory and schema decision (done)
1. Inventory seed usage of current types.
2. Define v2 taxonomy and canonical meanings.

### Phase 1 — Hard migration to v2 (done)
1. Replace all legacy seed values with canonical v2 values:
   - `requirement -> check`
   - `instruction -> action`
   - `precondition -> gate`
   - `note -> context`
2. Update `TestStepType` enum to v2 values only.
3. Make seed decoding strict (`SeedTestStep.type: TestStepType`) so invalid/legacy values fail fast.
4. Bump seed version to force reseeding in development.

### Phase 2 — Semantic enrichment (next)
From existing `check` and `action` steps, progressively promote entries into richer types:
- `check -> measurement` when content includes a quantifiable threshold or required value.
- `action/check -> evidence` when the step should capture an attachment for audit trail.

### Phase 3 — UI and result model updates
1. Update row rendering (icon/color/badges) for v2 types.
2. Add per-step evidence requirement UI.
3. Persist structured outcomes for `measurement` values and evidence artifacts.

### Phase 4 — Validation and cleanup
1. Validate all seed files decode with no unknown step types.
2. Keep strict type validation in seed import.

## Mapping status

### Legacy-to-v2 direct mapping (completed)

| Legacy type | v2 canonical type | Reason |
|---|---|---|
| `requirement` | `check` | Most entries are compliance statements to verify. |
| `instruction` | `action` | Imperative inspection/test procedure steps. |
| `precondition` | `gate` | Preconditions must pass before running procedure. |
| `note` | `context` | Supplemental/non-blocking guidance. |

### Early promotion rules (draft) for richer mapping

Use these deterministic heuristics to start promoting entries:
1. Promote to `measurement` if content contains explicit values/threshold cues:
   - examples: `mm`, `sec`, `kW`, `°`, `min`, `max`, `must be <=`, `must be >=`.
2. Promote to `evidence` if content implies capture/record/proof:
   - examples: `Record`, `Test report must be provided`, `Datasheets`, `must be sealed`.

These rules are intentionally conservative to avoid misclassifying critical steps.

## Risks and mitigations

- **Risk:** semantic drift from rulebook intent.  
  **Mitigation:** require reviewer sign-off for all promoted `measurement`/`evidence` mappings.
- **Risk:** local dev installs with old seeded data may need reset.  
  **Mitigation:** seed version was bumped; reset app data if stale model data remains.
- **Risk:** UI regressions with added types.  
  **Mitigation:** default unknown/new types to neutral rendering until full UI rollout.
