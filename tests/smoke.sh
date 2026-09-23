#!/usr/bin/env bash
# Exercise the starter script's public command-line behavior.

set -Eeuo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="${PROJECT_DIR}/bash-boilerplate.sh"
readonly PROJECT_DIR SCRIPT

fail() {
  printf 'Smoke test failed: %s\n' "$1" >&2
  exit 1
}

main() {
  local output
  local error_output
  local status

  output="$(bash "${SCRIPT}")" || fail 'default invocation'
  [[ "${output}" == '[INFO] Script completed successfully.' ]] || fail 'stdout'

  output="$(bash "${SCRIPT}" -h)" || fail 'help invocation'
  [[ "${output}" == *'Usage:'* ]] || fail 'help text'

  output="$(bash "${SCRIPT}" -v)" || fail 'verbose invocation'
  [[ "${output}" == *'[INFO] Verbose mode enabled.'* ]] || fail 'verbose output'

  status=0
  bash "${SCRIPT}" -x >/dev/null 2>&1 || status=$?
  [[ ${status} -eq 1 ]] || fail 'invalid option status'

  printf 'Smoke tests passed.\n'
}

main "$@"
