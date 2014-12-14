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

       # utils.jl
       reverse_endian

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
