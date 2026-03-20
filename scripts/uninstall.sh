#!/bin/bash
# abc-notify uninstaller

set -euo pipefail

echo "Uninstalling abc-notify..."

# 1. Remove hooks
if command -v abc-notify &>/dev/null; then
  abc-notify remove all 2>/dev/null || true
fi

# 2. Remove binary
if [[ -f "/usr/local/bin/abc-notify" ]]; then
  rm -f "/usr/local/bin/abc-notify"
  echo "Removed /usr/local/bin/abc-notify"
fi

# 3. Clean up temp files
if [[ -d "/tmp/abc-notify" ]]; then
  rm -rf "/tmp/abc-notify"
  echo "Cleaned up /tmp/abc-notify"
fi

echo ""
echo "abc-notify has been uninstalled."
echo "Note: ~/.abc-notify.env was preserved. Remove it manually if no longer needed."
