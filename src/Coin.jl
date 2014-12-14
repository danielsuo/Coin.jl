module Coin

export 
       # Keys.jl
       generate_keys, 
       get_public_key, 

       # WIF.jl
       private2wif, 
       wif2private, 
       wif_check_sum,

       # Base58.jl
       encode58,
       decode58

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

include("base58.jl")
include("keys.jl")
include("wif.jl")
include("transactions.jl")
include("signatures.jl")

Crypto.init()

end # module Coin
