# syntax=docker/dockerfile:1.12
FROM python:3.12-slim-bookworm

# Install UV for appuser instead of root
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app
ENV MARIMO_SKIP_UPDATE_CHECK=1

# Create a non-root user first
RUN useradd -u 1000 -m appuser

# Set up data folder
RUN mkdir -p /app/data && \
    chown -R appuser:appuser /app

USER appuser

# Copy configuration file
COPY --chown=appuser:appuser marimo.toml /app/.marimo.toml

ENV PORT=8080
EXPOSE $PORT

ENV HOST=0.0.0.0

# Run marimo in sandbox mode
CMD ["uvx", "marimo", "edit", "--no-token", "-p", "8080", "--host", "0.0.0.0", "--sandbox"]