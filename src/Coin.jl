module Coin

export 
       # keys.jl
       generate_keys, 
       get_public_key, 

       # wif.jl
       private2wif, 
       wif2private, 
       wif_check_sum,

       # base58.jl
       encode58,
       decode58,

       # messages.jl,
       create_header,
       Message,
       Tx,
       Tx_Input,
       OutPoint,
       Tx_Output,

       # utils.jl
       reverse_endian,
       get_checksum,
       hex_string_to_array,
       to_varint

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
include("wif.jl")
include("messages.jl")
include("signatures.jl")

Crypto.init()

end # module Coin
