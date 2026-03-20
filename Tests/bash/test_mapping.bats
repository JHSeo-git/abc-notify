#!/usr/bin/env bats

load test_helper

# ---------------------------------------------------------------------------
# map_term_program tests
# ---------------------------------------------------------------------------

@test "map_term_program: iTerm.app maps to iTerm2" {
  run map_term_program "iTerm.app"
  [ "$status" -eq 0 ]
  [ "$output" = "iTerm2" ]
}

@test "map_term_program: iTerm2 maps to iTerm2" {
  run map_term_program "iTerm2"
  [ "$status" -eq 0 ]
  [ "$output" = "iTerm2" ]
}

@test "map_term_program: Apple_Terminal maps to Terminal" {
  run map_term_program "Apple_Terminal"
  [ "$status" -eq 0 ]
  [ "$output" = "Terminal" ]
}

@test "map_term_program: WezTerm maps to WezTerm" {
  run map_term_program "WezTerm"
  [ "$status" -eq 0 ]
  [ "$output" = "WezTerm" ]
}

@test "map_term_program: Alacritty maps to Alacritty" {
  run map_term_program "Alacritty"
  [ "$status" -eq 0 ]
  [ "$output" = "Alacritty" ]
}

@test "map_term_program: kitty maps to kitty" {
  run map_term_program "kitty"
  [ "$status" -eq 0 ]
  [ "$output" = "kitty" ]
}

@test "map_term_program: Hyper maps to Hyper" {
  run map_term_program "Hyper"
  [ "$status" -eq 0 ]
  [ "$output" = "Hyper" ]
}

@test "map_term_program: ghostty maps to Ghostty" {
  run map_term_program "ghostty"
  [ "$status" -eq 0 ]
  [ "$output" = "Ghostty" ]
}

@test "map_term_program: unknown returns empty" {
  run map_term_program "unknown_terminal"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

# ---------------------------------------------------------------------------
# bundle_id_for tests
# ---------------------------------------------------------------------------

@test "bundle_id_for: iTerm2 returns com.googlecode.iterm2" {
  run bundle_id_for "iTerm2"
  [ "$status" -eq 0 ]
  [ "$output" = "com.googlecode.iterm2" ]
}

@test "bundle_id_for: Terminal returns com.apple.Terminal" {
  run bundle_id_for "Terminal"
  [ "$status" -eq 0 ]
  [ "$output" = "com.apple.Terminal" ]
}

@test "bundle_id_for: WezTerm returns com.github.wez.wezterm" {
  run bundle_id_for "WezTerm"
  [ "$status" -eq 0 ]
  [ "$output" = "com.github.wez.wezterm" ]
}

@test "bundle_id_for: Alacritty returns org.alacritty" {
  run bundle_id_for "Alacritty"
  [ "$status" -eq 0 ]
  [ "$output" = "org.alacritty" ]
}

@test "bundle_id_for: kitty returns net.kovidgoyal.kitty" {
  run bundle_id_for "kitty"
  [ "$status" -eq 0 ]
  [ "$output" = "net.kovidgoyal.kitty" ]
}

@test "bundle_id_for: Hyper returns co.zeit.hyper" {
  run bundle_id_for "Hyper"
  [ "$status" -eq 0 ]
  [ "$output" = "co.zeit.hyper" ]
}

@test "bundle_id_for: Ghostty returns com.mitchellh.ghostty" {
  run bundle_id_for "Ghostty"
  [ "$status" -eq 0 ]
  [ "$output" = "com.mitchellh.ghostty" ]
}

@test "bundle_id_for: VSCode returns com.microsoft.VSCode" {
  run bundle_id_for "VSCode"
  [ "$status" -eq 0 ]
  [ "$output" = "com.microsoft.VSCode" ]
}

@test "bundle_id_for: Warp returns dev.warp.Warp-Stable" {
  run bundle_id_for "Warp"
  [ "$status" -eq 0 ]
  [ "$output" = "dev.warp.Warp-Stable" ]
}

@test "bundle_id_for: unknown returns empty" {
  run bundle_id_for "UnknownApp"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "detect_terminal_bundle: prefers CODEX_ACTIVATE_BUNDLE" {
  run bash -lc "source '$BATS_TEST_DIRNAME/../../bin/abc-notify'; CODEX_ACTIVATE_BUNDLE='com.example.override' __CFBundleIdentifier= TERM_PROGRAM= TMUX= GHOSTTY_RESOURCES_DIR= KITTY_WINDOW_ID= ITERM_SESSION_ID= WEZTERM_PANE= TERMINAL_APP=; detect_terminal_bundle"
  [ "$status" -eq 0 ]
  [ "$output" = "com.example.override" ]
}

@test "detect_terminal_bundle: uses __CFBundleIdentifier when set" {
  run bash -lc "source '$BATS_TEST_DIRNAME/../../bin/abc-notify'; CODEX_ACTIVATE_BUNDLE= __CFBundleIdentifier='dev.warp.Warp-Stable' TERM_PROGRAM= TMUX= GHOSTTY_RESOURCES_DIR= KITTY_WINDOW_ID= ITERM_SESSION_ID= WEZTERM_PANE= TERMINAL_APP=; detect_terminal_bundle"
  [ "$status" -eq 0 ]
  [ "$output" = "dev.warp.Warp-Stable" ]
}

@test "detect_terminal_bundle: maps TERM_PROGRAM vscode" {
  run bash -lc "source '$BATS_TEST_DIRNAME/../../bin/abc-notify'; CODEX_ACTIVATE_BUNDLE= __CFBundleIdentifier= TERM_PROGRAM='vscode' TMUX= GHOSTTY_RESOURCES_DIR= KITTY_WINDOW_ID= ITERM_SESSION_ID= WEZTERM_PANE= TERMINAL_APP=; detect_terminal_bundle"
  [ "$status" -eq 0 ]
  [ "$output" = "com.microsoft.VSCode" ]
}

@test "detect_terminal_bundle: falls back to Ghostty environment" {
  run bash -lc "source '$BATS_TEST_DIRNAME/../../bin/abc-notify'; CODEX_ACTIVATE_BUNDLE= __CFBundleIdentifier= TERM_PROGRAM= TMUX= GHOSTTY_RESOURCES_DIR='/tmp/ghostty' KITTY_WINDOW_ID= ITERM_SESSION_ID= WEZTERM_PANE= TERMINAL_APP=; detect_terminal_bundle"
  [ "$status" -eq 0 ]
  [ "$output" = "com.mitchellh.ghostty" ]
}
