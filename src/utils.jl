function reverse_endian(hex_string::String)
  hex_length = length(hex_string)
  
  # Left pad with 0 to make hex_string even length
  if hex_length % 2 != 0
    hex_string = string("0", hex_string)
    hex_length += 1
  end

  return join(reverse([hex_string[2i-1:2i] for i in 1:hex_length/2]))
end