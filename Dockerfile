ARG ALPINE_VERSION=3.19
ARG UID=100
ARG GID=100

# Stage 1: Build
FROM alpine:${ALPINE_VERSION} AS builder

RUN apk add --no-cache go nodejs npm git make bash curl

WORKDIR /build
RUN git clone https://github.com/prometheus/prometheus.git .
RUN make build

# Stage 2: Final Image
FROM alpine:${ALPINE_VERSION}
ARG UID
ARG GID

# Create a non-root user and group
RUN addgroup -g ${GID} -S prometheus && \
    adduser -u ${UID} -S prometheus -G prometheus

# Conventional locations:
# Binary -> /usr/local/bin/prometheus
# Config -> /etc/prometheus/prometheus.yml
# Storage -> /prometheus
WORKDIR /prometheus

# Copy the binary from the builder stage
COPY --from=builder /build/prometheus /usr/local/bin/prometheus
COPY --from=builder /build/console_libraries /usr/share/prometheus/console_libraries
COPY --from=builder /build/consoles /usr/share/prometheus/consoles

# Setup directories and permissions
RUN mkdir -p /etc/prometheus /prometheus /usr/share/prometheus && \
    chown -R prometheus:prometheus /etc/prometheus /prometheus /usr/share/prometheus

# Copy the default configuration file
COPY prometheus.yml /etc/prometheus/prometheus.yml
RUN chown prometheus:prometheus /etc/prometheus/prometheus.yml

# Declare volumes for storage and configuration
VOLUME ["/prometheus"]

USER prometheus

EXPOSE 9090

# Set the entrypoint and default flags
ENTRYPOINT ["/usr/local/bin/prometheus"]
CMD ["--config.file=/etc/prometheus/prometheus.yml", \
     "--storage.tsdb.path=/prometheus", \
     "--web.console.libraries=/usr/share/prometheus/console_libraries", \
     "--web.console.templates=/usr/share/prometheus/consoles"]
