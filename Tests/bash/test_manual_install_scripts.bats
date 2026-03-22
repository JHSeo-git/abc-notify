#!/usr/bin/env bats

setup() {
  export TEST_REPO="${BATS_TEST_TMPDIR}/repo"
  export TEST_INSTALL_DIR="${BATS_TEST_TMPDIR}/install/bin"
  export TEST_SHARE_DIR="${BATS_TEST_TMPDIR}/install/share/abc-notify"
  export TEST_STATE_DIR="${BATS_TEST_TMPDIR}/state"
  export TEST_BIN_STUB="${BATS_TEST_TMPDIR}/stub-bin"

  mkdir -p "${TEST_REPO}/scripts" "${TEST_REPO}/bin" "${TEST_BIN_STUB}"
  printf '#!/usr/bin/env bash\necho manual install binary\n' > "${TEST_REPO}/bin/abc-notify"
  chmod +x "${TEST_REPO}/bin/abc-notify"
  printf 'v1.2.3\n' > "${TEST_REPO}/VERSION"
}

copy_manual_scripts_under_test() {
  cp "${BATS_TEST_DIRNAME}/../../scripts/manual-install.sh" "${TEST_REPO}/scripts/manual-install.sh"
  cp "${BATS_TEST_DIRNAME}/../../scripts/manual-uninstall.sh" "${TEST_REPO}/scripts/manual-uninstall.sh"
  chmod +x "${TEST_REPO}/scripts/manual-install.sh" "${TEST_REPO}/scripts/manual-uninstall.sh"
}

stub_swift_build() {
  cat > "${TEST_BIN_STUB}/swift" <<EOF
#!/usr/bin/env bash
set -euo pipefail

if [[ "\$*" != "build -c release" ]]; then
  echo "unexpected swift args: \$*" >&2
  exit 1
fi

mkdir -p "${TEST_REPO}/.build/release"
printf '#!/usr/bin/env bash\necho native helper\n' > "${TEST_REPO}/.build/release/abc-notify-native"
chmod +x "${TEST_REPO}/.build/release/abc-notify-native"
EOF
  chmod +x "${TEST_BIN_STUB}/swift"
}

@test "manual-install: builds release helper and installs binaries from repo checkout" {
  copy_manual_scripts_under_test
  stub_swift_build

  PATH="${TEST_BIN_STUB}:$PATH" run env \
    ABC_NOTIFY_SKIP_PLATFORM_CHECK=1 \
    ABC_NOTIFY_SKIP_SETUP=1 \
    ABC_NOTIFY_SKIP_DOCTOR=1 \
    ABC_NOTIFY_INSTALL_DIR="${TEST_INSTALL_DIR}" \
    ABC_NOTIFY_SHARE_DIR="${TEST_SHARE_DIR}" \
    "${TEST_REPO}/scripts/manual-install.sh"

  [ "$status" -eq 0 ]
  [ -x "${TEST_INSTALL_DIR}/abc-notify" ]
  [ -x "${TEST_INSTALL_DIR}/abc-notify-native" ]
  [ -f "${TEST_SHARE_DIR}/VERSION" ]
  [ "$(tr -d '\r\n' < "${TEST_SHARE_DIR}/VERSION")" = "v1.2.3" ]
}

@test "manual-uninstall: removes installed files and temp state" {
  copy_manual_scripts_under_test

  mkdir -p "${TEST_INSTALL_DIR}" "${TEST_SHARE_DIR}" "${TEST_STATE_DIR}"
  printf '#!/usr/bin/env bash\n' > "${TEST_INSTALL_DIR}/abc-notify"
  printf '#!/usr/bin/env bash\n' > "${TEST_INSTALL_DIR}/abc-notify-native"
  printf 'v1.2.3\n' > "${TEST_SHARE_DIR}/VERSION"
  chmod +x "${TEST_INSTALL_DIR}/abc-notify" "${TEST_INSTALL_DIR}/abc-notify-native"

  PATH="${TEST_BIN_STUB}:$PATH" run env \
    ABC_NOTIFY_SKIP_REMOVE_HOOKS=1 \
    ABC_NOTIFY_INSTALL_DIR="${TEST_INSTALL_DIR}" \
    ABC_NOTIFY_SHARE_DIR="${TEST_SHARE_DIR}" \
    ABC_NOTIFY_STATE_DIR="${TEST_STATE_DIR}" \
    "${TEST_REPO}/scripts/manual-uninstall.sh"

  [ "$status" -eq 0 ]
  [ ! -e "${TEST_INSTALL_DIR}/abc-notify" ]
  [ ! -e "${TEST_INSTALL_DIR}/abc-notify-native" ]
  [ ! -e "${TEST_SHARE_DIR}/VERSION" ]
  [ ! -e "${TEST_STATE_DIR}" ]
}
