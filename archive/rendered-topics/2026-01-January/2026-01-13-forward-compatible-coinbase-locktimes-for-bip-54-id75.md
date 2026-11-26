# Forward-compatible coinbase locktimes for BIP-54

b10c | 2026-01-13 12:23:22 UTC | #1

One of the four requirement of [BIP-54 (Consensus Cleanup)](https://github.com/bitcoin/bips/blob/master/bip-0054.md) is that:

> The coinbase transaction's `nLockTime` field must be set to the height of the block minus 1 and its `nSequence` field must not be equal to 0xffffffff.

Additionally, the BIP encourages:

> mining pools to update their software to craft coinbase transactions that are forward-compatible with the changes proposed in this BIP.

I've set up a mainnet-observer chart for this: https://mainnet.observer/charts/transactions-coinbase-locktime-bip54/ - but it seems as of writing no pool sets their coinbase locktime to be forward-compatible with BIP-54. 

Additionally, it's interesting to look at the pools that set their coinbase locktime to a non-zero value, which might reveal incompatibilities. This is done in https://mainnet.observer/charts/transactions-coinbase-locktime/.

![image|690x474](upload://pDgEQSFsPfjf1EahlfBsu1Akjzd.png)

Querying the mainnet-observer database revealed that currently, F2Pool is setting locktimes of their coinbase transactions, and pools like MaraPool and Poolin did so historically. 

![image|671x500](upload://qaainsChyWvEXtw1fVIDkO1fqBn.png)
 

Relevant discussions:
- https://groups.google.com/g/bitcoinminingdev/c/jlqlNHHNSNk/m/RBT_LBWQAgAJ
- https://groups.google.com/g/bitcoindev/c/6TTlDwP2OQg

-------------------------

Antoine | 2026-02-23 22:26:22 UTC | #2

[quote="b10c, post:1, topic:75"]
it’s interesting to look at the pools that set their coinbase locktime to a non-zero value, which might reveal incompatibilities.

[/quote]

Recent usage of the nLockTime field is by MARA and f2pool (as your graph shows). They use(d) it to store metadata about jobs, to make sure [a disconnected miner can resubmit its shares upon reconnection](https://bitcoin.stackexchange.com/a/119370/101498). Following my email to the bitcoinminingdev list last year, MARA updated their software to use the coinbase’s nVersion in place of nLockTime. F2pool could do the same but my takeaway from personal exchanges with them is that they don’t want to bother until BIP 54 is further along the way toward activation. (Which, of course, is a nice catch-22 in itself.)

But as far as incompatibilities go, all pools are currently incompatible (modulo one recent change –see next post), and i am more concerned about the swarm of tiny pools that currently hardcode their nLockTime to 0, than about easily updated practices from a few more easily reachable big pools.

-------------------------

Antoine | 2026-02-23 22:31:18 UTC | #3

[Whitepool](https://mempool.space/mining/pool/whitepool), a small mining pool, just upgraded their coinbase transactions to be BIP 54 compatible! I think block [937,650](https://mempool.space/block/000000000000000000011f0830fb0e528d1a715655064dd311863200081e43b2) is the first ever BIP54-compatible block.

I think this is encouraging as far as getting smaller pools to upgrade goes, which was one of my main concerns with BIP 54.

I caught this thanks to your dashboard, thanks!

-------------------------

b10c | 2026-02-24 13:05:02 UTC | #4

There seem to be three blocks with valid BIP-54 coinbase locktimes at this point:

```bash
$ paste -d ' ' <(curl -s https://mainnet.observer/csv/date.csv) \
<(curl -s https://mainnet.observer/csv/coinbase_locktime_set_bip54_sum.csv) | tail
2026-02-15 0
2026-02-16 0
2026-02-17 0
2026-02-18 0
2026-02-19 1
2026-02-20 0
2026-02-21 1
2026-02-22 1
2026-02-23 0
2026-02-24 0
```

```SQL
SELECT height FROM block_stats WHERE coinbase_locktime_set_bip54 > 0 ORDER BY height;

937404
937650
937744
```

So 937404 is actually the first one!

-------------------------

b10c | 2026-02-26 20:14:44 UTC | #5

https://mainnet.observer/charts/mining-pools-mining-bip54-coinbase/ now shows a table with which pools mined a BIP-54 valid coinbase and when. Also, how many they mined in total.

![grafik|690x142](upload://cpamjVMblz2T4Qx3zQLLcQn96s9.png)

-------------------------

Antoine | 2026-03-13 13:58:27 UTC | #6

Turns out some unknown miners have also enabled BIP 54 forward compat: https://mempool.space/block/00000000000000000001dcaf7e23ceac78d61587fc4e49def8c1896829a3b0e6.

Should those be counted as “unknown” in the latest dashboard?

-------------------------

Antoine | 2026-03-16 15:41:33 UTC | #7

Looks like the [dashboard](https://mainnet.observer/charts/mining-pools-mining-bip54-coinbase/) did catch it, though it labels the unknown pool “0”.

-------------------------

b10c | 2026-03-23 10:40:30 UTC | #8

Thanks for the report. Fixing this in:

https://github.com/0xB10C/mainnet-observer/pull/151

Should be live in a few days.

-------------------------

Antoine | 2026-04-27 16:59:17 UTC | #9

Ckpool is [now compatible](https://bitbucket.org/ckolivas/ckpool/pull-requests/25). I mined a few BIP 54 compatible blocks using ckpool on testnet4 for demonstration purposes. See for instance [`0000000000000001b407639fb982f00bc5dff36dc4bc436e6118e99042b2965f`](https://mempool.space/testnet4/block/0000000000000001b407639fb982f00bc5dff36dc4bc436e6118e99042b2965f).

-------------------------

Antoine | 2026-05-21 15:17:02 UTC | #10

ViaBTC has also been compatible for a week, although they do this weird partial upgrade: only some of their blocks are compatible, probably because they run multiple instances with different versions of the pool software.

-------------------------

b10c | 2026-06-10 09:56:36 UTC | #11

Seems like Foundry is now compatible since block 952880 (2026-06-08)!

https://mainnet.observer/charts/mining-pools-mining-bip54-coinbase/

-------------------------

