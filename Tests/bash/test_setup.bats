#!/usr/bin/env bats

load test_helper

# ---------------------------------------------------------------------------
# setup_claude tests
# ---------------------------------------------------------------------------

@test "setup_claude: creates new settings.json with hooks" {
  local settings_file="${HOME}/.claude/settings.json"
  [ ! -f "$settings_file" ]

  setup_claude

  [ -f "$settings_file" ]
  run jq -e '.hooks.Stop' "$settings_file"
  [ "$status" -eq 0 ]
  run jq -e '.hooks.SessionStart' "$settings_file"
  [ "$status" -eq 0 ]
}

@test "setup_claude: merges into existing settings.json" {
  local settings_dir="${HOME}/.claude"
  local settings_file="${settings_dir}/settings.json"
  mkdir -p "$settings_dir"
  echo '{"model":"claude-opus-4"}' > "$settings_file"

  setup_claude

  [ -f "$settings_file" ]
  # Original key preserved
  run jq -r '.model' "$settings_file"
  [ "$status" -eq 0 ]
  [ "$output" = "claude-opus-4" ]
  # Hooks added
  run jq -e '.hooks.Stop' "$settings_file"
  [ "$status" -eq 0 ]
}

@test "setup_claude: skips if hooks already registered" {
  local settings_dir="${HOME}/.claude"
  local settings_file="${settings_dir}/settings.json"
  mkdir -p "$settings_dir"

  # Run once to register
  setup_claude

  # Capture the file content
  local content_before
  content_before=$(cat "$settings_file")

  # Run again — should print skip message and not modify
  run setup_claude
  [ "$status" -eq 0 ]
  [[ "$output" == *"already registered"* ]] || [[ "$output" == *"skipping"* ]]
}

@test "remove_claude: removes abc-notify hooks from settings" {
  local settings_dir="${HOME}/.claude"
  local settings_file="${settings_dir}/settings.json"
  mkdir -p "$settings_dir"

  setup_claude

  # Verify hooks exist first
  run jq -e '.hooks.Stop' "$settings_file"
  [ "$status" -eq 0 ]

  remove_claude

  # After removal, hooks referencing abc-notify should be gone
  # The hooks key may be absent or empty after removal
  local stop_count
  stop_count=$(jq '[.hooks.Stop // [] | .[] | .hooks // [] | .[] | select(.command | contains("abc-notify"))] | length' "$settings_file" 2>/dev/null || echo "0")
  [ "$stop_count" = "0" ]
}

@test "remove_claude: handles missing settings file" {
  # No settings file exists
  run remove_claude
  [ "$status" -eq 0 ]
  [[ "$output" == *"No Claude Code settings found"* ]]
}

# ---------------------------------------------------------------------------
# setup_codex tests
# ---------------------------------------------------------------------------

@test "setup_codex: creates new config.toml" {
  local config_file="${HOME}/.codex/config.toml"
  [ ! -f "$config_file" ]

  setup_codex

  [ -f "$config_file" ]
  run grep 'abc-notify' "$config_file"
  [ "$status" -eq 0 ]
}

@test "setup_codex: appends to existing notify array" {
  local config_dir="${HOME}/.codex"
  local config_file="${config_dir}/config.toml"
  mkdir -p "$config_dir"
  echo 'notify = ["other-tool"]' > "$config_file"

  setup_codex

  run grep 'abc-notify' "$config_file"
  [ "$status" -eq 0 ]
  # other-tool should still be there
  run grep 'other-tool' "$config_file"
  [ "$status" -eq 0 ]
}

@test "setup_codex: skips if already configured" {
  local config_dir="${HOME}/.codex"
  local config_file="${config_dir}/config.toml"
  mkdir -p "$config_dir"
  echo 'notify = ["abc-notify"]' > "$config_file"

  run setup_codex
  [ "$status" -eq 0 ]
  [[ "$output" == *"already configured"* ]] || [[ "$output" == *"skipping"* ]]
}

@test "remove_codex: removes abc-notify from config" {
  local config_dir="${HOME}/.codex"
  local config_file="${config_dir}/config.toml"
  mkdir -p "$config_dir"
  echo 'notify = ["abc-notify"]' > "$config_file"

  remove_codex

  run grep 'abc-notify' "$config_file"
  [ "$status" -ne 0 ]
}

@test "remove_codex: handles missing config" {
  run remove_codex
  [ "$status" -eq 0 ]
  [[ "$output" == *"No Codex config found"* ]]
}
