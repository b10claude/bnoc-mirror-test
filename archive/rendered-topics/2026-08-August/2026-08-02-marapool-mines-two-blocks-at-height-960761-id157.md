# MARAPool mines two blocks at height 960761

b10c | 2026-08-03 08:46:11 UTC | #1

![image|690x277](upload://pbUP6M8Mb9Y1PFiFVkdXz2QKze6.png)


Added to the stale-block dataset in https://github.com/bitcoin-data/stale-blocks/commit/0a4e13968d0f538596ef40782c5cc352879c37ab

This is similar to:

- https://bnoc.xyz/t/antpool-mines-two-blocks-at-height-925051/60
- https://bnoc.xyz/t/f2pool-mines-two-blocks-at-height-956337/147

-------------------------

b10c | 2026-08-03 09:26:04 UTC | #2

The coinbase of the winning block had a minimally lower output value of `3.13935663 BTC` vs `3.13954121 BTC` in stale block. This matches with the template/coinbase being generated a second later in the stale block than in the stale block (`87906f6a` -> 1785696391) than in the winning block (`86906f6a`-> 1785696390). 

The header timestamp of the stale block is 1785696415 (vs 1785696391 in the coinbase (24s)) and of the winning block is `1785696392` (2s vs coinbase). Not sure if the miners engaged in time-rolling faster than actual time.

The winning block has 5585 transactions while the stale block has 5647.

-------------------------

b10c | 2026-08-03 09:26:25 UTC | #3

![image|690x484](upload://yBNTJJYDO45KYjUUUZJgDes7nrL.png)

https://mempool.space/block/00000000000000000001e2f3f2ffc556b03a758e2c6552c6e385565e2962bc39?showDetails=true&view=actual#details

-------------------------

b10c | 2026-08-03 09:29:38 UTC | #4

This looks to me like two miners getting jobs from MARA Pool (one job a bit newer than the other) finding blocks at roughly the same time. Similar to the other cases we've seen a pool mine two competing blocks. The old job was still being worked on by a miner.

-------------------------

