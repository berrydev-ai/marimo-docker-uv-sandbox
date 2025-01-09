# syntax=docker/dockerfile:1.12
FROM python:3.13-slim AS base

# Install curl for UV installation and healthcheck
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Create a non-root user first
RUN useradd -u 1000 -m appuser

# Install UV for appuser instead of root
USER appuser
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    echo 'export PATH="/home/appuser/.local/bin:$PATH"' >> /home/appuser/.bashrc

# Switch back to root for system-level operations
USER root
WORKDIR /app

ARG marimo_version=0.8.15
ENV MARIMO_SKIP_UPDATE_CHECK=1
# Update PATH to include appuser's local bin
ENV PATH="/home/appuser/.local/bin:${PATH}"

# Install marimo using UV for sandbox mode
RUN /home/appuser/.local/bin/uv pip install --system --no-cache marimo[recommended]==${marimo_version} && \
    mkdir -p /app/data && \
    chown -R appuser:appuser /app

# Copy configuration file
COPY --chown=appuser:appuser marimo.toml /app/.marimo.toml

ENV PORT=8080
EXPOSE $PORT

ENV HOST=0.0.0.0

# Switch back to appuser for running the container
USER appuser

# For debugging
# CMD ["tail", "-f", "/dev/null"]

FROM base AS slim
CMD ["uv", "run", "marimo", "edit", "--no-token", "-p", "8080", "--host", "0.0.0.0", "--sandbox"]

# # -slim entry point
# FROM base AS slim
# CMD ["uv", "run", "marimo", "edit", "--no-token", "-p", "8080", "--host", "0.0.0.0", "--sandbox"]

# # -data entry point
# FROM base AS data
# RUN /root/.local/bin/uv pip install --system --no-cache altair pandas numpy
# CMD ["uv", "run", "marimo", "edit", "--no-token", "-p", "8080", "--host", "0.0.0.0", "--sandbox"]

# # -sql entry point, extends -data
# FROM data AS sql
# RUN /root/.local/bin/uv pip install --system --no-cache "marimo[sql]"
# CMD ["uv", "run", "marimo", "edit", "--no-token", "-p", "8080", "--host", "0.0.0.0", "--sandbox"]