#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
VENV_PATH="${ROOT_DIR}/.venv"

if [[ ! -d "${VENV_PATH}" ]]; then
  echo "Creating Python virtual environment at ${VENV_PATH}"
  python3 -m venv "${VENV_PATH}"
fi

echo "Ensuring jupyterlite-core is installed in the virtual environment"
"${VENV_PATH}/bin/python" -m pip install --upgrade pip >/dev/null
"${VENV_PATH}/bin/python" -m pip install -e "${ROOT_DIR}/py/jupyterlite-core" >/dev/null

ARCHIVE_PATTERN="${ROOT_DIR}/py/jupyterlite-core/jupyterlite_core/jupyterlite-*.tgz"
if ! compgen -G "${ARCHIVE_PATTERN}" >/dev/null; then
  echo "Installing JS dependencies for packaging"
  COREPACK_ENABLE_STRICT=0 yarn install --immutable >/dev/null
  echo "Packaging JupyterLite application bundle"
  COREPACK_ENABLE_STRICT=0 yarn pack:app >/dev/null
fi

echo "Building JupyterLite site into ${ROOT_DIR}/dist"
pushd "${ROOT_DIR}/app" >/dev/null
"${VENV_PATH}/bin/jupyter" lite build \
  --lite-dir "${PWD}" \
  --output-dir "${ROOT_DIR}/dist" \
  --config "${ROOT_DIR}/app/jupyter_lite_config.json"
popd >/dev/null
