defmodule CustomProtocolSender do
  import Bitwise

  @source_ip {192, 168, 1, 100}  # Change this to your actual IP
  @dest_ip {192, 168, 50, 156}    # Target IP

  # @source_port 12345
  @dest_port 54321
  @protocol 17  # UDP protocol number
  @custom_protocol_id 99  # Arbitrary protocol ID for our own UDP-based protocol

  @sock_addr %{family: :inet, port: @dest_port, addr: @dest_ip}

  def send_packet do
    {:ok, sock} = :socket.open(:inet, :raw, @protocol)

    payload = "Custom Proto Data!"
    custom_header = build_custom_header(payload)
    ip_header = build_ip_header(custom_header <> payload)

    packet = ip_header <> custom_header <> payload

    :socket.sendto(sock, packet, @sock_addr)

    IO.puts("Custom protocol packet sent!")
    IO.puts("IP Header: #{inspect(Base.encode16(ip_header))}")
    IO.puts("custom_header: #{inspect(Base.encode16(custom_header))}")
    IO.puts("payload: #{inspect(Base.encode16(payload))}")

    :socket.close(sock)
  end

  defp build_ip_header(data) do
    version_ihl = <<0x45>>  # IPv4, Header Length = 5 (20 bytes)
    dscp_ecn = <<0x00>>
    total_length = <<0x00, byte_size(data) + 20>>  # 20 (IP) + payload
    identification = <<0x00, 0x01>>
    flags_fragment = <<0x00, 0x00>>
    ttl = <<0x40>>  # 64
    protocol = <<@protocol>>  # UDP
    header_checksum = <<0x00, 0x00>>  # Placeholder

    src_ip = ip_to_binary(@source_ip)
    dest_ip = ip_to_binary(@dest_ip)

    ip_header =
      version_ihl <> dscp_ecn <> total_length <> identification <> flags_fragment <>
      ttl <> protocol <> header_checksum <> src_ip <> dest_ip

    computed_checksum = checksum(ip_header)
    binary_part(ip_header, 0, 10) <> computed_checksum <> binary_part(ip_header, 12, 8)
  end

  defp build_custom_header(payload) do
    # Custom protocol header (4 bytes)
    # [Protocol ID (1 byte)] [Flags (1 byte)] [Length (2 bytes)]
    protocol_id = <<@custom_protocol_id>>
    flags = <<0x01>>  # Example flag (e.g., request type)
    length = <<byte_size(payload) + 4::16>>  # 4-byte header + payload length

    protocol_id <> flags <> length
  end

  defp ip_to_binary({a, b, c, d}), do: <<a, b, c, d>>

  defp checksum(data) do
    sum =
      data
      |> :binary.bin_to_list()
      |> Enum.chunk_every(2, 2, [0])  # Convert bytes to 16-bit words
      |> Enum.map(fn [a, b] -> (a <<< 8) + b end)
      |> Enum.sum()

    sum = (sum &&& 0xFFFF) + (sum >>> 16)  # Add overflow
    sum = (sum &&& 0xFFFF) + (sum >>> 16)  # Add again if needed

    <<(~~~sum &&& 0xFFFF) >>> 8, (~~~sum &&& 0xFF)>>  # One's complement
  end
end

CustomProtocolSender.send_packet()
