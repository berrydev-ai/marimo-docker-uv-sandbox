# syntax=docker/dockerfile:1.12
FROM python:3.12-slim-bookworm

# Install UV for appuser instead of root
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Create a non-root user first
RUN useradd -u 1000 -m appuser

USER appuser

# Run marimo in sandbox mode
CMD ["uvx", "marimo", "edit", "--no-token", "-p", "8080", "--host", "0.0.0.0", "--sandbox"]