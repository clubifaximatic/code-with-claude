#!/bin/bash
set -euo pipefail

NAME="${MACHINE_NAME:-dev-container-${HOSTNAME}}"

if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
    echo "WARNING: ANTHROPIC_API_KEY is not set. 'claude' CLI will not be authenticated." >&2
fi

if [[ -n "${GIT_USER_NAME:-}" ]]; then
    git config --global user.name "${GIT_USER_NAME}"
fi
if [[ -n "${GIT_USER_EMAIL:-}" ]]; then
    git config --global user.email "${GIT_USER_EMAIL}"
fi
if [[ -z "${GIT_USER_NAME:-}" || -z "${GIT_USER_EMAIL:-}" ]]; then
    echo "WARNING: GIT_USER_NAME and/or GIT_USER_EMAIL is not set. 'git commit' will fail until you set them (env vars, or 'git config --global user.name/user.email' manually)." >&2
fi

if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    git config --global credential.helper store
    echo "https://x-access-token:${GITHUB_TOKEN}@github.com" > "${HOME}/.git-credentials"
    chmod 600 "${HOME}/.git-credentials"
else
    echo "WARNING: GITHUB_TOKEN is not set. 'git push'/'git clone' over HTTPS to private GitHub repos will prompt for credentials." >&2
fi

echo "Starting VS Code tunnel as '${NAME}'..."
echo "If this is the first run, a device login URL/code will appear below."

exec code tunnel \
  --accept-server-license-terms \
  --disable-telemetry \
  --name "${NAME}"
