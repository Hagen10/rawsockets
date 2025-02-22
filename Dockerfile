# Use the official Elixir image
FROM elixir:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    iproute2 \
    net-tools \
    tcpdump \
    nmap \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the Elixir script
COPY raw_socket.exs raw_socket.exs

# Set the network interface name (default: eth0)
ENV NETWORK_INTERFACE=eth0

# Run the script
CMD elixir raw_socket.exs
