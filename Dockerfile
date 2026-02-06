# Use a slim Python base image for smaller size
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install uv (faster dependency management)
RUN pip install --no-cache-dir uv

# Copy dependency files first (better caching)
COPY pyproject.toml uv.lock* ./

# Install project dependencies
RUN uv sync --frozen

# Copy the rest of the project
COPY . .

# Default command: run tests (can be overridden)
CMD ["make", "test"]