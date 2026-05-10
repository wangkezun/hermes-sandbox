# hermes-sandbox

Docker image used as the execution sandbox for the hermes agent. Built on
`nikolaik/python-nodejs` (Python 3.11 + Node.js 20) with [`gogcli`](https://github.com/openclaw/gogcli)
preinstalled for Google Workspace access from the agent's tools.

## Build

```sh
docker build -t hermes-sandbox .
```

Multi-arch is supported automatically (amd64 / arm64).

## Auto-update

The `gogcli` version is pinned via the `GOG_VERSION` build arg. A scheduled
GitHub Actions workflow (`.github/workflows/update-gogcli.yml`) checks
`openclaw/gogcli` for new releases weekly and opens a PR when one is found.
