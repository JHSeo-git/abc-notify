#!/usr/bin/env bats

setup() {
  export TEST_REPO="${BATS_TEST_TMPDIR}/repo"
  export TEST_BIN_STUB="${BATS_TEST_TMPDIR}/stub-bin"
  export SWIFT_LOG="${BATS_TEST_TMPDIR}/swift.log"
  export LIPO_LOG="${BATS_TEST_TMPDIR}/lipo.log"

  mkdir -p "${TEST_REPO}/scripts" "${TEST_REPO}/.build/release" "${TEST_BIN_STUB}"
}

copy_script_under_test() {
  local script_name="$1"
  cp "${BATS_TEST_DIRNAME}/../../scripts/${script_name}" "${TEST_REPO}/scripts/${script_name}"
  chmod +x "${TEST_REPO}/scripts/${script_name}"
}

install_swift_stub() {
  cat > "${TEST_BIN_STUB}/swift" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "$*" >> "${SWIFT_LOG}"
mkdir -p .build/release
printf '#!/usr/bin/env bash\n' > .build/release/abc-notify-native
chmod +x .build/release/abc-notify-native
EOF
  chmod +x "${TEST_BIN_STUB}/swift"
}

install_lipo_stub() {
  cat > "${TEST_BIN_STUB}/lipo" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "$*" >> "${LIPO_LOG}"

if [[ "${1:-}" != "-create" || "${4:-}" != "-output" ]]; then
  echo "unexpected lipo args: $*" >&2
  exit 1
fi

cat "$2" "$3" > "$5"
EOF
  chmod +x "${TEST_BIN_STUB}/lipo"
}

@test "build-native-release: builds release binary and copies requested output" {
  copy_script_under_test "build-native-release.sh"
  install_swift_stub

  run env PATH="${TEST_BIN_STUB}:$PATH" SWIFT_LOG="${SWIFT_LOG}" \
    "${TEST_REPO}/scripts/build-native-release.sh" \
    --output "${TEST_REPO}/dist/abc-notify-native-arm64"

  [ "$status" -eq 0 ]
  [ -x "${TEST_REPO}/.build/release/abc-notify-native" ]
  [ -x "${TEST_REPO}/dist/abc-notify-native-arm64" ]
  [[ "$(cat "${SWIFT_LOG}")" == *"build -c release --product abc-notify-native --disable-sandbox"* ]]
}

@test "build-universal-native: merges two binaries into requested output" {
  copy_script_under_test "build-universal-native.sh"
  install_lipo_stub

  mkdir -p "${TEST_REPO}/artifacts"
  printf 'arm64\n' > "${TEST_REPO}/artifacts/arm64"
  printf 'x86_64\n' > "${TEST_REPO}/artifacts/x86_64"

  run env PATH="${TEST_BIN_STUB}:$PATH" LIPO_LOG="${LIPO_LOG}" \
    "${TEST_REPO}/scripts/build-universal-native.sh" \
    --arm64 "${TEST_REPO}/artifacts/arm64" \
    --x86_64 "${TEST_REPO}/artifacts/x86_64" \
    --output "${TEST_REPO}/dist/abc-notify-native"

  [ "$status" -eq 0 ]
  [ -f "${TEST_REPO}/dist/abc-notify-native" ]
  [[ "$(cat "${TEST_REPO}/dist/abc-notify-native")" == *"arm64"* ]]
  [[ "$(cat "${TEST_REPO}/dist/abc-notify-native")" == *"x86_64"* ]]
  [[ "$(cat "${LIPO_LOG}")" == *"-create ${TEST_REPO}/artifacts/arm64 ${TEST_REPO}/artifacts/x86_64 -output ${TEST_REPO}/dist/abc-notify-native"* ]]
}

@test "build-universal-native: fails when a required input is missing" {
  copy_script_under_test "build-universal-native.sh"
  install_lipo_stub

  mkdir -p "${TEST_REPO}/artifacts"
  printf 'arm64\n' > "${TEST_REPO}/artifacts/arm64"

  run env PATH="${TEST_BIN_STUB}:$PATH" LIPO_LOG="${LIPO_LOG}" \
    "${TEST_REPO}/scripts/build-universal-native.sh" \
    --arm64 "${TEST_REPO}/artifacts/arm64" \
    --x86_64 "${TEST_REPO}/artifacts/missing" \
    --output "${TEST_REPO}/dist/abc-notify-native"

  [ "$status" -eq 1 ]
  [[ "$output" == *"missing input"* ]]
}
