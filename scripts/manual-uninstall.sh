#!/usr/bin/env bash
# Manual uninstall for a local abc-notify install.

set -euo pipefail

INSTALL_DIR="${ABC_NOTIFY_INSTALL_DIR:-/usr/local/bin}"
SHARE_DIR="${ABC_NOTIFY_SHARE_DIR:-/usr/local/share/abc-notify}"
STATE_DIR="${ABC_NOTIFY_STATE_DIR:-/tmp/abc-notify}"
SKIP_REMOVE_HOOKS="${ABC_NOTIFY_SKIP_REMOVE_HOOKS:-0}"

ABC_NOTIFY_BIN="${INSTALL_DIR}/abc-notify"
NATIVE_BIN="${INSTALL_DIR}/abc-notify-native"
VERSION_FILE="${SHARE_DIR}/VERSION"

echo "Uninstalling abc-notify..."

if [[ "${SKIP_REMOVE_HOOKS}" != "1" ]] && [[ -x "${ABC_NOTIFY_BIN}" ]]; then
  "${ABC_NOTIFY_BIN}" remove all 2>/dev/null || true
fi

if [[ -e "${ABC_NOTIFY_BIN}" ]]; then
  rm -f "${ABC_NOTIFY_BIN}"
  echo "Removed ${ABC_NOTIFY_BIN}"
fi

if [[ -e "${NATIVE_BIN}" ]]; then
  rm -f "${NATIVE_BIN}"
  echo "Removed ${NATIVE_BIN}"
fi

if [[ -e "${VERSION_FILE}" ]]; then
  rm -f "${VERSION_FILE}"
  echo "Removed ${VERSION_FILE}"
fi

if [[ -d "${SHARE_DIR}" ]] && [[ -z "$(ls -A "${SHARE_DIR}")" ]]; then
  rmdir "${SHARE_DIR}"
fi

if [[ -d "${STATE_DIR}" ]]; then
  rm -rf "${STATE_DIR}"
  echo "Removed ${STATE_DIR}"
fi

echo "Manual uninstall complete."
