function reverse_endian(hex_string::String)
  hex_length = length(hex_string)

  # Left pad with 0 to make hex_string even length
  if hex_length % 2 != 0
    hex_string = string("0", hex_string)
    hex_length += 1
  end

  return join(reverse([hex_string[2i-1:2i] for i in 1:hex_length/2]))
end

function reverse_endian(hex_data::Number)
  data_type = typeof(hex_data)
  result = 0

  while hex_data > 0
    result = convert(data_type, result << 8 + hex_data & 0xff)
    hex_data >>>= 8
  end

  return result
end

function get_checksum(message::String; is_hex = false)
  create_digest(x) = Crypto.digest("SHA256", x, is_hex = is_hex)
  return create_digest(create_digest(message))[1:8]
end