##############################################################################
##
## References
##
##############################################################################

# - https://github.com/bitcoin/bitcoin/blob/master/src/base58.cpp

##############################################################################
##
## Constants
##
##############################################################################

# TODO: This would be nice as an associative array so we can just look up by
#       base.
const base58 = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

##############################################################################
##
## Function definitions
##
##############################################################################

# We really only need these for base 58 because Julia's default base 58 math
# uses a different alphabet.
function encode58(n::Array{Uint8})
  result = encode58(Crypto.oct2int(n))

  # TODO: this isn't correct in the case of general # of 0 bytes
  for byte in n
    if byte == 0x00
      result = string(base58[1], result) # Add the zero element
    end
  end

  return result
end

# - n: integer we want to convert
function encode58(n::Integer)
  # Require base to be 58 for now
  b = 58

  output = ""

  while n > 0
    n, rem = divrem(n, b)
    output = string(base58[rem + 1], output)
  end

  return output
end

# Decode from base 58 to integer
# - n: base 58 number we want to convert
function decode58(n::String)
  # Require base to be 58 for now
  b = 58

  result = BigInt(0)

  for i = 1:length(n)
    result = result * b + search(base58, n[i]) - 1
  end

  return result
end

function decode58_to_array(n::String)
  result = Crypto.hex2oct(hex(decode58(n)))

  # TODO: this isn't correct in the case of general # of 0s
  # Capture 2 leading 0s
  if n[1:2] == repeat(base58[1], 2) # Get the zero element
    result = [0x00, result]
  end

  return result
end
