# Use Ubuntu as base image
FROM ubuntu:24.04

# Install required dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ca-certificates \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the pre-compiled binary and settings template
COPY kernel-*-linux-amd64 /app/kernel-server
COPY settings.template.yml /app/settings.yml

# Make the binary executable
RUN chmod +x /app/kernel-server

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