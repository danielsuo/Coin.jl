module WIF

##############################################################################
##
## Dependencies
##
##############################################################################

using Coin

##############################################################################
##
## Exported methods and types
##
##############################################################################

export private2wif, wif2private, wif_checksum

##############################################################################
##
## Wallet interchange format function definitions
##
##############################################################################

# NOTE: As described in the document https://en.bitcoin.it/wiki/WIF

# Convert private key to WIF.
# TODO: turn keys into objects to hold metadata
# - which_net: which network to use; 0x80 for mainnet, 0xef for testnet
# - compression: 01 if private key corresponds to compressed public key
function private2wif(pk::ASCIIString; which_net="80", compression="")
  pk = string(which_net, pk, compression)

  hashed = Coin.Crypto.SHA2.sha256(pk)
  hashed = Coin.Crypto.SHA2.sha256(hashed)

  checksum = hashed[1:8]

  pk = string(pk, checksum)

  return Coin.Util.Base.encode(parseint(BigInt, pk, 16), 58)
end

function wif2private(wif::ASCIIString; is_compressed=false)
  pk = hex(Coin.Util.Base.decode(wif, 58))

  # Drop the first two characters (network identifier) and last
  # 8 (checksum)
  pk = pk[3:end-8]

  if is_compressed
    pk = pk[1:end-2]
  end

  return pk
end

function wif_checksum(wif::ASCIIString)
  result = hex(Coin.Util.Base.decode(wif, 58))

  checksum = result[end - 8 + 1:end]

  result = Coin.Crypto.SHA2.sha256(result[1:end - 8])
  result = Coin.Crypto.SHA2.sha256(result)

  return result[1:8] == checksum
end

end # module WIF
