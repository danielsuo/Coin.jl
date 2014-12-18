# TestNet: https://en.bitcoin.it/wiki/Testnet
# - Faucet: http://faucet.xeno-genesis.com/
# - Explorer: http://tbtc.blockr.io/
# - Peerlist: nslookup testnet-seed.bitcoin.petertodd.org

Crypto.init()

priv_key = "7e68e472a6b41f165c0d13b57b6ac88440367c25361b5d6d407bb5fe2cd05a12"
# moZRBjoq3ELstSp6CPeBXir5FSpjjHyQMp
pub_key = get_pub_key(priv_key, network_id = 0x6f)
