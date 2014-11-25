using Coin
using Base.Test

##############################################################################
##
## Crypto tests
##
##############################################################################

# SHA2 tests
@test Coin.Crypto.SHA2.sha256("a") == "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb"
@test Coin.Crypto.SHA2.sha256("Scientific progress goes 'boink'") == "2f2ba2a09a66771bf1fdf541af6e9db4b443145f9935ddd5d4c323c21a8bdcee"