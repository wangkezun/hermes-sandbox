FROM nikolaik/python-nodejs:python3.11-nodejs20

# 安装 gogcli（自动检测架构，支持 Apple Silicon 的 Docker）
ARG GOG_VERSION=0.31.1
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

# 安装知乎官方 CLI。安装到 /opt，避免 Hermes 挂载持久化 /root 后遮住二进制。
ARG ZHIHU_VERSION=0.3.0
ENV ZHIHU_CLI_HOME=/opt/zhihu-cli
RUN ARCH=$(dpkg --print-architecture) \
    && case "$ARCH" in \
         amd64) ZHIHU_ARCH="amd64"; ZHIHU_SHA256="d7e89a2d5df20ab367d944c2a1f7694b6272705c18ebc8d7388129a7933e0e80" ;; \
         arm64) ZHIHU_ARCH="arm64"; ZHIHU_SHA256="42296df3bc7f4678e050c6fb6e627f4ad87c6f3755e9f6b248a0813bea3dd2c7" ;; \
         *) echo "Unsupported arch: $ARCH" && exit 1 ;; \
       esac \
    && cd /var/tmp \
    && curl --fail --location --silent --show-error --proto '=https' --tlsv1.2 \
       --output zhihu-cli.tar.gz \
       "https://developer-cdn.zhihu.com/zhihu-cli/releases/stable/cli/${ZHIHU_VERSION}/zhihu-cli-${ZHIHU_VERSION}-linux-${ZHIHU_ARCH}.tar.gz" \
    && printf '%s  %s\n' "$ZHIHU_SHA256" zhihu-cli.tar.gz | sha256sum -c - \
    && [ "$(tar -tzf zhihu-cli.tar.gz)" = "zhihu-cli" ] \
    && install -d -m 0755 \
       "$ZHIHU_CLI_HOME/versions/$ZHIHU_VERSION" \
       "$ZHIHU_CLI_HOME/current" \
    && tar -xOzf zhihu-cli.tar.gz zhihu-cli \
       > "$ZHIHU_CLI_HOME/versions/$ZHIHU_VERSION/zhihu-cli" \
    && chmod 0755 "$ZHIHU_CLI_HOME/versions/$ZHIHU_VERSION/zhihu-cli" \
    && cp "$ZHIHU_CLI_HOME/versions/$ZHIHU_VERSION/zhihu-cli" \
       "$ZHIHU_CLI_HOME/current/zhihu-cli" \
    && ln -s "$ZHIHU_CLI_HOME/current/zhihu-cli" /usr/local/bin/zhihu-cli \
    && zhihu-cli version | grep -F "\"version\":\"$ZHIHU_VERSION\"" \
    && rm -f zhihu-cli.tar.gz

# Docker 容器里没有系统 keychain，用 file backend 存凭证
ENV GOG_KEYRING_BACKEND=file

# 验证安装
RUN gog --version
RUN zhihu-cli version
