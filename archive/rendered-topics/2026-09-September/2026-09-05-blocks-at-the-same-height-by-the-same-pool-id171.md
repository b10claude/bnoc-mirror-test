# Blocks at the same height by the same pool

CedArctic | 2026-09-06 00:06:42 UTC | #1

Following up on the discussion from recent similar observations (see [1](https://bnoc.xyz/t/spiderpool-mines-two-blocks-at-same-height-963853/166), [2](https://bnoc.xyz/t/antpool-mines-two-blocks-at-height-925051/60), [3](https://bnoc.xyz/t/marapool-mines-two-blocks-at-height-960761/157), [4](https://bnoc.xyz/t/f2pool-mines-two-blocks-at-height-956337/147)), I wanted to see how frequently any given pool mines two blocks at the same height. I attach a small dataset below. [:goose:](https://www.youtube.com/watch?v=dQw4w9WgXcQ)

**Methodology:** I sourced full stale blocks from the [stale-blocks](https://github.com/bitcoin-data/stale-blocks) dataset and compared them against the blocks at the same height on the longest (referred to below as "canonical") chain. Two blocks are considered to be mined by the same pool if there is any overlap in their coinbase TX output addresses.

**Observations:**

* **Number of occurences:** This has happened a total of 44 times across the 1065 full blocks included in the [stale-blocks](https://github.com/bitcoin-data/stale-blocks) dataset (approx 4% of stales). 1 of these occurences is Ocean mining on the BIP-110 fork. This particular block is excluded from the analysis below as it skews results.
* **Occurrences across time:** This phenomenon is not a recent development and appears to occur throughout time. The first such pair of blocks that I could identify were mined at height 231793 back in 2013.
* **Block times:** Stale block timestamps were on average older by \~80s. If we exclude outliers in the first and fourth quartile this drops to 0.0645s. Time delta (stale_ts-canonical_ts) statistics over all blocks: mean: -80.2093s, median: 0s, std: 304.8935s, min: -1728s, max: 377s.
* **Block sizes:** Stale blocks mined by the same pool were on average smaller by \~44kb. Block size delta (stale_bytes-canonical_bytes) statistics: mean: -44030.0465 bytes, median: -6 bytes, std: 220470.3769 bytes, min: -1150550 bytes, max: 208076 bytes.
* **Transaction counts:** Stale blocks had on average 76.2 fewer TXs than the canonical block. TX number delta statistics (stale_txs - canonical_txs): mean: -76.2093 txs, median: 0, std: 438.1779 txs, min: -2454 txs, max: 361 txs.
* **Fees:** Stale blocks mined by the same pool had a higher fee than their canonical counterparts in 18/43 cases. For these cases, the aggregate losses were 0.3768 BTC. In total, stale blocks were worth 8.1862 BTC in fees, and canonical blocks were worth 8.7567.
* **Empty blocks:** Only one of the stales mined by the same pool hints at some misconfiguration by virtue of it being an empty block.
* **Miner tags:** Overall all stale-canonical block pairs have miner tags with substantial common ASCII substrings, with only one exception, where the stale tag includes "Eligius" (currently Ocean mining), whereas the canonical block just includes "/P2SH/". Some of the ViaBTC tags are interesting in that they indicate the miner, and the two mined blocks have different tags (e.g: canonical - "/ViaBTC/Mined by zhujunqiang/", stale - "/ViaBTC/Mined by amirr91/").

**Figures:**

[details="Summary"]

[grid]

![fig1_time_delta_distribution|690x383](upload://tBWCLErEfFBdyll6PRhEAsAxODL.png)

![fig5_block_size_delta_distribution|690x383](upload://7nARs1bw7VEoRYRPYsRWZbWQiRC.png)

![fig4_stale_blocks_rolling_average|690x345](upload://lS4WBt3XdS1aokKOsAQNKTCYs2W.png)

![fig2_tx_count_delta_distribution|690x383](upload://2thHLonteCre54a4s5Yw9KJF4L3.png)


[/grid]

[/details]

**Dataset:** https://gist.github.com/CedArctic/51d2e4c9624da65f77c55fdc9675aecd

**JSON fields:**
•  version: nVersion
•  prev_block: hex string of the parent block hash (hashPrevBlock)
•  timestamp: Unix epoch timestamp (nTime). Note that this is the timestamp in the block, and *not* the time the block was observed in the network.
•  block_size: Block size in bytes
•  miner_ta : ASCII string from the coinbase  scriptSig
•  common_coinbase_addresses: First address-bearing output of the coinbase TX
•  coinbase_amount: Total value in BTC of all coinbase outputs
•  tx_count: Total number of transactions included in the block (empty blocks only have the coinbase TX)
•  total_fees: Total TX fees in BTC (coinbase_amount - block_subsidy)
•  time_delta: Timestamp offset in seconds (timestamp_stale - timestamp_canonical)
•  size_delta: Difference in binary block size in bytes (size_stale - size_canonical)
•  tx_count_delta: Difference in total transaction count (tx_count_stale - tx_count_canonical)
•  parent_match: True if the stale block builds on the same parent as the canonical block
•  is_empty_block : True if the stale block contains no transactions other than the coinbase

-------------------------

