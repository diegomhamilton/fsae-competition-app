# iOS UI checkpoint helpers

`checkpoint.sh` exposes individual observable build, test, simulator, and capture steps. It never switches branches, commits, fetches, or rebuilds for installation. Use one retained simulator and stable DerivedData throughout a checkpoint.

```sh
export FSAE_DEVELOPER_DIR=/Applications/Xcode26-2.app/Contents/Developer
export FSAE_DERIVED_DATA=/tmp/FSAESimplifiedUIDerivedData
export FSAE_SIMULATOR_ID=34AA36AD-2704-4759-A347-01A023DEB371
tools/ui-validation/checkpoint.sh help
```

The simulator ID is an example for this machine; discover it once with `devices`. Other overrides are listed by `help`. `test` accepts zero or more `TestTarget/Suite` arguments, disables parallel testing, and writes a result bundle. Select a fresh `FSAE_RESULT_BUNDLE` for reruns.

Run `boot`, `ready`, `install`, `launch`, and `capture` separately, checking each result. The app installed is the existing tested product. Capture creates the output directory and then applies `check_screenshot.swift`; accepted images still require visual review. `summary` reads the authoritative completed result-bundle summary.

The Swift gate is an independently implemented adaptation of the boot-screen sampling technique in the same owner's ios-bass-app project at `.agents/skills/ios-feature-validation/scripts/check_screenshot.swift`. Exit `0` permits visual inspection, `1` indicates invalid input, and `2` rejects a likely boot or blank black screen. A very dark intentional UI can be a false positive; inspect the image and document any waiver rather than silently treating it as passed.

Full workflow and source attribution are in `docs/simplified-ui-vault/Workflow/Build-and-snapshot-workflow.md` and `Learnings-from-ios-bass-app.md`. In this session XcodeBuildMCP is unavailable; checkpoint notes must identify direct Xcode validation accurately.
