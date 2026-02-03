FROM golang:1.24-alpine AS builder

WORKDIR /app

# Copy go mod files first for caching
COPY src/go.mod src/go.sum ./
RUN go mod download

# Copy source and build the binary
COPY src/ .
RUN go build -o whatsapp

FROM alpine:latest

# Install FFmpeg (required for media handling)
RUN apk add --no-cache ffmpeg

WORKDIR /app

COPY --from=builder /app/whatsapp .

# Expose the MCP port (default 8080)
EXPOSE 8080

# Run in MCP mode; override port/env via Railway variables if needed
CMD ["./whatsapp", "mcp"]
