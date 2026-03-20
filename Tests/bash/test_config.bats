#!/usr/bin/env bats

load test_helper

@test "load_config: no config files sets defaults" {
  # Ensure no config files exist
  rm -f "${HOME}/.abc-notify.env"
  rm -f "${PWD}/.abc-notify.env"

  # Unset any variables that might be set from the environment
  unset NOTIFY_SOUND NOTIFY_THROTTLE NOTIFY_DISABLED NOTIFY_TITLE_CLAUDE NOTIFY_TITLE_CODEX TERMINAL_APP

  load_config "${TEST_TEMP_DIR}"

  [ "${NOTIFY_SOUND}" = "Glass" ]
  [ "${NOTIFY_THROTTLE}" = "2" ]
  [ "${NOTIFY_DISABLED}" = "false" ]
  [ "${NOTIFY_TITLE_CLAUDE}" = "Claude Code" ]
  [ "${NOTIFY_TITLE_CODEX}" = "Codex" ]
}

@test "load_config: global config is loaded" {
  echo 'NOTIFY_SOUND=Basso' > "${HOME}/.abc-notify.env"

  unset NOTIFY_SOUND NOTIFY_THROTTLE NOTIFY_DISABLED

  load_config "${TEST_TEMP_DIR}"

  [ "${NOTIFY_SOUND}" = "Basso" ]
}

@test "load_config: project config overrides global config" {
  echo 'NOTIFY_SOUND=Basso' > "${HOME}/.abc-notify.env"
  echo 'NOTIFY_SOUND=Ping' > "${TEST_TEMP_DIR}/.abc-notify.env"

  unset NOTIFY_SOUND

  load_config "${TEST_TEMP_DIR}"

  [ "${NOTIFY_SOUND}" = "Ping" ]
}

@test "load_config: NOTIFY_DISABLED default is false" {
  rm -f "${HOME}/.abc-notify.env"

  unset NOTIFY_DISABLED

  load_config "${TEST_TEMP_DIR}"

  [ "${NOTIFY_DISABLED}" = "false" ]
}
