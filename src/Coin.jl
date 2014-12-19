module Coin

export 
       # keys.jl
       Keys,
       generate_keys, 
       get_pub_key, 

       # addresses.jl
       private2wif, 
       wif2private, 
       wif_check_sum,
       pub2base58,

       # base58.jl
       encode58,
       decode58,
       decode58_to_array,

       # utils.jl
       reverse_endian,
       get_checksum,
       to_varint,
       to_varstring,
       bytearray

export BITCOIN_PROTOCOL_VERSION,
       SERVICES_NODE_NETWORK

##############################################################################
##
## Message exports
##
##############################################################################

export
       # messages.jl,
       Message,
       create_header,
       
       # tx.jl
       Tx,
       Tx_Input,
       OutPoint,
       Tx_Output,
       create_tx,
       get_tx,

       # version.jl
       NetworkAddress,
       Version

export magic_mainnet,
       magic_testnet,
       magic_testnet3,
       magic_namecoin

##############################################################################
##
## Dependencies
##
##############################################################################

using Crypto

##############################################################################
##
## Load files
##
##############################################################################

include("utils.jl")
include("base58.jl")
include("keys.jl")
include("addresses.jl")
include("messages/messages.jl")
include("signatures.jl")
include("op.jl")
include("server.jl")

Crypto.init()

# Version 0.9.3
const BITCOIN_PROTOCOL_VERSION = 93000

const SERVICES_NODE_NETWORK = 1

end # module Coin
