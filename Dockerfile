FROM alpine:latest AS builder

# Install Zig
RUN apk add --no-cache wget && \
    wget -O- https://ziglang.org/download/0.11.0/zig-linux-x86_64-0.11.0.tar.xz | tar -xJ --strip-components=1 -C /usr/local/bin

# Set working directory
WORKDIR /app

# Copy source code
COPY server.zig .

# Build with optimizations
RUN zig build-exe server.zig -O ReleaseSafe -fstrip -fsingle-threaded -target x86_64-linux

# Runtime stage
FROM scratch

# Copy binary
COPY --from=builder /app/server /server

# Document port
EXPOSE 8080

# Run server
ENTRYPOINT ["/server"]