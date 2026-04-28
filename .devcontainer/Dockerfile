FROM debian:trixie-20260223-slim

# install packages
## git, ca-certificates, curl, zip, unzip, jq, less => for basic use
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        git \
        ca-certificates \
        curl \
        zip \
        unzip \
        jq \
        less \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Docker API version compatibility settings
# GitHub Codespaces環境では、ホスト側のDocker daemonが古いバージョン（24.0.9-2, API version 1.43）で動作している一方、
# devcontainer内にインストールされるDockerクライアントは新しいバージョン（29.1.4, API version 1.52）となる。
# この場合、クライアントがデフォルトで使用するAPIバージョン（1.52）が、
# ホスト側のDocker daemonでサポートされていない（最大1.43まで）ため、以下のエラーが発生する：
# "Error response from daemon: client version 1.52 is too new. Maximum supported API version is 1.43"
#
# この問題を解決するため、Dockerクライアントが使用するAPIバージョンを明示的に1.43に制限する。
# これにより、DooD（Docker-outside-of-Docker）構成において、新しいクライアントと古いdaemonの互換性を保つ。
# GitHub Codespacesのインフラ更新により、ホスト側のDocker daemonがアップデートされた場合は、
# この設定を見直す必要がある。
ENV DOCKER_API_VERSION=1.43

# install docker
RUN apt-get update && apt-get install --no-install-recommends -y \
        gnupg \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list \
    && apt-get update && apt-get install --no-install-recommends -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# install locale => for mise
RUN apt-get update \
    && apt-get install -y locales \
    && sed -i 's/# ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen ja_JP.UTF-8 \
    && update-locale LANG=ja_JP.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=ja_JP.UTF-8
ENV LANGUAGE=ja_JP:ja
ENV LC_ALL=ja_JP.UTF-8

# install mise
ARG MISE_VER=v2026.2.21
RUN curl https://mise.run | MISE_VERSION=${MISE_VER} sh \
    && echo 'eval "$( /root/.local/bin/mise activate bash )"' >> /root/.bashrc

# uv settings
# Suppress hardlink warning by using copy mode instead of hardlink
ENV UV_LINK_MODE=copy

# enable updateContentCommand for devcontainer
COPY .devcontainer/updateContentCommand.sh /updateContentCommand.sh
RUN chmod +x /updateContentCommand.sh

# enable postStartCommand for devcontainer
COPY .devcontainer/postStartCommand.sh /postStartCommand.sh
RUN chmod +x /postStartCommand.sh

CMD [ "sleep", "infinity" ]
