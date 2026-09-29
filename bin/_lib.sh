#!/usr/bin/env bash
# bin/_lib.sh

set -euo pipefail

BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$BIN_DIR/.." && pwd)"
export BIN_DIR ROOT_DIR

MISE_BIN="${MISE_BIN:-}"
if [[ -z "$MISE_BIN" ]] && command -v mise >/dev/null 2>&1; then
  MISE_BIN="$(command -v mise)"
elif [[ -z "$MISE_BIN" && -x "${HOME}/.local/bin/mise" ]]; then
  MISE_BIN="${HOME}/.local/bin/mise"
fi

cd "$ROOT_DIR"

run() {
  if [[ -n "$MISE_BIN" ]]; then
    "$MISE_BIN" exec -- "$@"
  else
    "$@"
  fi
}

say() {
  printf '\n==> %s\n' "$*"
}
