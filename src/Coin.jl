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

include(joinpath("Util", "Base58.jl"))
include(joinpath("Wallet", "Keys.jl"))
include(joinpath("Wallet", "WIF.jl"))

Crypto.init()

end # module Coin
