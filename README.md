# hermes-sandbox

Docker image used as the execution sandbox for the hermes agent. Built on
`nikolaik/python-nodejs` (Python 3.11 + Node.js 20) with [`gogcli`](https://github.com/openclaw/gogcli)
preinstalled for Google Workspace access and the official `zhihu-cli` for
Zhihu Open Platform skills.

## Build

```sh
docker build -t hermes-sandbox .
```

Multi-arch is supported automatically (amd64 / arm64).

## Zhihu CLI

`zhihu-cli` is pinned with the `ZHIHU_VERSION` build argument and installed at
`/opt/zhihu-cli`. `ZHIHU_CLI_HOME` points the mounted Zhihu skill at that
location; installing under `/root` would be hidden by Hermes' persistent home
mount.

Install the Zhihu skill separately under `~/.hermes/skills/zhihu` on the host.
For authenticated personal-data commands, add `ZHIHU_ACCESS_SECRET` to
`terminal.docker_forward_env` and supply its value through the Hermes host
environment or `~/.hermes/.env`. Never bake the secret into this image or
commit it to the repository.

## Auto-update

The `gogcli` version is pinned via the `GOG_VERSION` build arg. A scheduled
GitHub Actions workflow (`.github/workflows/update-gogcli.yml`) checks
`openclaw/gogcli` for new releases weekly and opens a PR when one is found.
