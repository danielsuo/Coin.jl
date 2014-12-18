import Base.convert
import Base.string
import Base.print
import Base.println

# Bitcoin's variable length integer
# https://en.bitcoin.it/wiki/Protocol_specification#Variable_length_integer
#
# Only providing convenience functions to and from Array{Uint8} because varint
# seems like its primarily a transport structure
#
# VarInt are created as big-endian here, but are sent little-endian as per
# https://bitcoin.org/en/developer-reference#compactsize-unsigned-integers
function to_varint(x::Integer)
  result = Array(Uint8, 0)

  if x < 0
    error("Negative values for VarInt undefined.")
  elseif x < 0xfd
    append!(result, Crypto.int2oct(uint8(x)))
  elseif x <= 0xffff
    append!(result, [0xfd])
    append!(result, Crypto.int2oct(uint16(x)))
  elseif x <= 0xffffffff
    append!(result, [0xfe])
    append!(result, Crypto.int2oct(uint32(x)))
  else
    append!(result, [0xff])
    append!(result, Crypto.int2oct(uint64(x)))
  end

  return result
end

function reverse_endian(hex_string::String)
  return join([hex(x, 2) for x in reverse(hex2oct(hex_string))])
end

function reverse_endian(hex_data::Integer)
  data_type = typeof(hex_data)
  num_bytes = sizeof(data_type)
  counter = 0
  result = 0

  # Assumes BigInts are at least 16 bytes
  while counter < num_bytes || hex_data > 0
    result = convert(data_type, result << 8 + hex_data & 0xff)
    hex_data >>>= 8
    counter += 1
  end

  return result
end

function get_checksum(message::String; is_hex = false)
  message = Crypto.digest("SHA256", Crypto.digest("SHA256", message, is_hex = true))
  return Crypto.oct2hex(message[1:4])
end

function get_checksum(message::Array{Uint8})
  return Crypto.digest("SHA256", Crypto.digest("SHA256", message))[1:4]
end

# Convenience function for converting to Array{Uint8}
# Must be defined for given types
function bytearray(x)
  convert(Array{Uint8}, x)
end

function string(array::Array{Uint8})
  return string("[", join([string("0x", hex(x, 2)) for x in array], ", "), "]")
end

print(x::Array{Uint8}) = print(string(x))
println(x::Array{Uint8}) = print(x); print("\n")

function string(x::Unsigned)
  return string("0x", hex(x, div(sizeof(x), 2)))
end

print(x::Unsigned) = print(string(x))
println(x::Unsigned) = print(x); print("\n")
