##############################################################################
##
## Notes
##
##############################################################################

# - All variables are 32 bit unsigned integers
# - Addition is calculated modulo 2^32
# - For each round, there is one round constant k[i] and one entry in the message
#   schedule array w[i], 0 ≤ i ≤ 63
# - The compression function uses 8 working variables, a through h
# - Big-endian convention is used when expressing the constants in this pseudocode, 
#   and when parsing message block data from bytes to words, for example, the first 
#   word of the input message "abc" after padding is 0x61626380

##############################################################################
##
## Initialize hash values
##
##############################################################################

# First 32 bits of the fractional parts of the square roots of the first 8
# primes, 2 through 19. A sample generation function below:
#
# function initial_hash_value(n)
#   fractional_square_root = sqrt(n) % 1
#   first_32_bits = floor(fractional_square_root * 2^32)
#   @printf "%x" first_32_bits
#   return first_32_bits
# end

h0 = (0x6a09e667)::Uint32
h1 = (0xbb67ae85)::Uint32
h2 = (0x3c6ef372)::Uint32
h3 = (0xa54ff53a)::Uint32
h4 = (0x510e527f)::Uint32
h5 = (0x9b05688c)::Uint32
h6 = (0x1f83d9ab)::Uint32
h7 = (0x5be0cd19)::Uint32

@printf "%x\n" h0
println(typeof(h0))