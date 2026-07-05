#!/usr/bin/env bash
set -u -o pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
PATCH_DIR="${1:-$ROOT_DIR/tools/mutation/patches}"
RESULT_ROOT="${MUTATION_RESULTS_DIR:-$ROOT_DIR/mutation-results/$(date +%Y%m%d-%H%M%S)-$$}"

TEST_PROJECT="$ROOT_DIR/FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist.xcodeproj"
TEST_DERIVED_DATA="${MUTATION_DERIVED_DATA:-/tmp/fsae-mutation-derived-data}"

active_patch=""

sanitize_path() {
  local raw_value="$1"

  if [[ -n "${ROOT_DIR:-}" ]]; then
    raw_value="${raw_value//$ROOT_DIR/<repo-root>}"
  fi

  if [[ -n "${HOME:-}" ]]; then
    raw_value="${raw_value//$HOME/<user-home>}"
  fi

  printf '%s' "$raw_value"
}

sanitize_file() {
  local file="$1"

  [[ -f "$file" ]] || return 0

  SANITIZE_REPO_ROOT="$ROOT_DIR" SANITIZE_HOME="${HOME:-}" perl -0pi -e '
    BEGIN {
      $repo = $ENV{"SANITIZE_REPO_ROOT"} // "";
      $home = $ENV{"SANITIZE_HOME"} // "";
    }
    s/\Q$repo\E/<repo-root>/g if length $repo;
    s/\Q$home\E/<user-home>/g if length $home;
  ' "$file"
}

revert_active_patch() {
  if [[ -n "$active_patch" ]]; then
    git -C "$ROOT_DIR" apply -R "$active_patch" >/dev/null 2>&1 || true
    active_patch=""
  fi
}

trap revert_active_patch EXIT INT TERM

run_unit_tests() {
  local result_bundle="$1"

  xcodebuild test \
    -project "$TEST_PROJECT" \
    -scheme FSAEInspectionChecklist \
    -destination platform=macOS \
    -enableCodeCoverage YES \
    -derivedDataPath "$TEST_DERIVED_DATA" \
    -resultBundlePath "$result_bundle" \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY=
}

write_status() {
  local result_dir="$1"
  local mutant="$2"
  local status="$3"
  local exit_code="$4"

  {
    printf 'mutant=%s\n' "$mutant"
    printf 'status=%s\n' "$status"
    printf 'exit_code=%s\n' "$exit_code"
    printf 'patch=%s\n' "$(sanitize_path "$result_dir/mutant.patch")"
    printf 'log=%s\n' "$(sanitize_path "$result_dir/test.log")"
    printf 'result_bundle=%s\n' "$(sanitize_path "$result_dir/TestResult.xcresult")"
  } > "$result_dir/status.txt"
}

mkdir -p "$RESULT_ROOT"

if [[ ! -d "$PATCH_DIR" ]]; then
  echo "Patch directory not found: $PATCH_DIR" >&2
  exit 2
fi

patch_count=0
for patch in "$PATCH_DIR"/*.patch; do
  [[ -e "$patch" ]] || continue
  patch_count=$((patch_count + 1))
done

if [[ "$patch_count" -eq 0 ]]; then
  echo "No patch files found in $PATCH_DIR" >&2
  exit 2
fi

summary_file="$RESULT_ROOT/summary.tsv"
printf 'mutant\tstatus\texit_code\tresult_dir\n' > "$summary_file"

for patch in "$PATCH_DIR"/*.patch; do
  mutant="$(basename "$patch" .patch)"
  result_dir="$RESULT_ROOT/$mutant"
  result_bundle="$result_dir/TestResult.xcresult"
  mkdir -p "$result_dir"
  cp "$patch" "$result_dir/mutant.patch"

  echo "==> $mutant"

  if ! git -C "$ROOT_DIR" apply --check "$patch" > "$result_dir/apply-check.log" 2>&1; then
    sanitize_file "$result_dir/apply-check.log"
    echo "    apply failed"
    write_status "$result_dir" "$mutant" "apply_failed" 2
    printf '%s\t%s\t%s\t%s\n' "$mutant" "apply_failed" 2 "$(sanitize_path "$result_dir")" >> "$summary_file"
    continue
  fi

  git -C "$ROOT_DIR" apply "$patch"
  active_patch="$patch"

  run_unit_tests "$result_bundle" > "$result_dir/test.log" 2>&1
  exit_code=$?
  sanitize_file "$result_dir/test.log"

  if [[ "$exit_code" -eq 0 ]]; then
    status="survived"
  else
    status="killed"
  fi

  if ! git -C "$ROOT_DIR" apply -R --check "$patch" > "$result_dir/revert-check.log" 2>&1; then
    sanitize_file "$result_dir/revert-check.log"
    status="revert_failed"
    echo "    revert check failed; leaving worktree for inspection"
    write_status "$result_dir" "$mutant" "$status" "$exit_code"
    printf '%s\t%s\t%s\t%s\n' "$mutant" "$status" "$exit_code" "$(sanitize_path "$result_dir")" >> "$summary_file"
    active_patch=""
    exit 3
  fi
  sanitize_file "$result_dir/revert-check.log"

  git -C "$ROOT_DIR" apply -R "$patch"
  active_patch=""

  echo "    $status"
  write_status "$result_dir" "$mutant" "$status" "$exit_code"
  printf '%s\t%s\t%s\t%s\n' "$mutant" "$status" "$exit_code" "$(sanitize_path "$result_dir")" >> "$summary_file"
done

echo
echo "Mutation summary: $(sanitize_path "$summary_file")"
column -t -s $'\t' "$summary_file" 2>/dev/null || cat "$summary_file"
