import Base.convert
import Base.print

##############################################################################
##
## References
##
##############################################################################

# - https://en.bitcoin.it/wiki/Protocol_specification

##############################################################################
##
## Notes
##
##############################################################################

# MESSAGE STRUCTURE - A typical message has the following structure:
# 
# Field size | Description | Data type | Comments
# ----------------------------------------------------------------------------
#          4 | magic       | uint32_t  | Value indicating origin network
#         12 | command     | char[12]  | ASCII string identifying packet content
#          4 | length      | uint32_t  | Length of payload in number of bytes
#          4 | checksum    | uint32_t  | First 4 bytes of sha256(sha256(payload))
#          ? | payload     | uchar[?]  | The actual data
#
# Almost all integers are encoded in little endian. Only IP or port number are 
# encoded big endian.

# MESSAGE TYPES - The following are the current message types
#
# version:    When a node creates an outgoing connection, it will immediately 
#             advertise its version. The remote node will respond with its version. 
#             No further communication is possible until both peers have exchanged 
#             their version.
# verack:     The verack message is sent in reply to version. This message consists 
#             of only a message header with the command string "verack".
# addr:       Provide information on known nodes of the network. Non-advertised 
#             nodes should be forgotten after typically 3 hours.
# inv:        Allows a node to advertise its knowledge of one or more objects. 
#             It can be received unsolicited, or in reply to getblocks.
# getdata:    getdata is used in response to inv, to retrieve the content of a 
#             specific object, and is usually sent after receiving an inv packet, 
#             after filtering known elements. It can be used to retrieve 
#             transactions, but only if they are in the memory pool or relay set - 
#             arbitrary access to transactions in the chain is not allowed to 
#             avoid having clients start to depend on nodes having full 
#             transaction indexes (which modern nodes do not).
# notfound:   notfound is a response to a getdata, sent if any requested data 
#             items could not be relayed, for example, because the requested 
#             transaction was not in the memory pool or relay set.
# getblocks
# getheaders
# tx
# block
# headers
# getaddr
# mempool
# checkorder
# submitorder
# reply
# ping
# pong
# reject
# filterload
# filteradd
# filterclear
# merkleblock
# alert

type Message
  magic::Uint32               # Network identifier
  command::Array{Uint8}       # Message command, right padded with \0 to 12 bytes
  payload::Array{Uint8}       # Payload data

  function Message(magic::Uint32, command::String, payload::String)
    # Right pad the command string with \0 to create 12-byte array
    append!(command.data, zeros(Char, 12 - length(command.data)))

    # Calculate checksum
    checksum = uint32(parseint(get_checksum(payload, is_hex=true)[1:8], 16))

    # Turn payload hex string into array of bytes
    payload = hex_string_to_array(payload)

    new(magic, command.data, payload)
  end
end

type OutPoint
  hash::Array{Uint8}          # 32-byte hash of the referenced transaction
  index::Uint32               # Index of specific output in tx. 1st output is 0 

  function OutPoint(hash::String, index::Integer)
    OutPoint(hex_string_to_array(hash), uint32(index))
  end

  function OutPoint(hash::Array{Uint8}, index::Integer)
    if index < 0
      error("OutPoint cannot have negative index")
    end

    if length(hash) != 32
      error("OutPoint requres 32-byte hash of referenced transaction")
    end

    new(hash, uint32(index))
  end
end

function convert(::Type{Array{Uint8}}, outpoint::OutPoint)
  result = Array(Uint8, 0)

  append!(result, reverse(outpoint.hash))
  append!(result, reverse(bytearray(outpoint.index)))

  return result
end

type Tx_Input
  previous_output::OutPoint             # Previous output tx, as OutPoint
  scriptSig::Array{Uint8}               # Script to confirm tx authorization
  sequence::Uint32                      # Tx version as defined by the sender

  function Tx_Input(previous_output::OutPoint, scriptSig::String; sequence = 0xffffffff)
    scriptSig = hex_string_to_array(scriptSig)
    Tx_Input(previous_output, scriptSig, sequence = sequence)
  end

  function Tx_Input(previous_output::OutPoint, scriptSig::Array{Uint8}; sequence = 0xffffffff)
    new(previous_output, scriptSig, uint32(sequence))
  end
