# syntax=docker/dockerfile:1.7
# Base Chainguard Python image reference (overridable at build time).
ARG PYTHON_IMAGE=cgr.dev/chainguard/python

# Build stage uses the build platform for cross-platform builds.
FROM --platform=$BUILDPLATFORM ${PYTHON_IMAGE}:latest-dev AS builder
WORKDIR /app

# Copy application source and pre-compile Python files.
COPY src/ ./src/
RUN python -m compileall src

# Runtime stage targets the requested output platform.
FROM --platform=$TARGETPLATFORM ${PYTHON_IMAGE}:latest
WORKDIR /app

# Copy only runtime source artifacts from builder stage.
COPY --from=builder /app/src ./src
# Ensure logs are emitted immediately (no output buffering).
ENV PYTHONUNBUFFERED=1

# Run the Hello World entrypoint.
ENTRYPOINT ["python", "src/hello_world.py"]
