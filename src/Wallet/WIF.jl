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

# NOTE: As described in the document https://en.bitcoin.it/wiki/WIF

# Convert private key to WIF.
# TODO: turn keys into objects to hold metadata
# - network_id: which network to use; 0x80 for mainnet, 0xef for testnet
# - compression: 01 if private key corresponds to compressed public key
function private2wif(private_key; network_id = "80", compression = "")
  private_key = string(network_id, private_key, compression)

  hashed = Crypto.digest("SHA256", private_key)
  hashed = Crypto.digest("SHA256", hashed)

  checksum = hashed[1:8]

  private_key = string(private_key, checksum)

  return encode58(parseint(BigInt, private_key, 16), 58)
end

function wif2private(wif; is_compressed=false)
  private_key = hex(decode58(wif, 58))

  # Drop the first two characters (network identifier) and last
  # 8 (checksum)
  private_key = private_key[3:end-8]

  if is_compressed
    private_key = private_key[1:end-2]
  end

  return private_key
end

function wif_check_sum(wif)
  result = hex(decode58(wif, 58))

  checksum = result[end - 8 + 1:end]

  result = Crypto.digest("SHA256", result[1:end - 8])
  result = Crypto.digest("SHA256", result)

  return result[1:8] == checksum
end
