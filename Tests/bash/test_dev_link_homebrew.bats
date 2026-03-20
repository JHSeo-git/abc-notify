#!/usr/bin/env bats

setup() {
  export TEST_REPO="${BATS_TEST_TMPDIR}/repo"
  export TEST_PREFIX="${BATS_TEST_TMPDIR}/prefix"
  export TEST_BIN_STUB="${BATS_TEST_TMPDIR}/stub-bin"

  mkdir -p "${TEST_REPO}/scripts" "${TEST_PREFIX}/bin" "${TEST_BIN_STUB}"

  cat > "${TEST_BIN_STUB}/brew" <<EOF
#!/usr/bin/env bash
set -euo pipefail

if [[ "\${1:-}" != "--prefix" ]]; then
  echo "unexpected brew args: \$*" >&2
  exit 1
fi

echo "${TEST_PREFIX}"
EOF
  chmod +x "${TEST_BIN_STUB}/brew"
}

copy_script_under_test() {
  cp "${BATS_TEST_DIRNAME}/../../scripts/dev-link-homebrew.sh" "${TEST_REPO}/scripts/dev-link-homebrew.sh"
  chmod +x "${TEST_REPO}/scripts/dev-link-homebrew.sh"
}

prepare_sources() {
  mkdir -p "${TEST_REPO}/bin" "${TEST_REPO}/.build/release"
  printf '#!/usr/bin/env bash\n' > "${TEST_REPO}/bin/abc-notify"
  printf '#!/usr/bin/env bash\n' > "${TEST_REPO}/.build/release/abc-notify-native"
  chmod +x "${TEST_REPO}/bin/abc-notify" "${TEST_REPO}/.build/release/abc-notify-native"
}

@test "dev-link-homebrew: link creates abc-notify symlinks in brew prefix" {
  prepare_sources
  copy_script_under_test

  PATH="${TEST_BIN_STUB}:$PATH" run "${TEST_REPO}/scripts/dev-link-homebrew.sh" link

  [ "$status" -eq 0 ]
  [ -L "${TEST_PREFIX}/bin/abc-notify" ]
  [ -L "${TEST_PREFIX}/bin/abc-notify-native" ]
  [ "$(readlink "${TEST_PREFIX}/bin/abc-notify")" = "${TEST_REPO}/bin/abc-notify" ]
  [ "$(readlink "${TEST_PREFIX}/bin/abc-notify-native")" = "${TEST_REPO}/.build/release/abc-notify-native" ]
}

@test "dev-link-homebrew: unlink removes only symlink targets" {
  copy_script_under_test
  ln -s "${TEST_REPO}/bin/abc-notify" "${TEST_PREFIX}/bin/abc-notify"
  ln -s "${TEST_REPO}/.build/release/abc-notify-native" "${TEST_PREFIX}/bin/abc-notify-native"

  PATH="${TEST_BIN_STUB}:$PATH" run "${TEST_REPO}/scripts/dev-link-homebrew.sh" unlink

  [ "$status" -eq 0 ]
  [ ! -e "${TEST_PREFIX}/bin/abc-notify" ]
  [ ! -e "${TEST_PREFIX}/bin/abc-notify-native" ]
}

@test "dev-link-homebrew: link refuses to replace regular files" {
  prepare_sources
  copy_script_under_test
  printf 'real file\n' > "${TEST_PREFIX}/bin/abc-notify"

  PATH="${TEST_BIN_STUB}:$PATH" run "${TEST_REPO}/scripts/dev-link-homebrew.sh" link

  [ "$status" -eq 1 ]
  [[ "$output" == *"non-symlink target"* ]]
}
