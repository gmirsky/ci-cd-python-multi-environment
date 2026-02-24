# syntax=docker/dockerfile:1.7
ARG PYTHON_IMAGE=cgr.dev/chainguard/python

FROM --platform=$BUILDPLATFORM ${PYTHON_IMAGE}:latest-dev AS builder
WORKDIR /app

COPY src/ ./src/
RUN python -m compileall src

FROM --platform=$TARGETPLATFORM ${PYTHON_IMAGE}:latest
WORKDIR /app

COPY --from=builder /app/src ./src
ENV PYTHONUNBUFFERED=1

ENTRYPOINT ["python", "src/hello_world.py"]
