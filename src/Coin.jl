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

       # messages.jl,
       create_header,
       Message,
       Tx,
       Tx_Input,
       OutPoint,
       Tx_Output,

       # tx.jl
       create_tx,
       get_tx,

       # utils.jl
       reverse_endian,
       get_checksum,
       to_varint,
       bytearray

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
include("messages.jl")
include("signatures.jl")
include("op.jl")
include("tx.jl")

Crypto.init()

end # module Coin
