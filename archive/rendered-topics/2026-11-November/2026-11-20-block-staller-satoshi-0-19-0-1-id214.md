# Block staller /Satoshi:0.19.0.1/

stratospher | 2026-11-20 19:26:03 UTC | #1

`3.72.130.203` announces new blocks to frank (`blocksonly=1` which means no mempool/compact block I think) and then never sends them. frank disconnects this peer but it reconnects back in 60 seconds.

- on nov 10: it was 6/135 blocks which `3.72.130.203` announced first and stalled
- on nov 19: it grew to 95/162 blocks which stalled 

so seeing logs like `Timeout downloading block 976505, disconnecting peer=883` much more frequently now. depending on how much stalling happened - frank can be few blocks behind the tip compared to other nodes.

- on nov 19: 62% of the time frank was at chain tip, 24% of the time was 1 block behind, 11% of the time was 2 blocks behind and 4% of the time was 3-4 blocks behind.

version message says `/Satoshi:0.19.0.1/`, protocol 70015, blocks=0, us=0.0.0.0:0, txrelay=0, AS16509 (Amazon)

-------------------------

b10c | 2026-11-21 16:27:28 UTC | #2

This are ViaBTC's `bitpeer` connections. I have some notes I still want to write up for this, but it's the same peers in https://b10c.me/blog/012-viabtc-spv-vulnerability-disclosure/. These also caused us to notice this https://bitcoincore.org/en/2024/11/05/cb-stall-hindering-propagation/.

Last time I checked they were announcing the `WITNESS` service flag, so we'd ask for witness `getdata`, but they don't handle witness `getdata` at all. They only handle type `2`, which is `MSG_BLOCK` and not `MSG_WITNESS_BLOCK` we'd expect them to send.

https://github.com/bitcoin/bitcoin/blob/442b152c8b012e03720de9004d8f1ae422fa4d17/src/protocol.h#L500-L505

https://github.com/viabtc/viabtc_mining_server/blob/4891c9ccbadc773919cbb3a53beca1b610fb6543/bitpeer/bp_peer.c#L609-L611

There's a similar problem with them mentioned in https://b10c.me/observations/10-viabtc-blocks-without-witness-data/.

-------------------------

b10c | 2026-11-21 16:31:09 UTC | #3

These might be a good candidate to track in [https://github.com/bitcoin-noc/network-entities](https://github.com/bitcoin-noc/network-entities) until they improve their client. I've told them about this more than 2 years ago.

-------------------------

