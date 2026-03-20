#!/bin/bash
# abc-notify installer
# Usage: curl -fsSL https://raw.githubusercontent.com/JHSeo-git/abc-notify/main/scripts/install.sh | bash

set -euo pipefail

REPO_URL="https://raw.githubusercontent.com/JHSeo-git/abc-notify/main"
INSTALL_DIR="/usr/local/bin"
SHARE_DIR="/usr/local/share/abc-notify"

echo "Installing abc-notify..."
echo ""

# 1. macOS check
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Error: abc-notify requires macOS" >&2
  exit 1
fi

# 2. Install dependencies via Homebrew
if ! command -v brew &>/dev/null; then
  echo "Error: Homebrew is required. Install from https://brew.sh" >&2
  exit 1
fi

if ! command -v terminal-notifier &>/dev/null; then
  echo "Installing terminal-notifier..."
  brew install terminal-notifier
fi

if ! command -v jq &>/dev/null; then
  echo "Installing jq..."
  brew install jq
fi

# 3. Download and install abc-notify
echo "Downloading abc-notify..."
mkdir -p "${SHARE_DIR}"
if command -v curl &>/dev/null; then
  curl -fsSL "${REPO_URL}/bin/abc-notify" -o "${INSTALL_DIR}/abc-notify"
  curl -fsSL "${REPO_URL}/VERSION" -o "${SHARE_DIR}/VERSION"
elif command -v wget &>/dev/null; then
  wget -qO "${INSTALL_DIR}/abc-notify" "${REPO_URL}/bin/abc-notify"
  wget -qO "${SHARE_DIR}/VERSION" "${REPO_URL}/VERSION"
else
  echo "Error: curl or wget is required" >&2
  exit 1
fi
chmod +x "${INSTALL_DIR}/abc-notify"

# 3.5 Build and install native window helper (optional)
if command -v swiftc &>/dev/null; then
  echo "Building native window helper..."
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
  if [[ -f "${PROJECT_DIR}/Package.swift" ]]; then
    (cd "$PROJECT_DIR" && swift build -c release 2>&1) && \
      cp "${PROJECT_DIR}/.build/release/abc-notify-native" "${INSTALL_DIR}/" && \
      echo "Native window helper installed." || \
      echo "Warning: Swift build failed. Using AppleScript fallback."
  else
    echo "Warning: Package.swift not found. Skipping native helper build."
  fi
else
  echo "Note: Swift compiler not found. Using AppleScript fallback for window capture."
fi

# 4. Register hooks
echo ""
echo "Registering hooks..."
abc-notify setup all

# 5. Run doctor
echo ""
abc-notify doctor

echo ""
echo "abc-notify installed successfully!"
echo "Run 'abc-notify doctor' anytime to check your setup."
