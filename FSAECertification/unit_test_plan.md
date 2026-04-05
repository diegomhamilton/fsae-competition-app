# Unit Test Plan — FSAEInspectionChecklist

All tests use **Swift Testing** (`import Testing`) with **Arrange / Act / Assert**.
Each service is tested against an **in-memory `ModelContainer`**.
ViewModels are tested with **stub/spy service doubles** passed via `configure(with:)`.

---

## 1. `InspectionSeedServiceTests`

### `extension InspectionSeedServiceTests` — Versioning

| # | Scenario | Assertion |
|---|----------|-----------|
| 1 | `seedIfNeeded` on a fresh store (version = 0) inserts templates | `InspectionTemplate` count > 0 |
| 2 | `seedIfNeeded` on an already-seeded store (version = current) does not insert duplicates | `InspectionTemplate` count equals count from first call |
| 3 | After a successful seed, `UserDefaults` seed version key equals the service's `seedVersion` constant | `UserDefaults.integer(forKey:) == 1` |

### `extension InspectionSeedServiceTests` — Template structure

| # | Scenario | Assertion |
|---|----------|-----------|
| 4 | Exactly 6 templates are seeded | count == 6 |
| 5 | Templates are seeded with the correct codes (`01_garage`, `02_body`, `03_chassis`, `04_ev`, `05_egress`, `06_rain`) | all codes present |
| 6 | Templates are ordered by `displayOrder` 1–6 with no gaps | sorted codes match expected sequence |
| 7 | Every template contains at least one `InspectionSection` | all templates: `sections.count >= 1` |
| 8 | Every section contains at least one `TestCase` | all sections: `testCases.count >= 1` |

### `extension InspectionSeedServiceTests` — TestCase content

| # | Scenario | Assertion |
|---|----------|-----------|
| 9 | EV template contains exactly 120 test cases (EV1–EV120) | count == 120 |
| 10 | Each test case has a non-empty `itemId` and `title` | no empty strings |
| 11 | Every test case has at least one `TestStep` | `steps.count >= 1` |
| 12 | Test cases EV101–EV120 all carry the `"CAUTION: ENERGIZED"` badge | `badges.contains("CAUTION: ENERGIZED")` for all |
| 13 | Test cases EV1–EV100 do not carry the `"CAUTION: ENERGIZED"` badge | badge absent for all |
| 14 | Multi-step EV item (e.g. EV101 — IMD Shutdown Test) produces at least one `.instruction` step in addition to the `.requirement` | step types include `.instruction` |

### `extension InspectionSeedServiceTests` — TestStep types

| # | Scenario | Assertion |
|---|----------|-----------|
| 15 | Egress test case (`EgressTest`) contains at least one `.precondition` step | step with type `.precondition` exists |
| 16 | Egress test case contains at least one `.note` step | step with type `.note` exists |
| 17 | Egress test case contains at least one `.instruction` step | step with type `.instruction` exists |
| 18 | Rain test case (`RainTest`) contains at least one `.precondition` step | step with type `.precondition` exists |
| 19 | Simple single-description EV item (e.g. EV1) produces exactly one step of type `.requirement` | count == 1, type == `.requirement` |
| 20 | Steps within a test case have unique, sequential `displayOrder` values starting at 1 | no duplicate orders, min == 1 |

---

## 2. `InspectionSessionServiceTests`

### `extension InspectionSessionServiceTests` — `createSession`

| # | Scenario | Assertion |
|---|----------|-----------|
| 21 | Creates a session with the provided `teamName`, `vehicleNumber`, `eventYear` | all three match the passed values |
| 22 | `createdAt` is set to a date close to `Date()` | within 2 seconds of `Date()` |
| 23 | Creates one `TestCaseResult` per seeded `TestCase` | `session.results.count == totalTestCaseCount` |
| 24 | All created results have initial status `.pending` | every result `.status == .pending` |
| 25 | Creating a second session does not delete the first | both sessions present in store |

### `extension InspectionSessionServiceTests` — `activeSession`

| # | Scenario | Assertion |
|---|----------|-----------|
| 26 | Returns `nil` when no session exists | result is `nil` |
| 27 | Returns the single session when one exists | result matches the created session |
| 28 | Returns the most recently created session when multiple exist | result matches the last-created session |

### `extension InspectionSessionServiceTests` — `deleteSession`

| # | Scenario | Assertion |
|---|----------|-----------|
| 29 | Deletes the session from the store | `activeSession()` returns `nil` after deletion |
| 30 | Cascade-deletes all associated `TestCaseResult` records | no orphaned results in store |

### `extension InspectionSessionServiceTests` — `templates`

| # | Scenario | Assertion |
|---|----------|-----------|
| 31 | Returns all seeded templates | count == 6 |
| 32 | Returns templates sorted ascending by `displayOrder` | `displayOrder` values are strictly increasing |

---

## 3. `TestCaseResultServiceTests`

### `extension TestCaseResultServiceTests` — `result(for:in:)`

| # | Scenario | Assertion |
|---|----------|-----------|
| 33 | Returns the correct `TestCaseResult` when one exists for the given `testCase` + `session` pair | returned result references the expected `testCase.itemId` |
| 34 | Returns `nil` when no result exists for a given test case in a session | result is `nil` |
| 35 | Returns `nil` when the session has results but for different test cases | result is `nil` |

### `extension TestCaseResultServiceTests` — `setStatus`

| # | Scenario | Assertion |
|---|----------|-----------|
| 36 | Sets status to `.pass` | `result.status == .pass` |
| 37 | Sets status to `.fail` | `result.status == .fail` |
| 38 | Sets status to `.notApplicable` | `result.status == .notApplicable` |
| 39 | Updates `updatedAt` to a time after the original value | `result.updatedAt > originalUpdatedAt` |

