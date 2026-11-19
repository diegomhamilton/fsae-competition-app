#!/usr/bin/env bash
# Observable iOS checkpoint steps adapted from the ios-bass-app workflow.
set -euo pipefail

FSAE_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FSAE_REPO_ROOT="$(cd "$FSAE_SCRIPT_DIR/../.." && pwd)"
FSAE_DEVELOPER_DIR="${FSAE_DEVELOPER_DIR:-/Applications/Xcode26-2.app/Contents/Developer}"
FSAE_PROJECT="${FSAE_PROJECT:-$FSAE_REPO_ROOT/FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist.xcodeproj}"
FSAE_SCHEME="${FSAE_SCHEME:-FSAEInspectionChecklist}"
FSAE_DERIVED_DATA="${FSAE_DERIVED_DATA:-/tmp/FSAESimplifiedUIDerivedData}"
FSAE_BUNDLE_ID="${FSAE_BUNDLE_ID:-com.Maia.FSAEInspectionChecklist}"
FSAE_APP_PATH="${FSAE_APP_PATH:-$FSAE_DERIVED_DATA/Build/Products/Debug-iphonesimulator/FSAEInspectionChecklist.app}"

usage() {
  cat <<'USAGE'
usage: checkpoint.sh <step> [arguments]

Read-only: status | version | destinations | devices | summary <bundle.xcresult>
Build:    build | test [TestTarget/Suite ...]
Device:   boot | ready | install | launch [app launch arguments ...]
Capture:  capture <image.png> | check <existing image>

Required for device/build/test steps: FSAE_SIMULATOR_ID.
Configurable: FSAE_DEVELOPER_DIR, FSAE_PROJECT, FSAE_SCHEME,
FSAE_DERIVED_DATA, FSAE_BUNDLE_ID, FSAE_APP_PATH, FSAE_RESULT_BUNDLE.

Run each step separately and inspect its result. A test action already builds.
Use a fresh FSAE_RESULT_BUNDLE path for each test run. Capture is followed by
boot-screen rejection; accepted images still need visual inspection.
USAGE
}

fail() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

run_step() {
  printf '+ '
  printf '%q ' "$@"
  printf '\n'
  "$@"
}

run_xcode() {
  [[ -d "$FSAE_DEVELOPER_DIR" ]] || fail "Developer directory does not exist: $FSAE_DEVELOPER_DIR"
  run_step env DEVELOPER_DIR="$FSAE_DEVELOPER_DIR" "$@"
}

require_simulator() {
  [[ -n "${FSAE_SIMULATOR_ID:-}" ]] || fail "Set FSAE_SIMULATOR_ID to a discovered simulator and retain it for this checkpoint."
}

simulator_state() {
  env DEVELOPER_DIR="$FSAE_DEVELOPER_DIR" xcrun simctl list devices --json |
    python3 -c 'import json,sys
identifier=sys.argv[1]
devices=[device for group in json.load(sys.stdin)["devices"].values() for device in group]
matches=[device for device in devices if device["udid"] == identifier]
if not matches:
    print("Unknown")
    sys.exit(1)
print(matches[0]["state"])' "$FSAE_SIMULATOR_ID"
}

require_booted() {
  require_simulator
  local fsae_state
  fsae_state="$(simulator_state)" || fail "Simulator was not found: $FSAE_SIMULATOR_ID"
  [[ "$fsae_state" == "Booted" ]] || fail "Simulator is $fsae_state. Run boot, then ready, before continuing."
}

FSAE_STEP="${1:-help}"
if [[ "$#" -gt 0 ]]; then shift; fi

