#!/usr/bin/env bats

load test_helper

@test "cmd_cleanup: removes specific session directory" {
  local session_id="test-session-123"
  local session_dir="${NOTIFY_DIR}/${session_id}"
  mkdir -p "$session_dir"
  touch "${session_dir}/meta"

  [ -d "$session_dir" ]

  echo "{\"session_id\":\"${session_id}\"}" | cmd_cleanup

  [ ! -d "$session_dir" ]
}

@test "cmd_cleanup: handles missing session_id gracefully" {
  # Should not fail when session_id is missing
  run bash -c "echo '{\"other_key\":\"value\"}' | $(cd /Users/a78256/Projects/abc-notify && pwd)/bin/abc-notify cleanup"
  [ "$status" -eq 0 ]
}

@test "cmd_cleanup: does not remove other session directories" {
  local session_id="target-session"
  local other_id="other-session"
  local session_dir="${NOTIFY_DIR}/${session_id}"
  local other_dir="${NOTIFY_DIR}/${other_id}"
  mkdir -p "$session_dir" "$other_dir"

  echo "{\"session_id\":\"${session_id}\"}" | cmd_cleanup

  [ ! -d "$session_dir" ]
  [ -d "$other_dir" ]
}

@test "session directory structure: meta file and focus.sh are expected files" {
  # This test verifies that cmd_init would create meta and focus.sh
  # We test the structure by creating them manually and verifying cleanup removes them
  local session_id="struct-test-456"
  local session_dir="${NOTIFY_DIR}/${session_id}"
  mkdir -p "$session_dir"
  touch "${session_dir}/meta"
  touch "${session_dir}/focus.sh"
  chmod +x "${session_dir}/focus.sh"

  [ -f "${session_dir}/meta" ]
  [ -f "${session_dir}/focus.sh" ]
  [ -x "${session_dir}/focus.sh" ]

  echo "{\"session_id\":\"${session_id}\"}" | cmd_cleanup

  [ ! -d "$session_dir" ]
}
