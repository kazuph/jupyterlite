#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
DIST_DIR="${ROOT_DIR}/dist"
PORT="${PORT:-4173}"

if [[ ! -d "${DIST_DIR}" ]]; then
  echo "dist folder not found. Run pnpm run build:lite first." >&2
  exit 1
fi

echo "Serving ${DIST_DIR} on http://127.0.0.1:${PORT}"
cd "${DIST_DIR}"
python3 -m http.server -b 127.0.0.1 "${PORT}"
