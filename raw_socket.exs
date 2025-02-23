defmodule CustomProtocolSender do
  import Bitwise

  @dest_ip {192, 168, 50, 156}    # Target IP

  @src_port 12345
  @dest_port 54321
  @protocol 17  # UDP protocol number
  @custom_protocol_id 99  # Arbitrary protocol ID for our own UDP-based protocol

  @sock_addr %{family: :inet, port: @dest_port, addr: @dest_ip}

  def loop(sock, packet, count \\ 0) do
    IO.puts("Looping... #{count} times")

    :socket.sendto(sock, packet, @sock_addr)

    Process.sleep(2_000)
    loop(sock, packet, count + 1) # Recursive call to continue the loop
  end

  def send_packet do
    {:ok, sock} = :socket.open(:inet, :raw, @protocol)

    payload = "Custom Proto Data!"
    custom_header = build_custom_header(payload)
    packet = custom_header <> payload

    loop(sock, packet)

    :socket.close(sock)
  end

  defp build_custom_header(payload) do
    source_port = <<@src_port::size(16)>>
    dest_port = <<@dest_port::size(16)>>

    header_checksum = <<0x00, 0x00>>  # Placeholder

    # Custom protocol header (4 bytes)
    # [Protocol ID (1 byte)] [Flags (1 byte)] [Length (2 bytes)]
    protocol_id = <<@custom_protocol_id>>
    flags = <<0x01>>  # Example flag (e.g., request type)
    length = <<byte_size(payload) + 4::16>>  # 4-byte header + payload length

    udp_header = source_port <> dest_port <> length <> header_checksum <> protocol_id <> flags <> length

    computed_checksum = checksum(udp_header)

    binary_part(udp_header, 0, 6) <> computed_checksum <> binary_part(udp_header, 8, 4)
  end

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
