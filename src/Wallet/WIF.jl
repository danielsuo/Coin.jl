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
end

function wif2private(wif::ASCIIString)
end

function wif_checksum(wif::ASCIIString)
end

end # module WIF
