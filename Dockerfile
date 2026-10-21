FROM dailyco/pipecat-base:latest

COPY --from=ghcr.io/astral-sh/uv:0.13.4 /uv /bin/uv

COPY scripts/check-system-ca.sh /usr/local/bin/check-system-ca
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates openssl \
    && sh /usr/local/bin/check-system-ca \
    && rm -rf /var/lib/apt/lists/*


# Enable bytecode compilation
ENV UV_COMPILE_BYTECODE=1

# Copy from the cache instead of linking since it's a mounted volume
ENV UV_LINK_MODE=copy

# Install minimal runtime libs for OpenCV (required by SmallWebRTC)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libgl1 \
        libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Install the project's dependencies using the lockfile and settings
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --locked --no-install-project --no-dev

# Copy the application code
COPY ./bot.py bot.py
