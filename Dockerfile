FROM debian:trixie-slim AS base

ENV PATH=/root/.local/bin:$PATH

RUN echo '' \
    # apt
    && apt-get update \
    # apt - age
    && apt-get install -y --no-install-recommends age \
    # apt - git
    && apt-get install -y --no-install-recommends git \
    # apt - psycopg
    && apt-get install -y --no-install-recommends build-essential libpq-dev \
    # docker
    && apt-get install -y --no-install-recommends ca-certificates curl \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null \
    && apt-get update \
    && apt-get install -y --no-install-recommends docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
    # apt
    && rm -rf /var/lib/apt/lists/* \
    && echo ''

COPY --from=ghcr.io/getsops/sops:v3.11.0 /usr/local/bin/sops /usr/local/bin/
# https://github.com/getsops/sops/pkgs/container/sops

COPY --from=ghcr.io/astral-sh/uv:0.9-python3.13-trixie-slim /usr/local/bin/uv /usr/local/bin/uvx /usr/local/bin/
# https://github.com/astral-sh/uv/pkgs/container/uv

COPY --from=mikefarah/yq:4 /usr/bin/yq /usr/local/bin/
# https://github.com/mikefarah/yq/pkgs/container/yq

RUN echo '' \
    && uv tool install bump-my-version \
    && if ! age --help >/dev/null 2>&1; then echo "ERROR: 'age --help' failed" >&2; exit 1; fi \
    && if ! bump-my-version --help >/dev/null 2>&1; then echo "ERROR: 'bump-my-version --help' failed" >&2; exit 1; fi \
    && if ! curl --help >/dev/null 2>&1; then echo "ERROR: 'curl --help' failed" >&2; exit 1; fi \
    && if ! docker --help >/dev/null 2>&1; then echo "ERROR: 'docker --help' failed" >&2; exit 1; fi \
    && if ! docker buildx --help >/dev/null 2>&1; then echo "ERROR: 'docker buildx --help' failed" >&2; exit 1; fi \
    && if ! docker compose --help >/dev/null 2>&1; then echo "ERROR: 'docker compose --help' failed" >&2; exit 1; fi \
    && if ! git --help >/dev/null 2>&1; then echo "ERROR: 'git --help' failed" >&2; exit 1; fi \
    && if ! sops --help >/dev/null 2>&1; then echo "ERROR: 'sops --help' failed" >&2; exit 1; fi \
    && if ! yq --help >/dev/null 2>&1; then echo "ERROR: 'yq --help' failed" >&2; exit 1; fi \
    && echo ''

CMD ["/bin/sh"]
