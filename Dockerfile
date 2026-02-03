# Single-stage Alpine build (simpler, smaller, consistent libc)
FROM golang:1.24-alpine AS builder

# Install build deps for CGO + SQLite + FFmpeg dev (if needed)
RUN apk add --no-cache \
    build-base \
    sqlite-dev \
    ffmpeg-dev

WORKDIR /app

# Cache deps
COPY src/go.mod src/go.sum ./
RUN go mod download

# Copy source
COPY src/ .

# Build with CGO (required for go-sqlite3)
ENV CGO_ENABLED=1
RUN go build -o whatsapp

# Final runtime (same Alpine base)
FROM alpine:3.21

# Runtime deps: FFmpeg + SQLite runtime lib
RUN apk add --no-cache \
    ffmpeg \
    sqlite-libs

WORKDIR /app

# Copy binary
COPY --from=builder /app/whatsapp .

# Expose port
EXPOSE 8080

# Run MCP mode
CMD ["./whatsapp", "mcp"]
