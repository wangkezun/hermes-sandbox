FROM nikolaik/python-nodejs:python3.11-nodejs20

# 安装 gogcli（自动检测架构，支持 Apple Silicon 的 Docker）
ARG GOG_VERSION=0.34.0
RUN ARCH=$(dpkg --print-architecture) \
    && case "$ARCH" in \
         amd64) GOG_ARCH="amd64" ;; \
         arm64) GOG_ARCH="arm64" ;; \
         *) echo "Unsupported arch: $ARCH" && exit 1 ;; \
       esac \
    && cd /tmp \
    && curl -L -o gogcli.tar.gz \
       "https://github.com/openclaw/gogcli/releases/download/v${GOG_VERSION}/gogcli_${GOG_VERSION}_linux_${GOG_ARCH}.tar.gz" \
    && tar -xzf gogcli.tar.gz \
    && install -m 0755 gog /usr/local/bin/gog \
    && rm -rf /tmp/*

# Docker 容器里没有系统 keychain，用 file backend 存凭证
ENV GOG_KEYRING_BACKEND=file

# 验证安装
RUN gog --version
