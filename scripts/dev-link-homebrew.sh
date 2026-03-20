#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ABC_NOTIFY_SRC="${REPO_DIR}/bin/abc-notify"
NATIVE_SRC="${REPO_DIR}/.build/release/abc-notify-native"

usage() {
  echo "Usage: $0 {link|unlink}" >&2
  exit 1
}

brew_prefix() {
  if ! command -v brew >/dev/null 2>&1; then
    echo "Error: brew is required." >&2
    exit 1
  fi

  brew --prefix
}

require_source() {
  local path="$1"

  if [[ ! -e "$path" ]]; then
    echo "Error: missing source $path. Run 'swift build -c release' first." >&2
    exit 1
  fi
}

ensure_target_safe() {
  local target="$1"

  if [[ -e "$target" && ! -L "$target" ]]; then
    echo "Error: refusing to replace non-symlink target: $target" >&2
    exit 1
  fi
}

remove_target() {
  local target="$1"

  if [[ -L "$target" ]]; then
    rm "$target"
    echo "Removed $target"
    return
  fi

  if [[ -e "$target" ]]; then
    echo "Error: refusing to remove non-symlink target: $target" >&2
    exit 1
  fi

  echo "Skipped missing $target"
}

cmd_link() {
  local prefix bin_dir

  prefix="$(brew_prefix)"
  bin_dir="${prefix}/bin"

  require_source "$ABC_NOTIFY_SRC"
  require_source "$NATIVE_SRC"

  mkdir -p "$bin_dir"

  ensure_target_safe "${bin_dir}/abc-notify"
  ensure_target_safe "${bin_dir}/abc-notify-native"

  ln -sf "$ABC_NOTIFY_SRC" "${bin_dir}/abc-notify"
  echo "Linked ${bin_dir}/abc-notify -> $ABC_NOTIFY_SRC"

  ln -sf "$NATIVE_SRC" "${bin_dir}/abc-notify-native"
  echo "Linked ${bin_dir}/abc-notify-native -> $NATIVE_SRC"
}

cmd_unlink() {
  local prefix bin_dir

  prefix="$(brew_prefix)"
  bin_dir="${prefix}/bin"

  remove_target "${bin_dir}/abc-notify"
  remove_target "${bin_dir}/abc-notify-native"
}

main() {
  local command="${1:-}"

  case "$command" in
    link)
      cmd_link
      ;;
    unlink)
      cmd_unlink
      ;;
    *)
      usage
      ;;
  esac
}

main "$@"