case "$FSAE_STEP" in
  help|-h|--help)
    usage
    ;;
  status)
    run_step git -C "$FSAE_REPO_ROOT" status --short --branch
    run_step git -C "$FSAE_REPO_ROOT" rev-parse HEAD
    ;;
  version)
    run_xcode xcodebuild -version
    ;;
  destinations)
    run_xcode xcodebuild -project "$FSAE_PROJECT" -scheme "$FSAE_SCHEME" -showdestinations
    ;;
  devices)
    run_xcode xcrun simctl list devices available
    ;;
  build)
    require_simulator
    run_xcode xcodebuild -project "$FSAE_PROJECT" -scheme "$FSAE_SCHEME" \
      -destination "platform=iOS Simulator,id=$FSAE_SIMULATOR_ID" \
      -derivedDataPath "$FSAE_DERIVED_DATA" -quiet build
    ;;
  test)
    require_simulator
    FSAE_RESULT_BUNDLE="${FSAE_RESULT_BUNDLE:-/tmp/FSAESimplifiedUI-$(date +%Y%m%d-%H%M%S).xcresult}"
    [[ ! -e "$FSAE_RESULT_BUNDLE" ]] || fail "Result bundle already exists; select a fresh FSAE_RESULT_BUNDLE: $FSAE_RESULT_BUNDLE"
    fsae_test_arguments=(
      -project "$FSAE_PROJECT" -scheme "$FSAE_SCHEME"
      -destination "platform=iOS Simulator,id=$FSAE_SIMULATOR_ID"
      -derivedDataPath "$FSAE_DERIVED_DATA"
      -resultBundlePath "$FSAE_RESULT_BUNDLE"
      -parallel-testing-enabled NO -quiet
    )
    for fsae_scope in "$@"; do
      fsae_test_arguments+=("-only-testing:$fsae_scope")
    done
    run_xcode xcodebuild "${fsae_test_arguments[@]}" test
    printf 'Result bundle: %s\n' "$FSAE_RESULT_BUNDLE"
    ;;
  summary)
    [[ "$#" -eq 1 ]] || fail "summary requires one existing result-bundle path."
    [[ -d "$1" ]] || fail "Result bundle does not exist: $1"
    run_xcode xcrun xcresulttool get test-results summary --path "$1"
    ;;
  boot)
    require_simulator
    FSAE_DEVICE_STATE="$(simulator_state)" || fail "Simulator was not found: $FSAE_SIMULATOR_ID"
    if [[ "$FSAE_DEVICE_STATE" == "Booted" ]]; then
      printf 'Simulator already booted. Run ready to confirm initialization.\n'
    elif [[ "$FSAE_DEVICE_STATE" == "Shutdown" ]]; then
      run_xcode xcrun simctl boot "$FSAE_SIMULATOR_ID"
    else
      fail "Simulator state is $FSAE_DEVICE_STATE; inspect it before booting."
    fi
    ;;
  ready)
    require_booted
    run_xcode xcrun simctl bootstatus "$FSAE_SIMULATOR_ID" -b
    ;;
  install)
    require_booted
    [[ -d "$FSAE_APP_PATH" ]] || fail "Tested app product does not exist: $FSAE_APP_PATH"
    run_xcode xcrun simctl install "$FSAE_SIMULATOR_ID" "$FSAE_APP_PATH"
    ;;
  launch)
    require_booted
    run_xcode xcrun simctl launch --terminate-running-process \
      "$FSAE_SIMULATOR_ID" "$FSAE_BUNDLE_ID" "$@"
    ;;
  capture)
    [[ "$#" -eq 1 ]] || fail "capture requires one output image path."
    require_booted
    mkdir -p "$(dirname "$1")"
    run_xcode xcrun simctl io "$FSAE_SIMULATOR_ID" screenshot "$1"
    [[ -s "$1" ]] || fail "Capture did not create an image: $1"
    run_xcode xcrun swift -module-cache-path /tmp/fsae-ui-validation-module-cache \
      "$FSAE_SCRIPT_DIR/check_screenshot.swift" "$1"
    ;;
  check)
    [[ "$#" -eq 1 ]] || fail "check requires one existing image path."
    [[ -s "$1" ]] || fail "Image does not exist: $1"
    run_xcode xcrun swift -module-cache-path /tmp/fsae-ui-validation-module-cache \
      "$FSAE_SCRIPT_DIR/check_screenshot.swift" "$1"
    ;;
  *)
    usage >&2
    fail "Unknown step: $FSAE_STEP"
    ;;
esac
