#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

if ! command -v pnpm >/dev/null 2>&1; then
  echo "pnpm is required for deployment. Install pnpm and retry." >&2
  exit 1
fi

bash "${ROOT_DIR}/scripts/build-lite.sh"

COREPACK_ENABLE_STRICT=0 pnpm dlx wrangler deploy --config "${ROOT_DIR}/wrangler.toml"
