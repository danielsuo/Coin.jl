##############################################################################
##
## References
##
##############################################################################

# - https://en.bitcoin.it/wiki/Technical_background_of_version_1_Bitcoin_addresses
# - https://en.bitcoin.it/wiki/List_of_address_prefixes

##############################################################################
##
## Definitions
##
##############################################################################

type Keys
  priv_key::Array{Uint8}
  pub_key::Array{Uint8}
end

function generate_keys(network_id = 0x00)
  priv_key = Crypto.random(256)
  pub_key = get_pub_key(priv_key, network_id = network_id, version = version)

  return (Crypto.oct2hex(priv_key), pub_key)
end

function get_pub_key(priv_key::String; network_id = 0x00)
  get_pub_key(Crypto.hex2oct(priv_key),
              network_id = network_id)
end

function get_pub_key(priv_key::Array{Uint8}; network_id = 0x00)

  # Generate corresponding public key generated with against ECDSA secp256k1
  # (65 bytes, 1 byte 0x04, 32 bytes corresponding to X coordinate, 32 bytes 
  # corresponding to Y coordinate)
  pub_key = Crypto.ec_pub_key(priv_key)

  # Perform SHA-256 hashing on the public key
  pub_key = Crypto.digest("SHA256", pub_key)

  # Perform RIPEMD-160 hashing on the result of SHA-256
  pub_key = Crypto.digest("RIPEMD160", pub_key)

  # Add version byte in front of RIPEMD-160 hash (0x00 for Main Network)
  # Reference: https://bitcoin.org/en/developer-reference#address-conversion
  pub_key = [Crypto.int2oct(network_id), pub_key]

  # Get checksum by performing SHA256 hash twice and taking first 4 bytes
  checksum = get_checksum(pub_key)

  # Add the 4 checksum bytes from stage 7 at the end of extended RIPEMD-160 
  # hash from stage 4. This is the 25-byte binary Bitcoin Address.
  append!(pub_key, checksum)

  # Convert the result from a byte string into a base58 string using 
  # Base58Check encoding. This is the most commonly used Bitcoin Address format
  # Reference: https://en.bitcoin.it/wiki/Base58Check_encoding
  # TODO: array to string to BigInt is really round-about
  pub_key = encode58(pub_key)

  return pub_key
end
