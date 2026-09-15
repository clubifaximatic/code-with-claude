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
  vscode-claude-tunnel:
    image: ghcr.io/clubifaximatic/vscode-claude-tunnel:latest
    env_file:
      - .env
    environment:
      - MACHINE_NAME=${MACHINE_NAME:-my-machine}
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY:-unknown}
    volumes:
      - workspace:/workspace
      - vscode-cli-auth:/home/dev/.vscode-cli
    restart: unless-stopped

volumes:
  workspace:
  vscode-cli-auth:
```
### command line


```bash
docker compose -f docker-compose.yml -f docker-compose.build.yml up -d --build
```

## Environment Variables

* MACHINE_NAME: (mandatory) The name of the remote machine
* ANTHROPIC_API_KEY: (optional) Your Anthropic Claude ApiKey

## Register

Look for this in the logs

```
To grant access to the server, please log into https://github.com/login/device and use code XXX-XXX
```

The tunnel CLI caches the resulting auth under `/home/dev/.vscode-cli`, which 
is a named volume — you won't need to log in again unless that volume is
removed

## Connect

In local VS Code: install the "Remote - Tunnels" extension, open the
Remote Explorer, and select the machine by the `MACHINE_NAME` you set.
Once connected, open `/workspace` — that's the persisted folder where
your code should live.

## Notes

- `claude --version` and a test prompt in the integrated terminal confirm
  the Claude API key is wired up correctly.
- Removing the `vscode-cli-auth` volume forces a fresh device login.
  Removing the `workspace` volume wipes any code stored there.
- No language runtimes are preinstalled 
