# hermes-sandbox

Docker image used as the execution sandbox for the Hermes agent. Built on the
official `nousresearch/hermes-sandbox:desktop` image (Python 3.13 + Node.js 26),
which includes Chromium, the desktop stack, `cua-driver`, and common command-line
tools. This image adds [`gogcli`](https://github.com/openclaw/gogcli) for Google
Workspace access and the official `zhihu-cli` for Zhihu Open Platform skills.

The upstream `desktop` tag is refreshed when this image is rebuilt, so use
`docker build --pull` when updating locally.

## Build

```sh
docker build --pull -t wangkezun/hermes-sandbox:latest .
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
