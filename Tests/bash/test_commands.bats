#!/usr/bin/env bats

load test_helper

@test "cmd_version: outputs correct version string" {
  local expected
  expected="$(tr -d '\r\n' < "$BATS_TEST_DIRNAME/../../VERSION")"
  run cmd_version
  [ "$status" -eq 0 ]
  [ "$output" = "abc-notify ${expected}" ]
}

@test "cmd_version: reads nearby VERSION file when present" {
  local repo="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$repo/bin"
  cp "$BATS_TEST_DIRNAME/../../bin/abc-notify" "$repo/bin/abc-notify"
  printf 'v9.9.9\n' > "$repo/VERSION"

  run bash -lc "source '$repo/bin/abc-notify'; cmd_version"

  [ "$status" -eq 0 ]
  [ "$output" = "abc-notify v9.9.9" ]
}

@test "cmd_help: contains usage information" {
  run cmd_help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage"* ]]
  [[ "$output" == *"abc-notify"* ]]
  [[ "$output" == *"Commands"* ]]
}

@test "main: unknown command prints error to stderr" {
  run main "unknowncmd"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown command"* ]] || [[ "$stderr" == *"Unknown command"* ]]
}
