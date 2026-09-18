FROM ubuntu:26.04

ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETARCH=amd64
ARG USER_UID=1000
ARG USER_GID=1000
ARG VSCODE_CLI_VERSION=1.138.0
ARG CLAUDE_CODE_VERSION=2.1.277

ENV TZ=UTC

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    procps \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

#
# install Visual Studio Code CLI (as root), pinned to VSCODE_CLI_VERSION
#
RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64) VSCODE_ARCH="alpine-x64" ;; \
      arm64) VSCODE_ARCH="alpine-arm64" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL "https://update.code.visualstudio.com/${VSCODE_CLI_VERSION}/cli-${VSCODE_ARCH}/stable" --output /tmp/vscode-cli.tar.gz; \
    tar -xzf /tmp/vscode-cli.tar.gz -C /usr/local/bin; \
    rm /tmp/vscode-cli.tar.gz; \
    chmod +x /usr/local/bin/code

#
# new user
#
RUN groupadd --non-unique --gid ${USER_GID} dev \
    && useradd --non-unique --uid ${USER_UID} --gid ${USER_GID} -m -s /bin/bash dev \
    && mkdir -p /workspace \
    && chown -R dev:dev /workspace \
    && mkdir -p /home/dev/.vscode-cli /home/dev/.claude /home/dev/.config \
    && chown -R dev:dev /home/dev/.vscode-cli /home/dev/.claude /home/dev/.config

USER dev
ENV PATH="/home/dev/.local/bin:${PATH}"

#
# install Claude Code (as dev), pinned to CLAUDE_CODE_VERSION
#
RUN curl -fsSL https://claude.ai/install.sh | bash -s "${CLAUDE_CODE_VERSION}"

COPY --chown=dev:dev scripts/entrypoint.sh /home/dev/entrypoint.sh
RUN chmod +x /home/dev/entrypoint.sh

WORKDIR /workspace

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD pgrep -f "code tunnel" || exit 1

ENTRYPOINT ["/home/dev/entrypoint.sh"]
