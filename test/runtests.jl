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
# @test Coin.create_header(magic_mainnet, "tx", payload) == "f9beb4d9747800000000000000000000df000000ea0f5494"

# Transaction output
tx_out = Coin.Tx_Output(123, "abc")
@test bytearray(tx_out) == Uint8[123,0,0,0,0,0,0,0,2,10,188]
tx_out = Coin.Tx_Output(5000000, "76A9141AA0CD1CBEA6E7458A7ABAD512A9D9EA1AFB225E88AC")
@test bytearray(tx_out) == Uint8[64,75,76,0,0,0,0,0,25,118,169,20,26,160,205,28,190,166,231,69,138,122,186,213,18,169,217,234,26,251,34,94,136,172]

##############################################################################
##
## Utility tests
##
##############################################################################

# Reverse endian of hex string
@test Coin.reverse_endian("") == ""
@test Coin.reverse_endian("0c28fca386c7a227600b2fe50b7cae11ec86d3bf1fbe471be89827e19d72aa1d") == "1daa729de12798e81b47be1fbfd386ec11ae7c0be52f0b6027a2c786a3fc280c"
@test Coin.reverse_endian(0) == 0
@test Coin.reverse_endian(0x22) == 0x22
@test Coin.reverse_endian(0x333) == 0x3303
@test Coin.reverse_endian(0x2234) == 0x3422
@test Coin.reverse_endian(0xf9beb4d9) == 0xd9b4bef9
@test Coin.reverse_endian(BigInt(19238471923847192837419283749128374912837491823742198374)) == 9830438508025927557749821611753759704769006686345681864
# reverse_endian assumes that BigInt is at least 16 bytes and Int is system-dependent
@test Coin.reverse_endian(BigInt(24)) == 31901471898837980949691369446728269824
@test Coin.reverse_endian(23) == 1657324662872342528
@test Coin.reverse_endian(-23) == -1585267068834414593

# hex_string_to_array: empty string
@test Coin.hex_string_to_array("") == []
# hex_string_to_array: odd- and even-length strings
@test Coin.hex_string_to_array("adfcef981") == [0x0a, 0xdf, 0xce, 0xf9, 0x81]
@test Coin.hex_string_to_array("aadfcef981") == [0xaa, 0xdf, 0xce, 0xf9, 0x81]

# Test VarInt conversion
@test Coin.to_varint(1) == [0x01]
@test Coin.to_varint(252) == [0xfc]
@test Coin.to_varint(253) == [0xfd, 0x00, 0xfd]
@test Coin.to_varint(0xffff) == [0xfd, 0xff, 0xff]
@test Coin.to_varint(0x10000) == [0xfe, 0x00, 0x01, 0x00, 0x00]
@test Coin.to_varint(0x100000000) == [0xff, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00]

