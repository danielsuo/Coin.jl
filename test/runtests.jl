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

##############################################################################
##
## Transaction tests
##
##############################################################################

# Test header generation
payload = "0100000001484d40d45b9ea0d652fca8258ab7caa42541eb52975857f96fb50cd732c8b481000000008a47304402202cb265bf10707bf49346c3515dd3d16fc454618c58ec0a0ff448a676c54ff71302206c6624d762a1fcef4618284ead8f08678ac05b13c84235f1654e6ad168233e8201410414e301b2328f17442c0b8310d787bf3d8a404cfbd0704f135b6ad4b2d3ee751310f981926e53a6e8c39bd7d3fefd576c543cce493cbac06388f2651d1aacbfcdffffffff0162640100000000001976a914c8e90996c7c6080ee06284600c684ed904d14c5c88ac00000000"
@test Coin.create_header(magic_mainnet, "tx", payload) == "f9beb4d9747800000000000000000000df000000ea0f5494"

##############################################################################
##
## Utility tests
##
##############################################################################

# Reverse endian of hex string
@test Coin.reverse_endian("0c28fca386c7a227600b2fe50b7cae11ec86d3bf1fbe471be89827e19d72aa1d") == "1daa729de12798e81b47be1fbfd386ec11ae7c0be52f0b6027a2c786a3fc280c"