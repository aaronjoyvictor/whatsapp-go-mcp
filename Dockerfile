# Stage 1: Build with CGO enabled
FROM golang:1.24-bookworm-slim AS builder

# Install C compiler + SQLite dev libs
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy go mod/sum first for caching
COPY src/go.mod src/go.sum ./
RUN go mod download

# Copy source code
COPY src/ .

# Build with CGO enabled (critical!)
ENV CGO_ENABLED=1
RUN go build -o whatsapp

# Stage 2: Small runtime image
FROM alpine:3.21

# Install runtime deps: FFmpeg + SQLite shared lib
RUN apk add --no-cache \
    ffmpeg \
    sqlite-libs

WORKDIR /app

# Copy only the binary from builder
COPY --from=builder /app/whatsapp .

# Expose MCP port
EXPOSE 8080

# Run in MCP mode (Railway can override PORT via $PORT if needed)
CMD ["./whatsapp", "mcp"]