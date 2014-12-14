##############################################################################
##
## TODO
##
##############################################################################

# - Test different WIF types
# - Add negative WIF tests (e.g., invalid compression bits)
# - Test different key types (e.g., compressed)
# - Add negative key tests

using Coin
using Base.Test

##############################################################################
##
## Base58 tests
##
##############################################################################

base58data = parseint(BigInt, "800c28fca386c7a227600b2fe50b7cae11ec86d3bf1fbe471be89827e19d72aa1d507a5b8d", 16)

# Base 58 encoding
@test Coin.encode58(base58data) == "5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ"

# Base 58 decoding
@test Coin.decode58("5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ") == base58data

##############################################################################
##
## Key generation tests
##
##############################################################################

secret_key = "18E14A7B6A307F426A94F8114701E7C8E774E7F9A47E2C2035DB29A206321725"
public_key = Coin.get_public_key(secret_key)
@test public_key == "16UwLL9Risc3QfPqBUvKofHmBQ7wMtjvM"

##############################################################################
##
## Wallet Interchange Format tests
##
##############################################################################

# Private key to WIF
@test Coin.private2wif("0c28fca386c7a227600b2fe50b7cae11ec86d3bf1fbe471be89827e19d72aa1d") == "5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ"

# WIF to private key
@test Coin.wif2private("5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ") == "0c28fca386c7a227600b2fe50b7cae11ec86d3bf1fbe471be89827e19d72aa1d"

# WIF checksum
@test Coin.wif_check_sum("5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ")
