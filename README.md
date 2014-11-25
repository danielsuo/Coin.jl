Coin.jl
=========
[![Build Status](https://travis-ci.org/danielsuo/Coin.jl.svg?branch=master)](https://travis-ci.org/danielsuo/Coin.jl)
[![Coverage Status](https://coveralls.io/repos/danielsuo/Coin.jl/badge.png)](https://coveralls.io/r/danielsuo/Coin.jl)

A (self-educational, incomplete, and likely incorrect) library for working with Bitcoin written in Julia.

# To Do
First, we're going to implement a thin-client wallet.

- Should consider creating object types (e.g., addresses with metadata; wallets; etc)

## Public key distribution
- Base58 encoding / decoding [ref](https://github.com/bitcoin/bitcoin/blob/master/src/base58.cpp)
- RIPEMD-160 [ref](https://github.com/bitcoin/bitcoin/blob/master/src/crypto/ripemd160.cpp)
- Elliptic Curve DSA [ref](https://github.com/bitcoin/secp256k1/blob/master/src/secp256k1.c)
- Wallet Interchange Format [ref](https://en.bitcoin.it/wiki/WIF)

## Signing program
- TBD

## Network operations
- TBD

## Utilities
- TBD

# Reference
- Bitcoin: [https://github.com/bitcoin/bitcoin](https://github.com/bitcoin/bitcoin)
- Bitcoinj: [https://github.com/bitcoinj/bitcoinj](https://github.com/bitcoinj/bitcoinj)
- Toshi: [https://github.com/coinbase/toshi](https://github.com/coinbase/toshi)
- Bitcoin-ruby: [https://github.com/lian/bitcoin-ruby](https://github.com/lian/bitcoin-ruby)
- Bitcoinjs: [https://github.com/bitcoinjs/bitcoinjs-lib](https://github.com/bitcoinjs/bitcoinjs-lib)

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