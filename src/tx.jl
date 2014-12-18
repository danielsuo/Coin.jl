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
                   addresses::Array{String},
                   amounts::Array{Integer};
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
    append!(inputs, input)
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
    append!(outputs, output)
  end

  # Build transaction object
  tx = Tx(inputs, outputs)

  # Get transaction as byte array
  raw_tx = bytearray(tx)

  # Append hash code; see here: https://en.bitcoin.it/wiki/OP_CHECKSIG
  append!(raw_tx, reverse(bytearray(hash_code)))

  # Double hash the transaction
  hash = Crypto.digest("SHA256", Crypto.digest("SHA256", raw_tx))

  # Sign the transaction using the private key
  for i in 1:length(priv)

    # Sign transation using private key
    signature = Crypto.ec_sign(hash, keys[i].priv_key)

    # Build scriptSig
    scriptSig = Array(Uint8, 0)

    # Append length of signature as little-endian varint hex
    append!(scriptSig, reverse(to_varint(length(signature))))

    # Append the signature as big-endian
    append!(scriptSig, signature)

    # Append hash_code byte
    append!(scriptSig, uint8(hash_code))

    # Append length of public key as little-endian varint hex
    append!(scriptSig, reverse(to_varint(length(keys[i].pub_key))))

    # Append public key
    append!(scriptSig, keys[i].pub_key)

    tx.inputs[i].scriptSig = scriptSig
  end

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
    outpoint = OutPoint(input["previous_transaction_hash"], input["output_index"])
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

# Crypto.init()

# priv_key = Crypto.random(256)
# pub_key = Crypto.ec_pub_key(priv_key)
# keys = [Keys(priv_key, pub_key)]

# outpoint = OutPoint("f2b3eb2deb76566e7324307cd47c35eeb88413f971d88519859b1834307ecfec", 1)
# address = "1runeksijzfVxyrpiyCY2LCBvYsSiFsCm"
# println(address)
# http://bitcoin.stackexchange.com/questions/2859/how-are-transaction-hashes-calculated
# outpoint = OutPoint("f2b3eb2deb76566e7324307cd47c35eeb88413f971d88519859b1834307ecfec", 1)
# input = Tx_Input(outpoint, "76a914010966776006953d5567439e5e39f86a0d273bee88ac")
# output = Tx_Output(99900000, "76a914097072524438d003d23a2f23edb65aae1bb3e46988ac")

# tx = Tx([input], [output])



# hash_code = SIGHASH_ALL

# raw_tx = bytearray(tx)
# append!(raw_tx, reverse(bytearray(hash_code)))
# hash = Crypto.digest("SHA256", Crypto.digest("SHA256", raw_tx))

# data = "0100000001eccf7e3034189b851985d871f91384b8ee357cd47c3024736e5676eb2debb3f2010000001976a914010966776006953d5567439e5e39f86a0d273bee88acffffffff01605af405000000001976a914097072524438d003d23a2f23edb65aae1bb3e46988ac0000000001000000"



# sig = Crypto.ec_sign(hash, priv_key)
# hash_code = uint8(SIGHASH_ALL)

# scriptSig = Array(Uint8, 0)

# append!(scriptSig, reverse(to_varint(length(sig))))
# append!(scriptSig, sig)
# append!(scriptSig, hash_code)

# append!(scriptSig, reverse(to_varint(length(pub_key))))
# append!(scriptSig, pub_key)

# tx.inputs[1].scriptSig = scriptSig

# send = "1KKKK6N21XKo48zWKuQKXdvSsCf95ibHFa"
# # First byte is network id, last four bytes are checksum
# addr = decode58_to_array(send)[2:end-4]

# scriptPubKey = [OP_DUP, OP_HASH160, uint8(length(addr)), addr, OP_EQUALVERIFY, OP_CHECKSIG]

# tx.outputs[1].scriptPubKey = scriptPubKey

# raw_tx = bytearray(tx)

# # TODO: Read raw_tx to Tx
# # TODO: 