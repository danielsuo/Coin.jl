##############################################################################
##
## References
##
##############################################################################

# - https://en.bitcoin.it/wiki/WIF

##############################################################################
##
## Wallet interchange format function definitions
##
##############################################################################

# Convert private key to WIF.
# TODO: turn keys into objects to hold metadata
# TODO: Update to use byte arrays
# - network_id: which network to use; 0x80 for mainnet, 0xef for testnet
# - compression: 01 if private key corresponds to compressed public key
function private2wif(private_key; network_id = "80", compression = "")
  private_key = string(network_id, private_key, compression)

  hashed = Crypto.digest("SHA256", private_key, is_hex=true)
  hashed = Crypto.digest("SHA256", hashed)

  checksum = Crypto.oct2hex(hashed[1:4])

  private_key = string(private_key, checksum)

  return encode58(parseint(BigInt, private_key, 16))
end

function wif2private(wif; is_compressed=false)
  private_key = hex(decode58(wif))

  # Drop the first two characters (network identifier) and last
  # 8 (checksum)
  private_key = private_key[3:end-8]

  if is_compressed
    private_key = private_key[1:end-2]
  end

  return private_key
end

function wif_check_sum(wif)
  result = hex(decode58(wif))
  return get_checksum(result[1:end-8], is_hex=true) == result[end-8+1:end]
end

function pub2base58(pub_key::String; network_id = "00")
  pub_key_length = div(length(pub_key), 2)

  # If public key is elliptic curve coordinate, hash with SHA-256
  if pub_key_length == 65
    pub_key = Crypto.digest("SHA256", pub_key, is_hex = true)
    pub_key = Crypto.oct2hex(pub_key)
    pub_key_length = div(length(pub_key), 2)
  end

  # If public key has been SHA-256 hashed, hash with RIPEMD-160
  if pub_key_length == 32
    pub_key = Crypto.digest("RIPEMD160", pub_key, is_hex = true)
    pub_key = Crypto.oct2hex(pub_key)
    pub_key_length = div(length(pub_key), 2)
  end

  # If public key has been RIPEMD-160 hashed, add network id
  if pub_key_length == 20
    pub_key = string(network_id, pub_key)
    pub_key_length = div(length(pub_key), 2)
  end

  # If public key has network id added, add checksum
  if pub_key_length == 21
    checksum = get_checksum(pub_key, is_hex = true)
    pub_key = string(pub_key, checksum)
    pub_key_length = div(length(pub_key), 2)
  end

  # If public key has checksum added
  if pub_key_length == 25
    pub_key = encode58(Crypto.hex2oct(pub_key))
  end

  return pub_key
end
