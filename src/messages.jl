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

# Define the known magic values
const magic_mainnet = "D9B4BEF9"
const magic_testnet = "DAB5BFFA"
const magic_testnet3 = "0709110B"
const magic_namecoin = "FEB4BEF9"

const commands = ["version", "verack", "addr", "inv", "getdata", "notfound", 
                  "getblocks", "getheaders", "tx", "block", "headers", 
                  "getaddr", "mempool", "checkorder", "submitorder", "reply", 
                  "ping", "pong", "reject", "filterload", "filteradd", 
                  "filterclear", "merkleblock", "alert"]

for command = commands
  # e.g., command_tx = generate_command_bytes("tx")
  eval(parse(string("command_", command, "=", "generate_command_bytes(\"", command, "\")")))
end

function generate_command_bytes(command_string)
  rpad(join([hex(x, 2) for x in command_string.data]), 12, "0")
end

function create_header(magic, command, data)
  data = Crypto.digest("SHA256", Crypto.digest("SHA256", data))[1:8]

end

function create_transaction_message(magic, command, data)

end