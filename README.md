# Code With Claude

Docker container for a remote dev box: 
* starts a Visual Studio Code Tunnel and
* has the Claude Code CLI (`claude`) ready to use from the integrated terminal

Runs on a remote machine. You connect to it from local Visual Studio Code and 
all code executes remotely.

## Setup

### docker-compose.yml

```
services:
  code-with-claude:
    image: ghcr.io/clubifaximatic/code-with-claude:latest
    env_file:
      - .env
    environment:
      - MACHINE_NAME=${MACHINE_NAME:-my-machine}
    volumes:
      - workspace:/workspace
      - vscode-cli-auth:/home/dev/.vscode-cli
      - claude-config:/home/dev/.claude
      - dev-config:/home/dev/.config
    restart: unless-stopped

volumes:
  workspace:
  vscode-cli-auth:
  claude-config:
  dev-config:
```
### command line


```bash
docker pull ghcr.io/clubifaximatic/code-with-claude:latest
```

## Environment Variables

* MACHINE_NAME: (optional) The name of the remote machine. Default value: "dev-container-${HOSTNAME}"
* ANTHROPIC_API_KEY: (optional) Your Anthropic Claude ApiKey. Default value: null

## Which way should I authenticate Claude Code?

Claude.ai subscriptions (Pro/Max) and the Anthropic API are billed
**separately** — a Pro/Max plan does not include any API usage, and an
`ANTHROPIC_API_KEY` is always pay-as-you-go on top of it. Pick based on what
you already pay for:

* **You have a Claude Pro or Max subscription and want to stay within that
  plan's cost** — use `claude login` and leave `ANTHROPIC_API_KEY` **unset**
  (don't put it in `.env` at all, not even empty). Run `claude login` once
  in the container's integrated terminal and follow the device-login URL;
  the session is cached under `/home/dev/.claude` and `/home/dev/.config`
  (named volumes above), so you won't need to log in again after a restart
  or image rebuild.
* **You don't have a Pro/Max subscription** (or you want usage billed
  independently, e.g. for a team/service account) — use an
  `ANTHROPIC_API_KEY` instead:
  1. Go to the [Anthropic Console](https://console.anthropic.com/) and sign
     in (or create an account) — this is a different account/billing system
     than claude.ai.
  2. Set up billing under **Settings → Billing**.
  3. Go to **Settings → API Keys** and click **Create Key**.
  4. Put it in `.env`: `ANTHROPIC_API_KEY=sk-ant-...`

> **Important:** if `ANTHROPIC_API_KEY` is set at all, Claude Code always
> uses it instead of your subscription login — it does **not** fall back to
> `claude login` just because you're on Pro/Max, and there's no way to have
> API usage billed through a subscription. Simply omit (or comment out) the
> `ANTHROPIC_API_KEY` line in `.env` to make sure your Pro/Max plan is what
> covers usage.

## Register

Look for this in the logs

```
To grant access to the server, please log into https://github.com/login/device and use code XXX-XXX
```

The tunnel CLI caches the resulting auth under `/home/dev/.vscode-cli`, which
is a named volume — you won't need to log in again unless that volume is
removed.

If you use `claude login` (Pro/Max subscription) instead of `ANTHROPIC_API_KEY`,
that session is stored under `/home/dev/.claude` and `/home/dev/.config` —
also named volumes above, so it survives container restarts and rebuilds too.

## Connect

In local VS Code: install the "Remote - Tunnels" extension, open the
Remote Explorer, and select the machine by the `MACHINE_NAME` you set.
Once connected, open `/workspace` — that's the persisted folder where
your code should live.

## Notes

- `claude --version` and a test prompt in the integrated terminal confirm
  Claude Code is authenticated correctly, whichever method you used.
- Removing the `vscode-cli-auth` volume forces a fresh device login.
  Removing the `claude-config`/`dev-config` volumes forces a fresh `claude login`.
  Removing the `workspace` volume wipes any code stored there.
- No language runtimes are preinstalled
- VS Code CLI and Claude Code versions are pinned at build time
  (`VSCODE_CLI_VERSION`, `CLAUDE_CODE_VERSION` build args in the Dockerfile)
  for reproducible builds. Bump them deliberately when you rebuild the image.
- On a NAS, you can replace the `workspace` named volume with a bind mount
  (e.g. `/volume1/projects:/workspace`) to browse/backup your code directly
  from the NAS file browser instead of Docker's internal volume storage.
