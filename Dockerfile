FROM alpine:latest

# Install necessary packages
RUN apk add --no-cache \
    build-base \
    gcc \
    libc-dev \
    htop

# Set working directory
WORKDIR /app

# Copy the C source file into the container
COPY program.c /app/

# Compile the C program
RUN gcc -o program program.c

# Set the default command to run the compiled executable
CMD ["/app/program"]