end

function convert(::Type{Array{Uint8}}, tx_in::Tx_Input)
  result = Array(Uint8, 0)

  append!(result, bytearray(tx_in.previous_output))
  append!(result, reverse(to_varint(length(tx_in.scriptSig))))
  append!(result, tx_in.scriptSig)
  append!(result, reverse(bytearray(tx_in.sequence)))
end

type Tx_Output
  # ERROR: does Uint64 exist on 32-bit OS?
  value::Uint64                         # Transaction value
  scriptPubKey::Array{Uint8}            # Script for claiming tx output

  # value: transaction value in Satoshi
  # scriptPubKey: script as hex string
  function Tx_Output(value, scriptPubKey::String)
    scriptPubKey = hex_string_to_array(scriptPubKey)
    Tx_Output(value, scriptPubKey)
  end

  # value: transaction value in Satoshi
  # scriptPubKey: script as Array of Uint8
  function Tx_Output(value, scriptPubKey::Array{Uint8})
    value = uint64(value)
    new(value, scriptPubKey)
  end
end

function convert(::Type{Array{Uint8}}, tx_out::Tx_Output)
  result = Array(Uint8, 0)

  # TODO: This is a really terrible way to get little
  # endian byte array
  append!(result, reverse(bytearray(tx_out.value)))

  append!(result, reverse(to_varint(length(tx_out.scriptPubKey))))

  append!(result, tx_out.scriptPubKey)

  return result
end

type Tx
  version::Uint32             # Transaction data format version
  inputs::Array{Tx_Input}     # Array of transaction inputs
  outputs::Array{Tx_Output}   # Array of transaction outputs
  lock_time::Uint32           # Block num / time when tx is locked

  function Tx(inputs::Array{Tx_Input}, outputs::Array{Tx_Output}; version = 0x00000001, lock_time = 0x00000000)
    new(version, inputs, outputs, lock_time)
  end
end

function convert(::Type{Array{Uint8}}, tx::Tx)
  result = Array(Uint8, 0)

  # Add version
  append!(result, reverse(bytearray(tx.version)))

  # Add number of inputs
  append!(result, reverse(to_varint(length(tx.inputs))))

  # Add inputs
  for input in tx.inputs
    append!(result, bytearray(input))
  end

  # Add number of outputs
  append!(result, reverse(to_varint(length(tx.outputs))))

  # Add outputs
  for output in tx.outputs
    append!(result, bytearray(output))
  end

  # Add lock_time
  append!(result, reverse(bytearray(tx.lock_time)))

  return result
end

# Define the known magic values
const magic_mainnet  = 0xd9b4bef9
const magic_testnet  = 0xdab5bffa
const magic_testnet3 = 0x0709110b
const magic_namecoin = 0xfeb4bef9

# const commands = ["version", "verack", "addr", "inv", "getdata", "notfound", 
#                   "getblocks", "getheaders", "tx", "block", "headers", 
#                   "getaddr", "mempool", "checkorder", "submitorder", "reply", 
#                   "ping", "pong", "reject", "filterload", "filteradd", 
#                   "filterclear", "merkleblock", "alert"]

# function generate_command_bytes(command_string)
#   rpad(join([hex(x, 2) for x in command_string.data]), 24, "0")
# end

# function create_header(magic, command, payload)
#   payload_length = div(length(payload), 2) # if data is hex string

#   magic       = reverse_endian(magic)
#   command     = generate_command_bytes(command)
#   payload_length = reverse_endian(lpad(hex(payload_length), 8, "0"))
#   checksum    = Crypto.digest("SHA256", Crypto.digest("SHA256", payload, is_hex=true), is_hex=true)[1:8]

#   return string(magic, command, payload_length, checksum)
# end

# function create_transaction_message(payload; magic = magic_mainnet, tx_version = "1")
#   header  = create_header(magic, "tx", payload)

#   version = reverse_endian(lpad(tx_version, 8, "0"))
# end