##############################################################################
##
## Notes
##
##############################################################################

# - All variables are 32 bit unsigned integers. From the Julia documentation 
#
#     http://docs.julialang.org/en/release-0.3/manual/integers-and-floating
#     -point-numbers/
#
#   we see that
#   
#   Unsigned integers are input and output using the 0x prefix and hexadecimal 
#   (base 16) digits 0-9a-f (the capitalized digits A-F also work for input). 
#   The size of the unsigned value is determined by the number of hex digits.
#
# - Addition is calculated modulo 2^32
#
# - For each round, there is one round constant k[i] and one entry in the 
#   message schedule array w[i], 0 ≤ i ≤ 63
#
# - The compression function uses 8 working variables, a through h
#
# - Big-endian convention is used when expressing the constants in this 
#   pseudocode, and when parsing message block data from bytes to words, 
#   for example, the first word of the input message "abc" after padding is 
#   0x61626380

##############################################################################
##
## Algorithm parameters
##
##############################################################################

const DIGESTSIZE = 256 # SHA256 outputs a 256 bit (32 byte) digest
const CHUNKSIZE = 512  # SHA256 operates on 512 bit (64 byte) chunks
const WORDSIZE = 32
const WORDS_PER_CHUNK = 16
const WORDS_PER_SCHEDULE = 64

##############################################################################
##
## Initialize array of round constants
##
##############################################################################

# First 32 bits of the fractional parts of the cube roots of the first 64 
# primes, 2 through 311. A sample generation function below:
#
# function initial_array_of_round_constraints(n)
#   fractional_cuberoot = cbrt(n) % 1
#   first_32_bits = floor(fractional_cube_root * 2^32)
#   @printf "%x" first_32_bits
#   return first_32_bits
# end

const k = [0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 
           0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 
           0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786, 
           0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
           0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 
           0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 
           0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b, 
           0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
           0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 
           0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 
           0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2]

##############################################################################
##
## Initialize helper functions and macros
##
##############################################################################

macro ROTRIGHT(num, shift, intsize) return (num >>> shift) | (num << (intsize - shift)) end

function ROTRIGHT(num, shift, intsize)
  println(bin(num >>> shift))
  println(bin(num << (intsize - shift)))
end

macro CH(e, f, g) return (((e) & (f)) $ (~(e) & (g))) end
macro MA(a, b, c) return ((a) & (b)) $ ((a) & (c)) $ ((b) & (c)) end

# get_chunks takes a message and returns an array of chunks, which themselves
# are arrays of words (32 bits each)
#
# TODO: We should have different branches for string and integer, but
#       we save that for another day
function get_chunks(msg)

  # Get data as binary string.
  data = bin(msg)

  println("data: ", data)

  # Get message length
  # TODO: probably a better way to find message size
  # TODO: can remove
  len = length(data)
  rem = length(data) % CHUNKSIZE

  println("len: ", len)
  println("rem: ", rem)

  # Append the bit '1' to the message
  # TODO: if msg were integer, we do msg << 1 + 1
  data = string(data, '1')
  println("data: ", data)

  # Get message length
  # TODO: probably a better way to find message size
  len = length(data)

  # Append k bits '0', where k is the minimum number >= 0 such that the 
  # resulting message length (modulo 512 in bits) is 448.
  # TODO: if msg were integer, we do msg << pad
  pad = 448 - len + (448 < len ? CHUNKSIZE : 0)
  data = string(data, repeat("0", pad))
  println("pad: ", pad)
  println("data: ", data)

  # Append length of message (without the '1' bit or padding), in bits, 
  # as 64-bit big-endian integer (this will make the entire post-processed 
  # length a multiple of 512 bits)
  # TODO: if msg were integer, we do msg << 64 | len
  data = string(data, lpad(bin(len), 64, "0"))
  println("data: ", data)

  # Update data length
  len = length(data)

  # Determine number of chunks, rounding up to nearest CHUNKSIZE
  num_chunks = int(len / CHUNKSIZE)
  println("num_chunks: ", num_chunks)

  # Pre-allocate return array
  chunks = zeros(Uint32, WORDS_PER_CHUNK, num_chunks)

  # Julia is column-major order
  for j = 1:num_chunks
    for i = 1:WORDS_PER_CHUNK
      lower = (j - 1) * CHUNKSIZE + (i - 1) * WORDSIZE + 1
      upper = lower + WORDSIZE - 1

      println("len: ", length(data))
      println("lower: ", lower)
      println("upper: ", upper)

      # TODO: Sacrificing performance for conciseness, I suppose
      setindex!(chunks, parseint(data[lower : upper], 2), i, j)
    end
  end

  return chunks
end

function sha256(msg)
  # First 32 bits of the fractional parts of the square roots of the first 8
  # primes, 2 through 19. A sample generation function below:
  #
  # function initial_hash_value(n)
  #   fractional_square_root = sqrt(n) % 1
  #   first_32_bits = floor(fractional_square_root * 2^32)
  #   @printf "%x" first_32_bits
  #   return first_32_bits
  # end

  state = [0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a
           0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19]

  chunks = get_chunks(msg)

  for j = 1:size(chunks)[2]
    schedule = zeros(Uint32, WORDS_PER_SCHEDULE)
    for i = 1:WORDS_PER_CHUNK
      schedule[i] = chunks[i][j]
    end
    for i = WORDS_PER_CHUNK + 1:WORDS_PER_SCHEDULE

    end
  end
end

# TODO: Refactor to process one 64 byte (512 bit) chunk at a time
function sha256(msg)

end

