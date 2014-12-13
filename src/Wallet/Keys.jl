##############################################################################
##
## References
##
##############################################################################

# - https://en.bitcoin.it/wiki/Technical_background_of_version_1_Bitcoin_addresses

##############################################################################
##
## Definitions
##
##############################################################################

# TODO: Compressed keys?
function generate_keys(network_id = "00", version = "1")
  secret_key = join([hex(x) for x in Crypto.random(256)])
  public_key = get_public_key(secret_key, network_id = network_id, version = version)

  return (secret_key, public_key)
end

function get_public_key(secret_key; network_id = "00", version = "1")

  # Generate corresponding public key generated with against ECDSA secp256k1
  # (65 bytes, 1 byte 0x04, 32 bytes corresponding to X coordinate, 32 bytes 
  # corresponding to Y coordinate)
  public_key = Crypto.ec_public_key_create(secret_key)

  # Perform SHA-256 hashing on the public key
  public_key = Crypto.digest("SHA256", public_key, is_hex=true)

  # Perform RIPEMD-160 hashing on the result of SHA-256
  public_key = Crypto.digest("RIPEMD160", public_key, is_hex=true)

  # Add version byte in front of RIPEMD-160 hash (0x00 for Main Network)
  # Reference: https://bitcoin.org/en/developer-reference#address-conversion
  public_key = string(network_id, public_key)

  # Get checksum by performing SHA256 hash twice and taking first 4 bytes
  checksum = Crypto.digest("SHA256", public_key, is_hex=true)
  checksum = Crypto.digest("SHA256", checksum, is_hex=true)
  checksum = checksum[1:8]

  # Add the 4 checksum bytes from stage 7 at the end of extended RIPEMD-160 
  # hash from stage 4. This is the 25-byte binary Bitcoin Address.
  public_key = string(public_key, checksum)

  # Convert the result from a byte string into a base58 string using 
  # Base58Check encoding. This is the most commonly used Bitcoin Address format
  # Reference: https://en.bitcoin.it/wiki/Base58Check_encoding
  public_key = parseint(BigInt, public_key, 16)
  public_key = encode58(public_key)

  # Append address version byte in hex
  # Reference: https://en.bitcoin.it/wiki/List_of_address_prefixes
  public_key = string(version, public_key)

  return public_key
end
