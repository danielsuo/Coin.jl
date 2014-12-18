##############################################################################
##
## TODO
##
##############################################################################

# - Read raw_tx to tx

##############################################################################
##
## Resources
##
##############################################################################

# - http://bitcoin.stackexchange.com/questions/2859/how-are-transaction-hashes-calculated

using Crypto
using HTTPClient
using JSON

const SIGHASH_ALL          = 0x00000001
const SIGHASH_NONE         = 0x00000002
const SIGHASH_SINGLE       = 0x00000003
const SIGHASH_ANYONECANPAY = 0x00000080

# Create transaction from previous OutPoints and outputs
function create_tx(keys::Array{Keys},
                   outpoints::Array{OutPoint},
                   addresses::Array,   # Should be array of Base58Check-encoded strings
                   amounts::Array;     # Should be array of Integers
                   hash_code = SIGHASH_ALL)

  if length(keys) != length(outpoints)
    error("Creating a transaction requires a private key for each input")
  end

  if length(addresses) != length(amounts)
    ereror("Creating a transation requires an amount for each address")
  end
  
  # Build input objects
  inputs = Array(Tx_Input, 0)
  for outpoint in outpoints
    prev_tx = get_tx(outpoint.hash)
    input = Tx_Input(outpoint, prev_tx.outputs[outpoint.index].scriptPubKey)
    append!(inputs, [input])
  end

  # Build output objects
  outputs = Array(Tx_Output, 0)
  for i in length(addresses)
    # First byte is network id, last four bytes are checksum
    address = decode58_to_array(addresses[i])[2:end-4]

    # Create scriptPubKey for pay2hash
    scriptPubKey = [OP_DUP, OP_HASH160, uint8(length(address)), address, OP_EQUALVERIFY, OP_CHECKSIG]

    # Create output object
    output = Tx_Output(amounts[i], scriptPubKey)
    append!(outputs, [output])
  end

  # Build transaction object
  tx = Tx(inputs, outputs)

  # Get transaction as byte array
  raw_tx = bytearray(tx)

  # Append hash code; see here: https://en.bitcoin.it/wiki/OP_CHECKSIG
  append!(raw_tx, reverse(Crypto.int2oct(hash_code)))

  # Double hash the transaction
  hash = Crypto.digest("SHA256", Crypto.digest("SHA256", raw_tx))

  # Sign the transaction using the private key
  for i in 1:length(keys)

    # Sign transation using private key
    signature = Crypto.ec_sign(hash, keys[i].priv_key)

    # Build scriptSig
    scriptSig = Array(Uint8, 0)

    # Append length of signature as little-endian varint hex
    append!(scriptSig, reverse(to_varint(length(signature))))

    # Append the signature as big-endian
    append!(scriptSig, signature)

    # Append hash_code byte
    append!(scriptSig, [uint8(hash_code)])

    # Append length of public key as little-endian varint hex
    append!(scriptSig, reverse(to_varint(length(keys[i].pub_key))))

    # Append public key
    append!(scriptSig, keys[i].pub_key)

    tx.inputs[i].scriptSig = scriptSig
  end

  return tx
end

function get_tx(hash::Array{Uint8})
  return get_tx(Crypto.oct2hex(hash))
end

function get_tx(hash::String)
  const TOSHI_API_TX_URL = "https://bitcoin.toshi.io/api/v0/transactions/"
  url = string(TOSHI_API_TX_URL, hash)

  # Get data
  # TODO: Add error handling to HTTP GET
  result = get(url)

  # Get body data
  result = result.body.data

  # Convert from hex array to ASCII string for JSON parsing
  result = join([char(x) for x in result])

  # Parse the JSON
  result = JSON.parse(result)

  # Parse json inputs into array of Tx_Input objects
  json_inputs = result["inputs"]
  inputs = Array(Tx_Input, 0)
  for input in json_inputs
    outpoint = OutPoint(input["previous_transaction_hash"], input["output_index"] + 1) # Julia is 1-index
    tx_input = Tx_Input(outpoint, input["script"])
    append!(inputs, [tx_input])
  end

  # Parse json outputs into array of Tx_Output objects
  json_outputs = result["outputs"]
  outputs = Array(Tx_Output, 0)
  for output in json_outputs
    tx_output = Tx_Output(output["amount"], output["script_hex"])
    append!(outputs, [tx_output])
  end

  return Tx(inputs, outputs)
end

function parse_tx(raw_tx::Array{Uint8})
  return 0
end

# https://en.bitcoin.it/wiki/OP_CHECKSIG
# https://github.com/aantonop/bitcoinbook/blob/develop/ch05.asciidoc
function verify_tx(tx::Tx)
  return 0
end