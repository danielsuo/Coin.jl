module Base

##############################################################################
##
## Exported functions and modules
##
##############################################################################

export encode, decode

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
# uses a different alphabet. Still asking users to supply a base to have nice,
# but descriptive function names.
# - n: integer we want to convert
# - b: base we want to convert to
function encode(n, b)
  # Require base to be 58 for now
  @assert b == 58

  output = ""

  while n > 0
    n, rem = divrem(n, b)
    output = string(base58[rem + 1],output)
  end

  return output
end

# Decode from base 58 to integer
# - n: base 58 number we want to convert
function decode(n, b)
  # Require base to be 58 for now
  @assert b == 58

  result = BigInt(0)

  for i = 1:length(n)
    result = result * b + search(base58, n[i]) - 1
  end

  return result
end

end # module Base
