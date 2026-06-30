# TASK#9 Operations Summary Prompt

Use this operation-first SPDD prompt for Tentpole 3 documentation, prompt taxonomy, review hygiene, and behavior-neutral source organization.

Target organization from TASK#12:

```text
FSAEInspectionChecklist/
  App/
  Common/
    UI/
    Accessibility/
    Localization/
  Features/
    InspectionContent/
    SessionFlow/
    StageExecution/
    TestCaseExecution/
    TestStepExecution/
    Validation/
    Persistence/
    Submission/
    Rechecks/
    Stickers/
  TestSupport/
    Fixtures/
```

| Task | PR Operation Summary | Likely Files | Validation | Split Trigger |
| --- | --- | --- | --- | --- |
| 9.1 | Add or update documentation files with YAML frontmatter for title, domain, feature, status, owners, source files, and related scenarios. | Docs markdown files | Frontmatter inspection. | Split if frontmatter touches unrelated document families. |
| 9.2 | Write technical report overview of architecture, recheck behavior, testing approach, accessibility conventions, and localization conventions. | Technical report docs | Review against OpenSpec design and specs. | Split if report becomes a broad architecture rewrite. |
| 9.3 | Add short tutorials for adding inspection JSON fixtures, validation rules, accessibility identifiers, and persona scenarios. | Tutorial docs | Each tutorial has prerequisite, steps, validation, and follow-up. | Split tutorials if examples require code changes. |
| 9.4 | Ensure implementation PRs use `Summary`, `Scope`, `Notes`, and `Validation` with manual notes, command output, feature scenarios, and squash guidance. | PR templates, docs, prompt files | PR description checklist. | Keep separate from code PRs when possible. |
| 9.5 | Keep one feature branch and one PR per major feature by default; split into task branches only when review context is too broad. | Workflow docs, prompt docs | Branch plan can identify split threshold. | Split when a PR exceeds 10 files or combines unrelated domains. |
| 9.6 | Split tasks across distinct commits so each completed task or tightly related task pair has a reviewable checkpoint. | Commit plan, PR notes | Commit list maps to tasks. | Split branches if commits are still too hard to review in one PR. |
| 9.7 | Add a Tentpole 3 organization plan with the target tree, dry-run file destinations, import risks, ownership risks, and validation checks. | Organization docs, Task 9 prompt docs | Dry-run table maps current files to proposed destinations before any move. | Split if docs expand into persistence or UX product decisions. |
| 9.8 | Perform the first behavior-neutral `Common/UI` organization pass, starting with `DesignSystem.swift` and `KeyboardDismissBar.swift`. | `DesignSystem.swift`, `KeyboardDismissBar.swift`, project references if needed, UI tests/build settings | Build/tests pass; public symbols, styles, keyboard dismissal behavior, and imports remain stable. | Split if project file updates and Swift source moves become hard to review together. |
| 9.9 | Split `AppCoordinators.swift` into smaller files by coordinator/route ownership without changing behavior. | `AppCoordinators.swift`, new coordinator files, coordinator tests | Existing coordinator tests pass; no route names, public intents, or app flow behavior change. | Split further if route enums, session selection, and execution coordinator extraction cannot be reviewed independently. |
| 9.10 | Split `ContentView.swift` into smaller root composition, tab, binding, and empty-state files without changing behavior. | `ContentView.swift`, new App/root view files, coordinator tests/view helper tests | Build/tests pass; top-level tabs and route behavior remain unchanged. | Split if dependency wiring and UI extraction both create broad diffs. |

Common PR summary language:

```md
## Summary

Improves inspection event documentation and PR review hygiene so implementation branches stay easier to scan, validate, and squash.

## Scope

- <Docs, templates, tutorials, workflow rules, or behavior-neutral source organization changed>
- <OpenSpec tasks or feature scenarios referenced>

## Notes

- Documentation and organization changes should not hide implementation behavior changes.
- Feature PRs stay single-PR by default, with task branches used only when review scope becomes too broad.
- Source splits in TASK#9.8 through TASK#9.10 are refactors only; feature behavior remains out of scope.
- Inspection content, persistence, submission, Stage/Case/Step view, `AppCoordinators.swift`, and `ContentView.swift` moves should follow the documented Organization Design priority order.

## Validation

- `rg` or manual inspection of frontmatter/template/source split coverage
- Existing Swift Testing suite for touched coordinators/views
- <Links to docs or PR checklist updated>
```
