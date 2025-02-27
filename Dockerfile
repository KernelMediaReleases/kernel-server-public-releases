# Build stage
FROM golang:1.23.4 AS builder

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=1 go build -trimpath -o kernel-server .

# Final stage
FROM ubuntu:24.04

# Install required dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ca-certificates \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the binary from builder
COPY --from=builder /app/kernel-server /app/
COPY settings.template.yml /app/settings.yml

# Create necessary directories
RUN mkdir -p /app/data /app/log

# Set environment variables
ENV KERNEL_PORT=9014
ENV KERNEL_HOST=0.0.0.0

# Expose the port
EXPOSE ${KERNEL_PORT}

# Set volumes for persistent data
VOLUME ["/app/data", "/app/log"]

# Run the kernel server
CMD ["./kernel-server"] 