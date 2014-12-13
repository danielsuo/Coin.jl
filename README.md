Coin.jl
=========
[![Build Status](https://travis-ci.org/danielsuo/Coin.jl.svg?branch=master)](https://travis-ci.org/danielsuo/Coin.jl)
[![Coverage Status](https://coveralls.io/repos/danielsuo/Coin.jl/badge.png)](https://coveralls.io/r/danielsuo/Coin.jl)

A (self-educational, incomplete, and likely incorrect) library for working with Bitcoin written in Julia.

# To Do
- https://en.bitcoin.it/wiki/Technical_background_of_Bitcoin_addresses

## Wallet
First, we're going to implement a thin-client wallet.

- Should consider creating object types (e.g., addresses with metadata; wallets; etc)
- Clean up tests to make more consistent

### Public key distribution
- See [ref](https://github.com/danielsuo/Crypto.jl)

### Signing program
- See [ref](https://github.com/danielsuo/Crypto.jl)

### Network operations
- TBD

### Utilities
- TBD

## Vault and multisig
- https://github.com/ciphrex/CoinVault
- BIP 32 HD Wallets [ref](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki)

## Mining
- https://github.com/ckolivas/cgminer

# Reference
- Bitcoin: [https://github.com/bitcoin/bitcoin](https://github.com/bitcoin/bitcoin)
- Bitcoinj: [https://github.com/bitcoinj/bitcoinj](https://github.com/bitcoinj/bitcoinj)
- Toshi: [https://github.com/coinbase/toshi](https://github.com/coinbase/toshi)
- Bitcoin-ruby: [https://github.com/lian/bitcoin-ruby](https://github.com/lian/bitcoin-ruby)
- Bitcoinjs: [https://github.com/bitcoinjs/bitcoinjs-lib](https://github.com/bitcoinjs/bitcoinjs-lib)
- Protocol: [https://en.bitcoin.it/wiki/Protocol_specification](https://en.bitcoin.it/wiki/Protocol_specification)

# Articles
- [Developer guide](https://bitcoin.org/en/developer-guide)
- [Developer reference](https://bitcoin.org/en/developer-reference)
- [Develoepr examples](https://bitcoin.org/en/developer-examples)
- [http://www.righto.com/2014/02/bitcoins-hard-way-using-raw-bitcoin.html](http://www.righto.com/2014/02/bitcoins-hard-way-using-raw-bitcoin.html)
- [http://www.righto.com/2014/02/bitcoin-mining-hard-way-algorithms.html](http://www.righto.com/2014/02/bitcoin-mining-hard-way-algorithms.html)

# Eventually
- Dockerize
- [TheBlueMatt tests](https://github.com/TheBlueMatt/test-scripts)
- Add to Julia pkg repo and get badge
- Split off Crypto package
- Write Struct (a la Python's `struct` module) package?