### `extension TestCaseResultServiceTests` — `setNotes`

| # | Scenario | Assertion |
|---|----------|-----------|
| 40 | Sets a non-empty string as `inspectorNotes` | `result.inspectorNotes == "some note"` |
| 41 | Passing an empty string sets `inspectorNotes` to `nil` | `result.inspectorNotes == nil` |
| 42 | Overwrites an existing note with a new value | `result.inspectorNotes == newNote` |
| 43 | Updates `updatedAt` after setting notes | `result.updatedAt > originalUpdatedAt` |

### `extension TestCaseResultServiceTests` — `progress(for:in:)`

| # | Scenario | Assertion |
|---|----------|-----------|
| 44 | Returns `(0, total)` when all results are `.pending` | `completed == 0`, `total == templateItemCount` |
| 45 | Returns `(total, total)` when all results are non-pending | `completed == total` |
| 46 | Returns correct partial count when some results are non-pending | `completed == nonPendingCount` |
| 47 | `.notApplicable` counts as completed (non-pending) | included in `completed` |
| 48 | Only counts results belonging to the given template's test cases, not other templates | count excludes results from a second template |
| 49 | Returns `(0, 0)` for a template with no test cases | both values == 0 |

---

## 4. `ActiveSessionViewModelTests`

### `extension ActiveSessionViewModelTests` — `configure`

| # | Scenario | Assertion |
|---|----------|-----------|
| 50 | After `configure`, calling `createSession` does not crash (services are wired) | no error thrown, `errorMessage` remains `nil` |

### `extension ActiveSessionViewModelTests` — `createSession`

| # | Scenario | Assertion |
|---|----------|-----------|
| 51 | On success, `errorMessage` remains `nil` | `errorMessage == nil` |
| 52 | When the service throws, `errorMessage` is populated | `errorMessage != nil` |

### `extension ActiveSessionViewModelTests` — `progress`

| # | Scenario | Assertion |
|---|----------|-----------|
| 53 | Delegates to `TestCaseResultService` and returns correct `(completed, total)` tuple | values match what the service returns |

---

## 5. `InspectionStageViewModelTests`

### `extension InspectionStageViewModelTests` — `sections`

| # | Scenario | Assertion |
|---|----------|-----------|
| 54 | Returns sections sorted ascending by `displayOrder` | sequence is strictly increasing |
| 55 | Returns empty array when template has no sections | count == 0 |

### `extension InspectionStageViewModelTests` — `testCases(in:)`

| # | Scenario | Assertion |
|---|----------|-----------|
| 56 | Returns test cases sorted ascending by `displayOrder` | sequence is strictly increasing |
| 57 | Returns only test cases belonging to the given section | no test cases from other sections included |
| 58 | Returns empty array for a section with no test cases | count == 0 |

### `extension InspectionStageViewModelTests` — `result(for:)`

| # | Scenario | Assertion |
|---|----------|-----------|
| 59 | Returns the correct `TestCaseResult` for a test case that has a result in the session | `result.testCase?.itemId == testCase.itemId` |
| 60 | Returns `nil` for a test case with no result in the session | result is `nil` |

### `extension InspectionStageViewModelTests` — `progress()`

| # | Scenario | Assertion |
|---|----------|-----------|
| 61 | Returns `(0, total)` when no items are completed in the template | `completed == 0` |
| 62 | Returns `(total, total)` when all items are non-pending | `completed == total` |

---

## 6. `TestCaseDetailViewModelTests`

### `extension TestCaseDetailViewModelTests` — `sortedSteps`

| # | Scenario | Assertion |
|---|----------|-----------|
| 63 | Returns steps sorted ascending by `displayOrder` | sequence is strictly increasing |
| 64 | Returns empty array when test case has no steps | count == 0 |
| 65 | Returns steps in correct order when seeded out of order | first step has lowest `displayOrder` |

### `extension TestCaseDetailViewModelTests` — `result`

| # | Scenario | Assertion |
|---|----------|-----------|
| 66 | Returns the matching `TestCaseResult` when one exists in the session | result is non-nil and matches the test case |
| 67 | Returns `nil` when no result exists for the test case | result is `nil` |

### `extension TestCaseDetailViewModelTests` — `setStatus`

| # | Scenario | Assertion |
|---|----------|-----------|
| 68 | Updates `result.status` via the service when a result exists | `result.status == .pass` after `setStatus(.pass)` |
| 69 | Is a no-op and does not crash when `result` is `nil` (no result in session) | no error thrown, `errorMessage == nil` |
| 70 | When the service throws, `errorMessage` is populated | `errorMessage != nil` |

### `extension TestCaseDetailViewModelTests` — `setNotes`

| # | Scenario | Assertion |
|---|----------|-----------|
| 71 | Updates `result.inspectorNotes` via the service when a result exists | `result.inspectorNotes == "note text"` |
| 72 | Is a no-op and does not crash when `result` is `nil` | no error thrown, `errorMessage == nil` |
| 73 | When the service throws, `errorMessage` is populated | `errorMessage != nil` |

---

## Summary

| Component | Extensions | Scenarios |
|-----------|-----------|-----------|
| `InspectionSeedService` | 4 | 20 |
| `InspectionSessionService` | 4 | 12 |
| `TestCaseResultService` | 4 | 17 |
| `ActiveSessionViewModel` | 3 | 4 |
| `InspectionStageViewModel` | 4 | 9 |
| `TestCaseDetailViewModel` | 4 | 11 |
| **Total** | **23** | **73** |
