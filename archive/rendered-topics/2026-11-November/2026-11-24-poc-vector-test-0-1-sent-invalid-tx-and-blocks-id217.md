# /poc-vector-test:0.1/ sent invalid tx and blocks

stratospher | 2026-11-24 15:56:19 UTC | #1

`/poc-vector-test:0.1/` connected to 2 of peer.observer nodes via tor exits and sent invalid transactions and blocks. everything was obviously rejected. but just tracking it here.

each node got:
- 18 transactions in the same order (one every 8.5 s)
    1. 9 of them were `bad-txns-inputs-missingorspent`.
        - they were followed by `[txpackages] added peer=<id> as a candidate for resolving orphan <wtxid>`. so the node kept all 9 as orphans and they were erased when the peer was disconnected.
        - the parents were made up txids or sometimes real txids
    2. 2 of them were `bad-txns-inputs-duplicate`
    3. 7 of them were `tx-size-small`
-  9 blocks each on a new connection because every invalid block would make us disconnect them. saw logs like `[error] ProcessNewBlock: AcceptBlock FAILED (high-hash, proof of work failed)`.

the 2nd time it reconnected, it also sent a `merkleblock` p2p message (which we logged as `Unknown message type "merkleblock"`) and then block 2. 

it's version message was: `/poc-vector-test:0.1/` version 70016, blocks=870000, txrelay=0

-------------------------

