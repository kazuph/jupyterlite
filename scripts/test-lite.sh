#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
DIST_DIR="${ROOT_DIR}/dist"
PORT="${PORT:-4173}"

if ! command -v pnpm >/dev/null 2>&1; then
  echo "pnpm is required to run browser checks. Install pnpm and retry." >&2
  exit 1
fi

bash "${ROOT_DIR}/scripts/build-lite.sh"

if [[ ! -d "${DIST_DIR}" ]]; then
  echo "dist folder not found after build." >&2
  exit 1
fi

COREPACK_ENABLE_STRICT=0 pnpm dlx @playwright/test install --with-deps chromium >/dev/null

python3 -m http.server -b 127.0.0.1 "${PORT}" --directory "${DIST_DIR}" &
SERVER_PID=$!
trap 'kill ${SERVER_PID}' EXIT

until curl -fs "http://127.0.0.1:${PORT}" >/dev/null 2>&1; do
  sleep 1
done

PLAYWRIGHT_BASE_URL="http://127.0.0.1:${PORT}" COREPACK_ENABLE_STRICT=0 pnpm dlx @playwright/test test \
  --config "${ROOT_DIR}/tests/playwright.config.ts" \
  "${ROOT_DIR}/tests/pyodide-demo.spec.ts"
