# Source the script under test
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SCRIPT_DIR}/bin/abc-notify"

setup() {
  TEST_TEMP_DIR="$(mktemp -d)"
  export HOME="$TEST_TEMP_DIR"
  export NOTIFY_DIR="${TEST_TEMP_DIR}/abc-notify"
  mkdir -p "$NOTIFY_DIR"
}

teardown() {
  rm -rf "$TEST_TEMP_DIR"
}

# Mock out macOS-only commands for unit tests
require_macos() { true; }
require_deps() { true; }
