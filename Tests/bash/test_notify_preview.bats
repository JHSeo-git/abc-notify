#!/usr/bin/env bats

load test_helper

PREVIEW_LIMIT=140

ensure_notifier_stub() {
  export NOTIFIER_LOG="${TEST_TEMP_DIR}/terminal-notifier.log"
  mkdir -p "${TEST_TEMP_DIR}/fake-bin"

  cat > "${TEST_TEMP_DIR}/fake-bin/terminal-notifier" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$@" > "${ABC_NOTIFY_TEST_NOTIFY_LOG}"
EOF
  chmod +x "${TEST_TEMP_DIR}/fake-bin/terminal-notifier"
}

logged_notify_message() {
  local _attempt
  for _attempt in 1 2 3 4 5 6 7 8 9 10; do
    [[ -f "${NOTIFIER_LOG}" ]] && break
    sleep 0.05
  done
  awk 'seen { print; exit } $0 == "-message" { seen = 1 }' "${NOTIFIER_LOG}"
}

run_claude_notify() {
  local payload="$1"
  ensure_notifier_stub

  run env \
    JSON_PAYLOAD="$payload" \
    PATH="${TEST_TEMP_DIR}/fake-bin:${PATH}" \
    HOME="${HOME}" \
    NOTIFY_DIR="${NOTIFY_DIR}" \
    ABC_NOTIFY_TEST_NOTIFY_LOG="${NOTIFIER_LOG}" \
    ABC_NOTIFY_BIN="${ABC_NOTIFY_BIN}" \
    bash -c '
      source "$ABC_NOTIFY_BIN"
      require_macos() { true; }
      require_deps() { true; }
      printf "%s" "$JSON_PAYLOAD" | cmd_notify
      for _ in 1 2 3 4 5; do
        [[ -f "$ABC_NOTIFY_TEST_NOTIFY_LOG" ]] && break
        sleep 0.05
      done
    '
}

run_codex_notify() {
  local payload="$1"
  ensure_notifier_stub

  run env \
    JSON_PAYLOAD="$payload" \
    PATH="${TEST_TEMP_DIR}/fake-bin:${PATH}" \
    HOME="${HOME}" \
    NOTIFY_DIR="${NOTIFY_DIR}" \
    ABC_NOTIFY_TEST_NOTIFY_LOG="${NOTIFIER_LOG}" \
    ABC_NOTIFY_BIN="${ABC_NOTIFY_BIN}" \
    bash -c '
      source "$ABC_NOTIFY_BIN"
      require_macos() { true; }
      require_deps() { true; }
      cmd_codex "$JSON_PAYLOAD"
      for _ in 1 2 3 4 5; do
        [[ -f "$ABC_NOTIFY_TEST_NOTIFY_LOG" ]] && break
        sleep 0.05
      done
    '
}

@test "cmd_notify: uses Claude last assistant message preview for Stop" {
  run_claude_notify '{"session_id":"claude-stop-preview","hook_event_name":"Stop","last_assistant_message":"Implemented the final migration and verified the tests are passing."}'

  [ "$status" -eq 0 ]
  [ "$(logged_notify_message)" = "Implemented the final migration and verified the tests are passing." ]
}

@test "cmd_notify: falls back when Claude last assistant message is blank" {
  run_claude_notify '{"session_id":"claude-stop-fallback","hook_event_name":"Stop","last_assistant_message":"   \n  "}'

  [ "$status" -eq 0 ]
  [ "$(logged_notify_message)" = "Task completed" ]
}

@test "cmd_notify: normalizes Claude preview whitespace" {
  run_claude_notify '{"session_id":"claude-stop-normalize","hook_event_name":"Stop","last_assistant_message":"First line.\n\n  Second    line.\tThird line."}'

  [ "$status" -eq 0 ]
  [ "$(logged_notify_message)" = "First line. Second line. Third line." ]
}

@test "cmd_notify: truncates long Claude preview" {
  local long_message
  long_message="$(printf 'A%.0s' $(seq 1 170))"

  run_claude_notify "{\"session_id\":\"claude-stop-truncate\",\"hook_event_name\":\"Stop\",\"last_assistant_message\":\"${long_message}\"}"

  [ "$status" -eq 0 ]
  [ "$(logged_notify_message)" = "$(printf 'A%.0s' $(seq 1 "${PREVIEW_LIMIT}"))..." ]
}

@test "cmd_codex: uses supported assistant message preview when present" {
  run_codex_notify '{"type":"agent-turn-complete","cwd":".","thread-id":"codex-preview","last_assistant_message":"Completed the refactor and added regression coverage for the shell helper."}'

  [ "$status" -eq 0 ]
  [ "$(logged_notify_message)" = "Completed the refactor and added regression coverage for the shell helper." ]
}

@test "cmd_codex: falls back when assistant preview is absent" {
  run_codex_notify '{"type":"agent-turn-paused","cwd":".","thread-id":"codex-fallback"}'

  [ "$status" -eq 0 ]
  [ "$(logged_notify_message)" = "Approval required" ]
}
