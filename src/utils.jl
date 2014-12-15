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
    append!(result, convert(Array{Uint8}, uint8(x)))
  elseif x <= 0xffff
    append!(result, [0xfd])
    append!(result, convert(Array{Uint8}, uint16(x)))
  elseif x <= 0xffffffff
    append!(result, [0xfe])
    append!(result, convert(Array{Uint8}, uint32(x)))
  else
    append!(result, [0xff])
    append!(result, convert(Array{Uint8}, uint64(x)))
  end

  return result
end

function reverse_endian(hex_string::String)
  return join([hex(x, 2) for x in reverse(hex_string_to_array(hex_string))])
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

# TODO: String manipulation is really not the best way
function convert(::Type{Array{Uint8}}, x::Integer)
  padding = 0
  if typeof(x) != BigInt
    padding = sizeof(x) * 2
  end
  hex_string = hex(x, padding)
  return hex_string_to_array(hex_string)
end

function get_checksum(message::String; is_hex = false)
  create_digest(x) = Crypto.digest("SHA256", x, is_hex = is_hex)
  return create_digest(create_digest(message))[1:8]
end

function hex_string_to_array(hex_string::String)
  hex_length = length(hex_string)

  # Left pad with 0 to make hex_string even length
  if hex_length % 2 != 0
    hex_string = string("0", hex_string)
    hex_length += 1
  end

  hex_length = div(hex_length, 2)

  return [uint8(parseint(hex_string[2i-1:2i], 16)) for i in 1:hex_length]
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
println(x::Array{Uint8}) = print(x); print()

function string(x::Unsigned)
  return string("0x", hex(x, div(sizeof(x), 2)))
end

print(x::Unsigned) = print(string(x))
println(x::Unsigned) = print(x); print()