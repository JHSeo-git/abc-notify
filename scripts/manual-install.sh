#!/usr/bin/env bash
# Manual install from a local abc-notify repository checkout.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

INSTALL_DIR="${ABC_NOTIFY_INSTALL_DIR:-/usr/local/bin}"
SHARE_DIR="${ABC_NOTIFY_SHARE_DIR:-/usr/local/share/abc-notify}"
SKIP_PLATFORM_CHECK="${ABC_NOTIFY_SKIP_PLATFORM_CHECK:-0}"
SKIP_SETUP="${ABC_NOTIFY_SKIP_SETUP:-0}"
SKIP_DOCTOR="${ABC_NOTIFY_SKIP_DOCTOR:-0}"

BIN_SOURCE="${REPO_ROOT}/bin/abc-notify"
VERSION_SOURCE="${REPO_ROOT}/VERSION"
NATIVE_SOURCE="${REPO_ROOT}/.build/release/abc-notify-native"

if [[ "${SKIP_PLATFORM_CHECK}" != "1" ]] && [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Error: abc-notify manual install requires macOS" >&2
  exit 1
fi

if [[ ! -f "${BIN_SOURCE}" || ! -f "${VERSION_SOURCE}" ]]; then
  echo "Error: run this script from an abc-notify repository checkout" >&2
  exit 1
fi

if ! command -v swift >/dev/null 2>&1; then
  echo "Error: swift is required for manual install" >&2
  exit 1
fi

echo "Building abc-notify-native (release)..."
(cd "${REPO_ROOT}" && swift build -c release)

if [[ ! -f "${NATIVE_SOURCE}" ]]; then
  echo "Error: expected native helper at ${NATIVE_SOURCE}" >&2
  exit 1
fi

echo "Installing abc-notify to ${INSTALL_DIR}..."
mkdir -p "${INSTALL_DIR}" "${SHARE_DIR}"
cp "${BIN_SOURCE}" "${INSTALL_DIR}/abc-notify"
cp "${NATIVE_SOURCE}" "${INSTALL_DIR}/abc-notify-native"
cp "${VERSION_SOURCE}" "${SHARE_DIR}/VERSION"
chmod +x "${INSTALL_DIR}/abc-notify" "${INSTALL_DIR}/abc-notify-native"

if [[ "${SKIP_SETUP}" != "1" ]]; then
  echo "Registering hooks..."
  "${INSTALL_DIR}/abc-notify" setup all
fi

if [[ "${SKIP_DOCTOR}" != "1" ]]; then
  echo "Running doctor..."
  "${INSTALL_DIR}/abc-notify" doctor
fi

echo "Manual install complete."
