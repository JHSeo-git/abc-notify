#!/usr/bin/env bats

load test_helper

@test "parse_terminal_apps: single app returns one line" {
  run parse_terminal_apps "iTerm2"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 1 ]
  [ "${lines[0]}" = "iTerm2" ]
}

@test "parse_terminal_apps: multiple apps returns three lines" {
  run parse_terminal_apps "iTerm2,Terminal,kitty"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" = "iTerm2" ]
  [ "${lines[1]}" = "Terminal" ]
  [ "${lines[2]}" = "kitty" ]
}

@test "parse_terminal_apps: apps with spaces are trimmed correctly" {
  run parse_terminal_apps "iTerm2 , Terminal , kitty"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" = "iTerm2" ]
  [ "${lines[1]}" = "Terminal" ]
  [ "${lines[2]}" = "kitty" ]
}

@test "parse_terminal_apps: empty string produces no output" {
  run parse_terminal_apps ""
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
