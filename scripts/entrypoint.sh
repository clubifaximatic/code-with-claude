#!/bin/bash
set -euo pipefail

NAME="${MACHINE_NAME:-dev-container-${HOSTNAME}}"

if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
    echo "WARNING: ANTHROPIC_API_KEY is not set. 'claude' CLI will not be authenticated." >&2
fi

echo "Starting VS Code tunnel as '${NAME}'..."
echo "If this is the first run, a device login URL/code will appear below."

exec code tunnel \
  --accept-server-license-terms \
  --disable-telemetry \
  --name "${NAME}"
