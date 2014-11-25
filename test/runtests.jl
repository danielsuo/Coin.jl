using Coin
using Base.Test

@test Coin.Crypto.SHA2.sha256("a") == "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb"
