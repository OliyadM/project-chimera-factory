# Use a slim Python base image for smaller size
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Install system dependencies (make for Makefile support)
RUN apt-get update && apt-get install -y --no-install-recommends \
    make \
    && rm -rf /var/lib/apt/lists/*

# Install uv (faster dependency management)
RUN pip install --no-cache-dir uv

# Copy dependency files first (better caching)
COPY pyproject.toml ./

# Install project dependencies
RUN uv sync

# Copy the rest of the project
COPY . .

# Default command: run tests (expected to fail - TDD approach)
CMD ["uv", "run", "pytest", "tests/", "-v"]
