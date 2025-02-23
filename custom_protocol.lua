-- Custom Protocol Lua Dissector for Wireshark
-- Author: Hagen10

-- Define the protocol
custom_proto = Proto("CustomProto", "Custom UDP-based Protocol")

-- Define the protocol fields
local f_protocol_id = ProtoField.uint8("customproto.protocol_id", "Protocol ID", base.DEC)
local f_flags = ProtoField.uint8("customproto.flags", "Flags", base.HEX)
local f_length = ProtoField.uint16("customproto.length", "Payload Length", base.DEC)
local f_payload = ProtoField.string("customproto.payload", "Payload")

custom_proto.fields = { f_protocol_id, f_flags, f_length, f_payload }

local function heuristic_checker(buffer, pinfo, tree)
    if buffer:len() < 4 then
        return -- Not enough data for the header
    end

    local protocol_id = buffer(0, 1):uint()

    -- Only process packets with protocol ID 99
    if protocol_id ~= 99 then
        return false
    end

    custom_proto.dissector(buffer, pinfo, tree)
    return true
end

-- Dissector function
function custom_proto.dissector(buffer, pinfo, tree)
    length = buffer:len()
    if length == 0 then return end

    pinfo.cols.protocol = "CustomProtos"

    -- Create protocol tree
    local subtree = tree:add(custom_proto, buffer(), "Custom Protocol Data")
    subtree:add(f_protocol_id, buffer(0, 1))
    subtree:add(f_flags, buffer(1, 1))
    subtree:add(f_length, buffer(2, 2))

    -- Extract and display payload if available
    local payload_length = buffer:len() - 4

    if payload_length > 0 then
        subtree:add(f_payload, buffer(4, payload_length))
    end
end

custom_proto:register_heuristic("udp", heuristic_checker)
