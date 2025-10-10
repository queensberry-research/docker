# base image
FROM python:3.12-slim-bookworm AS base

# age
RUN apt-get update \
    && apt-get install -y --no-install-recommends age \
    && rm -rf /var/lib/apt/lists/*

# network
RUN apt-get update \
    && apt-get install -y --no-install-recommends dnsutils inetutils-traceroute iputils-ping iproute2 net-tools \
    && rm -rf /var/lib/apt/lists/*

# psycopg
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential libpq-dev python3-dev \
    && rm -rf /var/lib/apt/lists/*

# sops
#  - ghcr   | https://github.com/getsops/sops/pkgs/container/sops/versions
#  - source | https://github.com/getsops/sops/blob/1c1b3c8787a9837bdeab616903e44666bae404d3/.release/Dockerfile
FROM ghcr.io/getsops/sops:v3.10.2 AS sops

# uv
#  - docker hub | https://hub.docker.com/r/astral/uv
#  - ghcr       | https://github.com/astral-sh/uv/pkgs/container/uv/versions
#  - source     | https://github.com/astral-sh/uv/blob/9be016f3f8fdc3ac7974ed82762aa3364f6e8f2b/.github/workflows/build-docker.yml
FROM ghcr.io/astral-sh/uv:0.9-python3.12-bookworm-slim AS uv

# final image
FROM base

# sops
COPY --from=sops /usr/local/bin/sops /usr/local/bin/

# uv
COPY --from=uv /usr/local/bin/uv /usr/local/bin/
COPY --from=uv /usr/local/bin/uvx /usr/local/bin/

# test
RUN set -e; \
    echo 'checking binaries...'; \
    for bin in age dig gcc ip ld make nslookup pg_config ping sops uv; do \
        if ! command -v "${bin}" >/dev/null 2>&1; then \
            echo "ERROR: '${bin}' not found on PATH" >&2; \
            exit 1; \
        fi; \
    done

CMD ["/bin/sh"]
