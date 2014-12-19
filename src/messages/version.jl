type NetworkAddress
  time::Uint32
  services::Uint64
  IP::Array{Uint8}
  port::Uint16

  # Assume addresses come in the form IP:Port
  function NetworkAddress(address::String; services = SERVICES_NODE_NETWORK)

    # TODO: more rigorous IP address checking
    pieces = split(address, ":")
    ip = pieces[1:end-1]
    port = pieces[end]

    # If we have an ipv6 address (e.g., xxxx:...{6}...:xxxx)
    if length(ip) > 1
      ip = reduce(vcat, [Crypto.int2oct(uint16(parseint(x, 16))) for x in ip])
    else
      ip = split(ip, ".")
      ip = reduce(vcat, [Crypto.int2oct(uint8(x)) for x in ip])

      pad = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff]
      ip = [pad, ip]
    end

    new(uint64(time()), uint64(services), ip, uint16(port))
  end
end

function convert(::Type{Array{Uint8}}, x::NetworkAddress)
  result = Array(Uint8, 0)

  append!(result, reverse(Crypto.int2oct(x.services)))
  append!(result, x.IP)
  append!(result, Crypto.int2oct(x.port))

  return result
end

type Version
  version::Uint32
  services::Uint64
  timestamp::Uint64
  addr_recv::NetworkAddress
  addr_from::NetworkAddress
  nonce::Array{Uint8}
  user_agent::Array{Uint8}
  start_height::Uint32
  relay::Bool

  # Take address in the form 
  function Version(addr_recv::String, addr_from::String; 
                   version      = BITCOIN_PROTOCOL_VERSION,
                   services     = SERVICES_NODE_NETWORK,
                   timestamp    = int(time()),
                   nonce        = Crypto.random(64),
                   user_agent   = "/Coin.jl:0.0.1/",
                   start_height = 0,
                   relay        = true)

    addr_recv = NetworkAddress(addr_recv, services = services)
    addr_from = NetworkAddress(addr_from, services = services)

    new(uint32(version), 
        uint64(services), 
        uint64(timestamp), 
        addr_recv, 
        addr_from, 
        nonce, 
        user_agent, 
        uint32(start_height), 
        relay)
  end
end
