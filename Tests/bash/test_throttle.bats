#!/usr/bin/env bats

load test_helper

@test "is_throttled: no throttle file returns not throttled (exit 1)" {
  local throttle_file="${TEST_TEMP_DIR}/no_such_file"
  run is_throttled "$throttle_file"
  [ "$status" -eq 1 ]
}

@test "is_throttled: recent timestamp is throttled (exit 0)" {
  local throttle_file="${TEST_TEMP_DIR}/throttle"
  # Write the current timestamp — well within the throttle window
  date +%s > "$throttle_file"
  export NOTIFY_THROTTLE=5
  run is_throttled "$throttle_file"
  [ "$status" -eq 0 ]
}

@test "is_throttled: old timestamp with short throttle window is not throttled" {
  local throttle_file="${TEST_TEMP_DIR}/throttle"
  # Write a timestamp 10 seconds ago
  local old_time
  old_time=$(( $(date +%s) - 10 ))
  echo "$old_time" > "$throttle_file"
  export NOTIFY_THROTTLE=2
  run is_throttled "$throttle_file"
  [ "$status" -eq 1 ]
}

@test "update_throttle: creates file with current timestamp" {
  local throttle_file="${TEST_TEMP_DIR}/new_throttle"
  [ ! -f "$throttle_file" ]
  update_throttle "$throttle_file"
  [ -f "$throttle_file" ]
  local stored_time
  stored_time=$(cat "$throttle_file")
  local now
  now=$(date +%s)
  # Allow 2 second delta
  [ $(( now - stored_time )) -le 2 ]
}
