module RIPEMD

##############################################################################
##
## Exported methods and types
##
##############################################################################

export ripemd160

##############################################################################
##
## Notes
##
##############################################################################

# Pseudocode: http://homes.esat.kuleuven.be/~bosselae/ripemd/rmd160.txt
# Additional notes: https://en.bitcoin.it/wiki/RIPEMD-160
#
# RIPEMD-160 is an iterative hash function that operates on 32-bit words.
# The round function takes as input a 5-word chaining variable and a 16-word
# message block and maps this to a new chaining variable. All operations are
# defined on 32-bit words. Padding is identical to that of MD4.

##############################################################################
##
## Definitions
##
##############################################################################

# Nonlinear functions at bit level: exor, mux, -, mux, -
const f = [(x, y, z) -> x $ y $ z,
           (x, y, z) -> (x & y) | (~x & z),
           (x, y, z) -> (x | ~y) $ z,
           (x, y, z) -> (x & z) | (y & ~z),
           (x, y, z) -> x $ (y | ~z)]

# Added constants (hexadecimal)
# NOTE: First 32 bits of the fractional parts of the square (K0)/cube (K1) 
# roots of the first 4 primes, 2 through 7. 
const K0 = [0x00000000, 0x5A827999, 0x6ED9EBA1, 0x8F1BBCDC, 0xA953FD4E]
const K1 = [0x50A28BE6, 0x5C4DD124, 0x6D703EF3, 0x7A6D76E9, 0x00000000]

# Selection of message word
const r0 = [[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
            [7, 4, 13, 1, 10, 6, 15, 3, 12, 0, 9, 5, 2, 14, 11, 8],
            [3, 10, 14, 4, 9, 15, 8, 1, 2, 7, 0, 6, 13, 11, 5, 12],
            [1, 9, 11, 10, 0, 8, 12, 4, 13, 3, 7, 15, 14, 5, 6, 2],
            [4, 0, 5, 9, 7, 12, 2, 10, 14, 1, 3, 8, 11, 6, 15, 13]]
const r1 = [[5, 14, 7, 0, 9, 2, 11, 4, 13, 6, 15, 8, 1, 10, 3, 12],
            [6, 11, 3, 7, 0, 13, 5, 10, 14, 15, 8, 12, 4, 9, 1, 2],
            [15, 5, 1, 3, 7, 14, 6, 9, 11, 8, 12, 2, 10, 0, 4, 13],
            [8, 6, 4, 1, 3, 11, 15, 0, 5, 12, 2, 13, 9, 7, 10, 14],
            [12, 15, 10, 4, 1, 5, 8, 7, 6, 2, 13, 14, 0, 3, 9, 11]]

# Amount for rotate left (rol)
const s0 = [[11, 14, 15, 12, 5, 8, 7, 9, 11, 13, 14, 15, 6, 7, 9, 8],
            [7, 6, 8, 13, 11, 9, 7, 15, 7, 12, 15, 9, 11, 7, 13, 12],
            [11, 13, 6, 7, 14, 9, 13, 15, 14, 8, 13, 6, 5, 12, 7, 5],
            [11, 12, 14, 15, 14, 15, 9, 8, 9, 14, 5, 6, 8, 6, 5, 12],
            [9, 15, 5, 11, 6, 8, 13, 12, 5, 12, 13, 14, 11, 8, 5, 6]]
const s1 = [[8, 9, 9, 11, 13, 15, 15, 5, 7, 7, 8, 11, 14, 14, 12, 6],
            [9, 13, 15, 7, 12, 8, 9, 11, 7, 7, 12, 7, 6, 15, 13, 11],
            [9, 7, 15, 11, 8, 6, 6, 14, 12, 13, 5, 14, 13, 13, 7, 5],
            [15, 5, 8, 11, 14, 14, 6, 14, 6, 9, 12, 9, 12, 5, 15, 8],
            [8, 5, 12, 9, 12, 5, 14, 6, 8, 13, 6, 5, 15, 13, 11, 11]]

# Initial value (hexadecimal)
const h = [0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476, 0xC3D2E1F0]


##############################################################################
##
## Function definitions
##
##############################################################################

function transform!()

end

function ripemd160(msg::ASCIIString; is_hex=true)

  if is_hex
    len = int(length(msg) / 2)
    result = zeros(Uint8, len)
    for i = 1:len
      result[i] = uint8(parseint(msg[2 * i - 1: 2 * i],16))
    end
    msg = result
  else
    # We only want byte array literal (i.e., character array)
    msg = msg.data
  end

  # Get original length and bit lengths
  len = length(msg)
  bitlen = len * 8

  # Append the bit '1' to the message.
  append!(msg, [0x80])

  # Divide up message into blocks of BLOCK_SIZE = 512 bits
  # and run through transformation
  while length(msg) >= BLOCK_SIZE
    transform!(state, msg[1:BLOCK_SIZE])
    msg = msg[BLOCK_SIZE + 1:end]
  end

  # Get the number of characters untransformed
  rem = length(msg)

  # If there are any characters remaining
  if rem > 0

    # Append k bits '0', where k is the minimum number >= 0 such that the 
    # resulting message length (modulo 512 in bits) is 448.
    if length(msg) > BLOCK_SIZE - 8
      msg = append!(msg, zeros(Uint8, BLOCK_SIZE - rem))
      transform!(state, msg)
      msg = zeros(Uint8, BLOCK_SIZE)
    else
      msg = append!(msg, zeros(Uint8, BLOCK_SIZE - rem))
    end

    # Append length of message (without the '1' bit or padding), in bits, as 
    # 64-bit big-endian integer (this will make the entire post-processed 
    # length a multiple of 512 bits)
    msg[57] = (bitlen >>> 56) & 0xff
    msg[58] = (bitlen >>> 48) & 0xff
    msg[59] = (bitlen >>> 40) & 0xff
    msg[60] = (bitlen >>> 32) & 0xff
    msg[61] = (bitlen >>> 24) & 0xff
    msg[62] = (bitlen >>> 16) & 0xff
    msg[63] = (bitlen >>> 8) & 0xff
    msg[64] = bitlen & 0xff

    # Process the last block
    transform!(state, msg)
  end

end

end # module RIPEMD