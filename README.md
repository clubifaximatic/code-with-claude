# VS Code Remote Tunnel + Claude Code CLI

Docker container for a remote dev box: starts a VS Code Remote Tunnel and
has the Claude Code CLI (`claude`) ready to use from the integrated
terminal. Runs on a remote machine; you connect to it from local VS Code
and all code executes remotely.

## Setup

The remote machine only *runs* the container — it doesn't build the
image. Build and push once from a machine with Docker (matching the
remote's CPU architecture), then pull + run on the remote.

### 1. Build and push (on your build machine)

```bash
docker login ghcr.io   # GitHub PAT with write:packages
GHCR_OWNER=your-github-username ./build-and-push.sh
```

This builds the image and pushes it to
`ghcr.io/your-github-username/vscode-claude-tunnel:latest`.

If you want to build+run locally without pushing anywhere (e.g. to test
changes), use the build override instead:

```bash
docker compose -f docker-compose.yml -f docker-compose.build.yml up -d --build
```

### 2. Run (on the remote machine)

Only `docker-compose.yml` and `.env` are needed here — no source files.

1. Copy the env template and fill in values:

   ```bash
   cp .env.example .env
   ```

   - `IMAGE` — the image you pushed in step 1, e.g.
     `ghcr.io/your-github-username/vscode-claude-tunnel:latest`.
   - `MACHINE_NAME` — name shown in the VS Code "Remote Tunnels" picker.
   - `ANTHROPIC_API_KEY` — your Claude API key.
   - `GEMINI_API_KEY` — your Google AI Studio API key (aistudio.google.com/apikey).

   If the image is private, also run `docker login ghcr.io` on the
   remote machine first (read-only PAT is enough).

2. Pull and start:

   ```bash
   docker compose pull
   docker compose up -d
   ```

3. First run only — device login:

   ```bash
   docker compose logs -f
   ```

   Look for a URL + code (e.g. `https://github.com/login/device`, code
   `XXXX-XXXX`). Open the URL in any browser, enter the code, approve.
   The tunnel CLI caches the resulting auth under `/home/dev/.vscode-cli`,
   which is a named volume — you won't need to log in again unless that
   volume is removed.

## Connect

In local VS Code: install the "Remote - Tunnels" extension, open the
Remote Explorer, and select the machine by the `MACHINE_NAME` you set.
Once connected, open `/workspace` — that's the persisted folder where
your code should live.

## Notes

- `claude --version` and a test prompt in the integrated terminal confirm
  the Claude API key is wired up correctly.
- `gemini --version` and `gemini -p "hello"` confirm the Gemini API key
  is wired up correctly.
- Restarting the container (`docker compose restart`) should not require
  re-login, since both the workspace and tunnel auth are on named volumes.
- Removing the `vscode-cli-auth` volume forces a fresh device login.
  Removing the `workspace` volume wipes any code stored there.
- No language runtimes are preinstalled — install what a given project
  needs (Node, Python, etc.) inside the container as needed.
