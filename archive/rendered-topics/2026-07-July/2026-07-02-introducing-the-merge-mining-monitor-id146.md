# Introducing the Merge Mining Monitor

deadmanoz | 2026-07-02 08:12:45 UTC | #1

Following up on my earlier thread about recovering pre-2015 Bitcoin stale blocks from merged-mined chains ([here](https://bnoc.xyz/t/recovering-pre-2015-bitcoin-stale-blocks-from-merged-mined-chains-revisiting-stifter-et-al-2018/120)), I kept pulling on that line of work and have created a new tool in service of the Bitcoin monitoring mission: the [Merge Mining Monitor](https://mmm.deadmanoz.xyz/).

As in the original post, Stifter et al. showed that merge-mined child chains preserve the Bitcoin parent headers their miners actually hashed. That makes them a side channel into Bitcoin stale and orphan blocks, as well as a way to associate child-chain blocks with the Bitcoin parent headers they committed to.

What began as a historical data recovery exercise turned into a live and historical monitor (I did things a bit backwards compared with the original plan, at least in terms of publishing the datasets etc.). The monitor reads AuxPoW evidence across six live producers, 17 recovered child-chain datasets, and ten catalogued chains where data is still missing. It then makes the resulting pool attribution, child-chain attribution, stale-block evidence, and orphan evidence explorable in a fork-observer-like tree view.

The current record is 2,200+ recovered stale & orphan blocks from current chain tip right back to 2011 when Namecoin started merge-mining with Bitcoin. Many of those blocks have no durable trace left on the Bitcoin network itself.

Even though direct Bitcoin-network monitoring is much more mature in 2026, the value of this side channel is still apparent. For example, the monitor recovered an F2Pool stale at Bitcoin height 953,715 via RSK, around two weeks ago at time of writing, which does not appear to have propagated widely on the Bitcoin network: [F2Pool 953715 on RSK](https://mmm.deadmanoz.xyz/?tree_window=generated&tree_from=953699&tree_to=953731&tree_height=953715&selected=000000000000000000009d0c8597a8b0ae9dd1e1ef16e9dd8d4a94ed7e486bc7). There are many such instances, with this just being the most recent.

I have plans to add more visualisations, including graphs of merge-mining breakdown over time (blocks per difficulty period for each chain, child-chain difficulty relative to Bitcoin, and so on), and better ways to show the cadence of block production across chains. Some of the facets I want to explore:

* block timestamp differentials, including whether cross-chain timing anomalies point to anything worth investigating;
* mining proxy relationships, including cross-checking 0xB10C’s AntPool-and-friends research from another data source;
* mining pool dynamics, which was the original stale-block data question that set me down this rabbit hole;
* notification capabilities such as RSS;
* auto-publishing into the foundational public dataset at [bitcoin-data/stale-blocks](https://github.com/bitcoin-data/stale-blocks).

Suggestions, corrections, missing-chain leads, and other feedback very welcome!!

-------------------------

deadmanoz | 2026-07-02 08:16:53 UTC | #2

Some data that may be of interest in the following comments

-------------------------

deadmanoz | 2026-07-02 09:03:54 UTC | #3

Foundry produced a ***very*** high number of stale blocks on 11/12th September 2025 as recorded in the records of RSK and Fractal Bitcoin: https://mmm.deadmanoz.xyz/?tree_time=2025-09-18T16%3A21%3A51Z&selected=00000000000000000000ba485fa4bbba0416890572ff6b5853cdc24e92d7434f

![Screenshot 2026-07-02 at 4.22.59 pm|690x346](upload://5msuOgKfdk4ArZpKZsr2kcsErxV.jpeg)

I've not dug into this deeply at this stage, and this certainly warrants a deeper investigation, but the preliminary (AI-assisted) findings are:

- 20 stale Foundry blocks between heights 914261 and 914373, a window of roughly 20 hours running from 2025-09-11 17:48 UTC to 2025-09-12 14:05 UTC. Every stale block in that window is Foundry's; no other pool lost a single block.
- All 20 are genuine full-difficulty Bitcoin blocks. I re-verified each stored 80-byte header independently of the monitor's classifier: the header hashes to its claimed block hash, the hash meets the header's own nBits target, the nBits matches the canonical difficulty epoch at that height, and the prev hash points at the canonical parent.
- These blocks appear never to have reached the Bitcoin network. There are no ForkMonitor/fork.observer/stale-blocks stale-candidate entries near these heights, and I found no discussion of the event anywhere online. The only surviving evidence is the AuxPoW commitments captured by RSK and Fractal Bitcoin.
- The header timestamps support this. In a normal propagation race the competing blocks are seconds apart. Here, 18 of the 20 losing blocks carry timestamps 135 to 1621 seconds (median ~600s) *before* the canonical winner at the same height. The network wasn't racing Foundry, it simply kept mining as though Foundry's blocks didn't exist. (The other 2 look like ordinary races: one 0s self-race and one 6s loss to F2Pool.)
- Foundry's canonical share over the window was ~18% (20 of 113 blocks), well below the ~29% it held across the two weeks either side (592 of 2,022 blocks). Counting the stales, the network found 133 full-difficulty solutions in the window (113 canonical + 20 stale) and Foundry found 40 of them (20 + 20), i.e. 30%, right at its normal share. So the pool's hashrate was fine; roughly half the blocks it found were silently lost. The 20 stales sit at 16 distinct heights (4 heights have two Foundry stales each, and only one block per height can win; at 914261 the winner was Foundry itself), so the incident cost the pool 15 heights it would otherwise almost certainly have won: ~46.9 BTC in foregone subsidy plus fees.
- Every stale builds on a canonical parent and none of them chain onto each other, which suggests the found blocks never even made it back into Foundry's own block templates. That points at a failure in the block-submission path at the pool layer rather than a network partition.
- Attribution is high-confidence on two independent bases: 13 of the 20 carry the `Foundry USA Pool` tag in the Bitcoin parent coinbase embedded in Fractal's AuxPoW proof, and the remaining 7 (RSK-only evidence) pay out to Foundry's known RSK reward address `0xCe7864A8...845D4a`.

The evidence is publicly and independently checkable. For example, for the selected block above (height 914342): Fractal block [1061372](https://mempool.fractalbitcoin.io/block/3ef4d377b189f08f04d89934e8b5589812c34358f7e6da52b50f835cb0f1e249) is canonical on Fractal and commits to the stale parent, and RSK block [0x45b485e9...](https://rootstock.blockscout.com/block/0x45b485e90ea7a46f13b31e2abbac1ff0d0d576fbf9c18ee3b3d6d221e518c280) at height 7987912, whose captured AuxPoW embeds the same parent header, is visible on Blockscout as mined by Foundry's RSK address (that RSK block was itself reorged out, consistent with its Bitcoin parent never propagating, but Blockscout retains it as an uncle).

One caveat: header timestamps are miner-set, so any single delta could be clock skew. But 18 losses in one direction averaging ~12 minutes, plus zero sightings by Bitcoin network monitors, is hard to read as anything other than ~20 hours of Foundry's blocks intermittently failing to propagate? 

Regardless, an event that cost them dearly (~46.9 BTC), which could have been openly detected had this monitor been operating!

-------------------------

ajtowns | 2026-07-02 14:57:27 UTC | #4

I wonder if that indicates the foundry blocks were invalid somehow -- too many transactions, bad transaction ordering, an invalid transaction in a mempool, or bad math in the coinbase somewhere? That would cause block relay to fail very quickly. As an FPPS pool, presumably individual miners didn't see an impact.

-------------------------

b10c | 2026-07-02 15:43:57 UTC | #5

I just had a look through KIT block announcement data shared by @matthias, and none of the block hashes seem to have been announced to their monitoring nodes (which only receive INVs, not compact blocks).

These are SOME(!) of the hashes of these blocks:

```
914329 00000000000000000002097c6c16d3e4065640c744d544d35dd797d06189a4ab
914331 00000000000000000000439817c63926873f46ca396974268b1f9f6eae84b1c1
914332 0000000000000000000122a9c97762f507cc57df067f07b826ab0a81cb4e787f
914332 000000000000000000016c286d182701403f8eb2e322a844a019c933ba6082cb
914334 0000000000000000000092003874d2b869e8b986339f5bcf8c3a03f5dddd972c
914342 00000000000000000000ba485fa4bbba0416890572ff6b5853cdc24e92d7434f
914344 0000000000000000000075bdcb14ab9b07e87c6c5a43addb81ff6dd74c14d16e
914344 000000000000000000020806ba231682bab800c757366c169b2e17259a5e3aaf
914357 0000000000000000000135a4e20e4402f5f3b5798b2d49ec9f51614feb224c93
914360 00000000000000000001c7664aeb6f4ce7f29e3f799eb3aafb924255d6643573
914362 0000000000000000000098d9f82cd465d4a1e55fabb659d1df2464648f796777
914362 0000000000000000000170e712b2da3ba73fb618753fc44d0e4b6b1db3e3fc4b
914371 000000000000000000013cad1d0d9a4d168c0b2dbae847fa8a2c3ba0704252c0
914373 00000000000000000000a4a5644ce7e315feeeb1c586903c077993bb5f7825a2
```

-------------------------

b10c | 2026-07-02 15:23:34 UTC | #6

Also didn’t find any of these hashes in my peer-observer debug.logs

-------------------------

deadmanoz | 2026-07-02 15:29:08 UTC | #7

Yeah, that could be it.. there's no stratum data for Foundry we could cross-reference right?

-------------------------

