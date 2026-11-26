# Recovering pre-2015 Bitcoin stale blocks from merged-mined chains (revisiting Stifter et al. 2018)

deadmanoz | 2026-04-27 05:13:58 UTC | #1

A common claim around block propagation is that smaller pools stale more often than their hashrate would predict, because they spend a larger fraction of every block race competing against the rest of the network. Antoine Poinsot’s [post on Delving Bitcoin](https://delvingbitcoin.org/t/propagation-delay-and-mining-centralization-modeling-stale-rates/2110) puts numbers on the theoretical side - roughly a 2:1 stale-rate ratio between a 1% pool and a 30% pool across plausible propagation delays. Whether this actually shows up on the real network is a different question, and you can only answer it empirically if you have enough stale events to look at.

Unfortunately, there’s the awkward matter of systematic live monitoring only really kicking off from 2015 or so. The KIT DSN [Bitcoin fork dataset](https://www.dsn.kastel.kit.edu/bitcoin/forks/) starts in mid-July 2015, and while 0xB10C’s [`bitcoin-data/stale-blocks`](https://github.com/bitcoin-data/stale-blocks) does contain some earlier entries, the “pre-KIT” public record is sparse and heterogeneous rather than a systematic observation window. That’s exactly the period where the centralisation effect should be largest, because compact blocks and FIBRE didn’t exist yet, fast-relay infrastructure was still immature and unevenly adopted, and propagation delays were several seconds to tens of seconds rather than the almost sub-second we see today. Without enough data from that period, the ability to test the theory in the most interesting era is problematic.

This is where I came across **Stifter et al. 2018,** *[Echoes of the Past: Recovering Blockchain Metrics From Merged Mining](https://eprints.cs.univie.ac.at/6448/1/2018-1134.pdf)* (eight years on, better late than never…). Their core observation is simple: once Namecoin enabled merge-mining at block 19,200, each merge-mined block preserved the Bitcoin header miners used for its parent proof-of-work, plus the coinbase transaction and merkle proofs tying the Namecoin commitment back to that header. That bundle is the Auxiliary Proof-of-Work (AuxPoW) object. By itself, it proves the parent Bitcoin header was good enough for Namecoin.

The useful subset for Bitcoin stale recovery is narrower: records whose parent header also satisfies Bitcoin’s target at the claimed height. Those are real Bitcoin-difficulty SHA-256 solutions. So a Namecoin chain history is, among other things, a self-authenticating record of Bitcoin stale-work attempts, and the same applies to other AuxPoW chains they looked at (e.g. I0Coin, Devcoin, ixcoin, GeistGeld, Groupcoin, Unobtanium). It’s a side channel into Bitcoin’s early mining behaviour that doesn’t depend on anyone having been listening on the P2P network at the time.

I started by re-running the simplest version of the methodology against Namecoin. I ran a Namecoin Core full node, extracted every AuxPoW commitment, and validated each candidate parent header in two stages: first, the 80-byte header double-SHA256s to its declared block hash and satisfies the PoW target encoded in its own \`nBits\`; second, \`nBits\` matches Bitcoin’s canonical difficulty at the claimed height (this is also what cleanly rejects BCH/BSV headers post-August-2017). That produced [PR #94 to bitcoin-data/stale-blocks](https://github.com/bitcoin-data/stale-blocks/pull/94) with **1,089 recovered headers**. 795 of those rows fall below the KIT cutoff, adding 754 previously unrepresented pre-KIT heights to \`stale-blocks.csv\` - a \~59% increase in pre-KIT height coverage from Namecoin alone, (Namecoin merge-mining starts October 2011). 0xB10C is also independently validating the contribution with [this script](https://gist.github.com/deadmanoz/6b3ac580df1021246da026ff4f0fcd15).

The embedded coinbases are also important for answering the small-pool stale-rate question, as well as being a useful sanity check. Pool attribution comes out 88.5% to named pools (BTC Guild, Eligius, BitMinter, GHash.IO and early Slush/Braiins pre-2016; F2Pool, AntPool, BTCC, BTC.com later), which is exactly the kind of mining population you would expect if these are Bitcoin mining artefacts rather than foreign-chain contamination.

Namecoin is only the first pass. I’m currently working through recent and historical data from a broader set of merge-mined chains so the public record can be expanded beyond Namecoin and brought up to date as of 2026, rather than stopping at the 2018 extraction window. I also wrote to Nicholas asking whether any of the original 2018-era outputs were still around, and he very kindly stood up the original [`NStifter/mergedmonitor`](https://github.com/NStifter/mergedmonitor) artefacts a few hours later!! I’m exploring those now; some additional data may have been lost during an infrastructure migration, but he has since indicated that it might be retrievable (fingers crossed).

**What’s coming next**

\- Significantly improved pre-2015 stale data in the public catalogue, properly attributed, so anyone can use the expanded data set for whatever research purpose.

\- The appropriate parts of the `NStifter/mergedmonitor` artefacts folded into the public catalogue with attribution to the team. Their 2018 dataset covers chains I’m unlikely to be able to re-derive from scratch today (e.g. I0Coin, GeistGeld, Groupcoin in particular - dormant clients, no working public explorers), so this is also a preservation outcome. Plus whatever further data Nicholas is able to retrieve.

\- A published empirical answer to the small-pool stale-rate question. That’ll go up as its own post once everything has been analysed.

\- Side-channel *\*live\** observation of merged-mined chains is where I am headed once the historical data is published. AuxPoW lets you watch Bitcoin stale-work events in real time off the back of a child chain’s P2P network (or alternatively, scraping from block explorers)..

\- More awareness of the methodology and credit to Stifter et al; I think the technique is quite neat and under-cited relative to how useful it appears to be.

-------------------------

deadmanoz | 2026-07-22 09:24:41 UTC | #2

It has been a bit of a mission (I initially "moved fast and broke things"), but I've finally managed to organise and cleanup for public release the work I did on stale block acquisition from chains that merge mine with Bitcoin as I outlined in my post above.

It's now on Github under [merge-mining-research](https://github.com/deadmanoz/merge-mining-research).

As the repo name and contents is indicative of, I realised that stale blocks is just one aspect of merge mining on Bitcoin, so I broadened the scope to be the foundation for research into merge mining on Bitcoin generally, and have outlined additional research directions and analysis that myself or others can pursue, although the initial focus is indeed on stale (and canonical) Bitcoin block recovery/assignment.

I have some additional analysis regarding mining pool ID and analysis that I will be contributing next, and will continue to seek to fill the remaining data gaps in the interest of having a merge mining resource that is as complete as possible for future research.

There's many GB of the original source data from these chains that I still need to work out how to preserve for the historical record, e.g. chain data from chains that have single live peers, or hosted blockchain data `.zip` files or similar that could go offline at any notice. Anyway, I will retain this data indefinitely until I can figure this out (suggestions welcome).

As I mention in the [README](https://github.com/deadmanoz/merge-mining-research/blob/main/README.md), and should come as no surprise in this day and age, AI/LLMs were indispensable in helping with the discovery, extraction, organisation etc of all of this. But any errors or oversights reside with me.

-------------------------

