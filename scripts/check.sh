#!/usr/bin/env bash
# Check template syntax and behavior; lint and format scaffold scripts.

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
readonly SCRIPT_DIR PROJECT_DIR

main() {
  local tool

  for tool in shellcheck shfmt; do
    if ! command -v "${tool}" >/dev/null 2>&1; then
      printf 'Required tool is missing: %s\n' "${tool}" >&2
      return 1
    fi
  done

  bash -n "${PROJECT_DIR}/bash-boilerplate.sh" "${SCRIPT_DIR}/check.sh" \
    "${PROJECT_DIR}/tests/smoke.sh"
  shellcheck "${SCRIPT_DIR}/check.sh" \
    "${PROJECT_DIR}/tests/smoke.sh"
  shfmt -i 2 -ci -bn -d "${SCRIPT_DIR}/check.sh" \
    "${PROJECT_DIR}/tests/smoke.sh"
  bash "${PROJECT_DIR}/tests/smoke.sh"
}

main "$@"
