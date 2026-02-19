# smol-prometheus

A slim, multi-stage Docker build for [Prometheus](https://github.com/prometheus/prometheus) based on Alpine Linux.

This repository provides a minimal containerized version of Prometheus, built from source, optimized for size and security.

## Features

- **Slim Alpine Base**: Built on the latest Alpine versions for a tiny footprint.
- **Multi-Stage Build**: Compiles Prometheus from source and only includes the binary and necessary assets in the final image.
- **Non-Root Execution**: Runs as a `prometheus` system user with configurable UID/GID for better security and easier volume mounting.
- **Highly Configurable**: Supports custom Alpine versions and User/Group IDs via build arguments.

## Quick Start

### Build

```bash
docker build -t smol-prometheus .
```

To build with a specific Alpine version or matching your local user ID:

```bash
docker build \
  --build-arg ALPINE_VERSION=3.20 \
  --build-arg UID=$(id -u) \
  --build-arg GID=$(id -g) \
  -t smol-prometheus .
```

### Run

Run Prometheus with your own configuration and persistent storage:

```bash
docker run -d \
  -p 9090:9090 \
  -v /path/to/prometheus.yml:/etc/prometheus/prometheus.yml \
  -v smol-prometheus-data:/prometheus \
  --name prometheus \
  smol-prometheus
```

## Directory Structure

- `/usr/local/bin/prometheus`: The Prometheus binary.
- `/etc/prometheus/prometheus.yml`: Default configuration file path.
- `/prometheus`: Working directory and default TSDB storage path.
- `/usr/share/prometheus/`: Console templates and libraries.
