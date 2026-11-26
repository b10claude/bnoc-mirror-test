# Slowish blocks on Signet

Antoine | 2026-03-26 19:04:52 UTC | #1

BIP 54 was [activated on Inquisition](https://gnusha.org/pi/bitcoindev/wJZkcSEOQD5Z8rsel8TJCSkUJiwn7YepjyOfSDHKt3P_4Fvh9MFu_oiva3G6C-Q_1CmRTCj6lqmVm6ZeZG8WbdVrCo4IZUFg3VazRdJ48AQ=@protonmail.com/) at the beginning of the month. BIP 54 introduces a mitigation for blocks that are slow to validate. @ajtowns and i figured it would be interesting to run some slow blocks on Signet.

The goal is to showcase some slow blocks on a public network, without disclosing the worst case(s). I crafted 6 transactions that take a higher-than-normal amount of time on most hardware \[0\] but does not reveal some of the tricks that can be used to increase validation time by another factor \~150x.

Those blocks would be accepted by Bitcoin Core Signet, but rejected by Bitcoin Inquisition Signet. So the plan would be for @ajtowns to mine a streak of 6 slowish blocks, and then reorg them out. This would let anyone running a Signet node today witness those slow blocks, without imposing a Signet IBD cost forever.

I’m creating this thread to coordinate and share observations.

---

\[0\]: 4 seconds each on a high end machine, about 25 seconds on a mid-range server and over 70 seconds on a RPi 4B.

-------------------------

b10c | 2026-03-27 14:39:21 UTC | #2

I've set up a (temporary) signet peer-observer instance for this: https://signet.peer.observer/. I'm running a Bitcoin Core `v31.0rc1` (node01) node and an Inquisition `v29.2` (which has BIP-54 merged) node (node02). 

I'll post a few links here to watch during and after the event:

- https://signet.peer.observer/forks/ should show the `v31.0rc1` node processing (albeit slowly), and the `Inquisition v29.2` BIP-54 node rejecting the blocks.
- https://signet.peer.observer/debug-logs/ has detailed debug - once they rotate (UTC midnight)
- https://signet.peer.observer/monitoring/d/bdgc3bcjec268b/validation-block-connection-time shows validation time of blocks

Both nodes are running on the same host. The host has access to 8 shared AMD EPYC-Rome (2019) cores. I guess that makes it something between high-end and mid-range.

-------------------------

Emzy | 2026-03-26 20:56:24 UTC | #3

I have two signet nodes. One is v30.2 and the other v30.1.
The v30.2 can be observed here: https://mempool.emzy.de/signet

-------------------------

ajtowns | 2026-03-27 05:19:02 UTC | #4

[quote="Antoine, post:1, topic:100"]
So the plan would be for @ajtowns to mine a streak of 6 slowish blocks,
[/quote]

I'll aim to fire this off at around 1300 UTC, so ~8 hours away from now.

Plan is:
 * mine a few normal blocks with nTime in the future so that inquisition miners defer creating new blocks and engaging in a race with the attack blocks
 * mine the six attack blocks in a row, allowing them to propagate
 * call invalidateblock on the first attack block, and restart my inquisition miner to eventually produce a more-work chain than the attack blocks

I expect mining the attack blocks will take ~10 minutes, and presumably propagation across the signet network will be somewhat slow (due to no compact block benefit, slow validation, and inquisition 29.2 nodes rejecting the block). There's also a chance the network will partition somewhat, with inquisition 29.2 nodes disconnecting from peers that advertise child blocks built on the earlier attack blocks that inq nodes have already rejected.

Presumably it will take about an hour for the attack blocks to be reorged out (ie, for the inquistion miners to mine 7 blocks).

-------------------------

b10c | 2026-03-27 14:10:55 UTC | #5

[date=2026-03-27 time=14:12:00 timezone=Europe/Amsterdam]

I have an invalid block on the Inquisition v29.2 node
![grafik|690x483](upload://7Q1qcgsLAjsdrdFz5sORIL3S5RS.png)

[date=2026-03-27 time=14:16:00 timezone=Europe/Amsterdam]

The Bitcoin Core `v31.0rc1` node is struggeling a bit to validate the blocks. This one took just over a minute to validate: 
```
2026-03-27T13:15:04.958134Z [msghand] [validation] NewPoWValidBlock: block hash=00000002a129891c57504b01e855d29e8e4debc90a12eb092a1afe83e87b13f0
2026-03-27T13:15:05.065694Z [msghand] [bench]   - Using cached block
2026-03-27T13:15:05.065762Z [msghand] [bench]   - Load block from disk: 0.07ms
2026-03-27T13:15:05.065799Z [msghand] [bench]     - Sanity checks: 0.01ms [265.15s (3.88ms/blk)]
2026-03-27T13:15:06.576035Z [msghand] [bench]     - Fork checks: 1510.20ms [1861.31s (27.25ms/blk)]
2026-03-27T13:15:06.872661Z [msghand] [bench]       - Connect 2 transactions: 296.57ms (148.283ms/tx, 0.740ms/txin) [1386.22s (20.30ms/blk)]
2026-03-27T13:16:07.083804Z [msghand] [bench]     - Verify 401 txins: 60507.74ms (150.892ms/txin) [1713.90s (25.10ms/blk)]
2026-03-27T13:16:07.086961Z [msghand] [bench]     - Write undo data: 3.19ms [264.62s (3.87ms/blk)]
2026-03-27T13:16:07.087026Z [msghand] [bench]     - Index writing: 0.10ms [4.90s (0.07ms/blk)]
2026-03-27T13:16:07.087160Z [msghand] [validation] BlockChecked: block hash=00000002a129891c57504b01e855d29e8e4debc90a12eb092a1afe83e87b13f0 state=Valid
2026-03-27T13:16:07.087338Z [msghand] [bench]   - Connect total: 62021.57ms [4136.42s (60.57ms/blk)]
2026-03-27T13:16:08.492142Z [msghand] [bench]   - Flush: 1404.78ms [657.15s (9.62ms/blk)]
2026-03-27T13:16:08.492301Z [msghand] [bench]   - Writing chainstate: 0.20ms [232.19s (3.40ms/blk)]
2026-03-27T13:16:08.492732Z [msghand] [validation] Enqueuing MempoolTransactionsRemovedForBlock: block height=297391 txs removed=0
2026-03-27T13:16:08.492886Z [msghand] UpdateTip: new best=00000002a129891c57504b01e855d29e8e4debc90a12eb092a1afe83e87b13f0 height=297391 version=0x20000000 log2_work=43.591733 tx=28983815 date='2026-03-27T13:13:52
Z' progress=1.000000 cache=206.2MiB(1504269txo)
2026-03-27T13:16:08.492902Z [msghand] [bench]   - Connect postprocess: 0.60ms [17.39s (0.25ms/blk)]
2026-03-27T13:16:08.492914Z [msghand] [bench] - Connect block: 63427.23ms [5623.64s (82.35ms/blk)]
2026-03-27T13:16:08.492965Z [msghand] [validation] Enqueuing BlockConnected: block hash=00000002a129891c57504b01e855d29e8e4debc90a12eb092a1afe83e87b13f0 block height=297391
2026-03-27T13:16:08.492999Z [msghand] [validation] Enqueuing UpdatedBlockTip: new block hash=00000002a129891c57504b01e855d29e8e4debc90a12eb092a1afe83e87b13f0 fork block hash=00000007326c42ef17ee090f758ba328954f243
13648dc0971b7b33b165427e7 (in IBD=false)
2026-03-27T13:16:08.493081Z [msghand] [validation] ActiveTipChange: new block hash=00000002a129891c57504b01e855d29e8e4debc90a12eb092a1afe83e87b13f0 block height=297391
2026-03-27T13:16:08.765151Z [scheduler] [validation] MempoolTransactionsRemovedForBlock: block height=297391 txs removed=0
2026-03-27T13:16:08.765756Z [scheduler] [validation] BlockConnected: block hash=00000002a129891c57504b01e855d29e8e4debc90a12eb092a1afe83e87b13f0 block height=297391
2026-03-27T13:16:08.766254Z [scheduler] [validation] UpdatedBlockTip: new block hash=00000002a129891c57504b01e855d29e8e4debc90a12eb092a1afe83e87b13f0 fork block hash=00000007326c42ef17ee090f758ba328954f24313648dc0
971b7b33b165427e7 (in IBD=false)
```


[date=2026-03-27 time=14:22:00 timezone=Europe/Amsterdam]

The Bitcoin Core node is now at 297392, while the Inquisition one is still at 297387.

![grafik|690x367](upload://gamrVX3nr7OgcUr5wk7k4lPSGRn.png)


[date=2026-03-27 time=14:26:00 timezone=Europe/Amsterdam]

We have started to reorg.

![grafik|690x416](upload://99XYCt3LhsGWog2TA1bIpvEVCx2.png)

[date=2026-03-27 time=15:03:00 timezone=Europe/Amsterdam]

We are about to reorg.

![grafik|690x349](upload://nByOQrOQBiBhdExnrwOvQ7Zbh80.png)


[date=2026-03-27 time=15:10:00 timezone=Europe/Amsterdam]

And we have reorged. 

![grafik|690x440](upload://7gx8WqC15SHI7S1wetVhuAd7tFj.png)

-------------------------

ajtowns | 2026-03-27 13:36:05 UTC | #6

[quote="b10c, post:5, topic:100"]
We have started to reorg.
[/quote]

After mining the big blocks, I lost connectivity to inq 29.2 nodes, so the new bip54 / inq 29.2 compliant chain wasn't actually leaving the miner. Fixed by manually running invalidateblock on the `inquisition.bitcoin-signet.net` node (which is still running inq 29.1). Otherwise it seemed like things performed as expected.

-------------------------

ajtowns | 2026-03-27 13:45:17 UTC | #7

Node running on the cheapest local VPS I could find took about 5m to connect each block, fwiw:

```
2026-03-27T13:15:59.142042Z UpdateTip: new best=00000000d9338f3251ebb0dc01afebf34b38a2bafaf1376ef9e26e02eadb0c64 height=297387 version=0x20000000 log2_work=43.591646 tx=28983807 date='2026-03-27T13:08:33Z' progress=0.999984 cache=431.5MiB(3044011txo)
2026-03-27T13:21:48.662514Z UpdateTip: new best=00000006048ed6cfedbc6249c5eb82616a4a90cb35c76127af7a40e3198736e1 height=297388 version=0x20000000 log2_work=43.591668 tx=28983809 date='2026-03-27T13:10:22Z' progress=0.999975 cache=442.7MiB(3142307txo)
2026-03-27T13:26:47.108278Z UpdateTip: new best=00000013fb4596b358dd07ede7ef18c57a64e4a6fc0b33944bb86b91f0e74b32 height=297389 version=0x20000000 log2_work=43.591690 tx=28983811 date='2026-03-27T13:11:18Z' progress=0.999966 cache=454.0MiB(3240603txo)
2026-03-27T13:31:38.528283Z UpdateTip: new best=00000007326c42ef17ee090f758ba328954f24313648dc0971b7b33b165427e7 height=297390 version=0x20000000 log2_work=43.591711 tx=28983813 date='2026-03-27T13:12:16Z' progress=0.999957 cache=465.2MiB(3338899txo)
2026-03-27T13:36:34.312286Z UpdateTip: new best=00000002a129891c57504b01e855d29e8e4debc90a12eb092a1afe83e87b13f0 height=297391 version=0x20000000 log2_work=43.591733 tx=28983815 date='2026-03-27T13:13:52Z' progress=0.999950 cache=476.5MiB(3437195txo)
2026-03-27T13:41:14.166092Z UpdateTip: new best=0000000cd04ef18d4a43fa7fc093b8c3a6d29685d899f29e20373bfd04bab78d height=297392 version=0x20000000 log2_work=43.591755 tx=28983817 date='2026-03-27T13:14:45Z' progress=0.999942 cache=487.7MiB(3535491txo)
```

-------------------------

Antoine | 2026-03-27 14:25:00 UTC | #8

On my non-publicly-reachable node running from New York, i received slowish blocks 297387 through 297392 at (UTC) 13:10:33, 13:11:27, 13:12:24, 13:14:00, 13:14:53 and 13:15:41. They all came from the same peer. The first one via simple header announcement, the five others through compact blocks.

-------------------------

b10c | 2026-03-27 14:30:36 UTC | #9

The full debug logs of my nodes are here (for a while):

- https://signet.peer.observer/debug-logs/node01/debug-node01-Core-v31.0rc1.log.gz
- https://signet.peer.observer/debug-logs/node02/debug-node02-Inquisition-v29.2.log.gz

From the Bitcoin Core node it took about a minute to validate the blocks. With most time being spend in `Verify 401 txins: 63155.40ms`.

```
2026-03-27T13:13:59.106635Z [msghand] [validation] NewPoWValidBlock: block hash=00000007326c42ef17ee090f758ba328954f24313648dc0971b7b33b165427e7
2026-03-27T13:13:59.171443Z [msghand] [bench]   - Using cached block
2026-03-27T13:13:59.171495Z [msghand] [bench]   - Load block from disk: 0.06ms
2026-03-27T13:13:59.171520Z [msghand] [bench]     - Sanity checks: 0.01ms [265.15s (3.88ms/blk)]
2026-03-27T13:14:00.293176Z [msghand] [bench]     - Fork checks: 1121.62ms [1859.79s (27.23ms/blk)]
2026-03-27T13:14:00.519708Z [msghand] [bench]       - Connect 2 transactions: 226.51ms (113.257ms/tx, 0.565ms/txin) [1385.93s (20.29ms/blk)]
2026-03-27T13:15:03.448621Z [msghand] [bench]     - Verify 401 txins: 63155.40ms (157.495ms/txin) [1653.39s (24.21ms/blk)]
2026-03-27T13:15:03.450535Z [msghand] [bench]     - Write undo data: 1.98ms [264.62s (3.87ms/blk)]
2026-03-27T13:15:03.450571Z [msghand] [bench]     - Index writing: 0.05ms [4.90s (0.07ms/blk)]
2026-03-27T13:15:03.450691Z [msghand] [validation] BlockChecked: block hash=00000007326c42ef17ee090f758ba328954f24313648dc0971b7b33b165427e7 state=Valid
2026-03-27T13:15:03.450783Z [msghand] [bench]   - Connect total: 64279.29ms [4074.40s (59.66ms/blk)]
2026-03-27T13:15:03.786971Z [msghand] [bench]   - Flush: 336.14ms [655.74s (9.60ms/blk)]
2026-03-27T13:15:03.787159Z [msghand] [bench]   - Writing chainstate: 0.23ms [232.19s (3.40ms/blk)]
2026-03-27T13:15:03.787784Z [msghand] [validation] Enqueuing MempoolTransactionsRemovedForBlock: block height=297390 txs removed=0
2026-03-27T13:15:03.788007Z [msghand] [bench]   - Connect postprocess: 0.85ms [17.39s (0.25ms/blk)]
2026-03-27T13:15:03.788025Z [msghand] [bench] - Connect block: 64616.58ms [5560.21s (81.42ms/blk)]
2026-03-27T13:15:03.788089Z [msghand] [validation] Enqueuing BlockConnected: block hash=00000007326c42ef17ee090f758ba328954f24313648dc0971b7b33b165427e7 block height=297390
2026-03-27T13:15:03.788140Z [msghand] [validation] Enqueuing UpdatedBlockTip: new block hash=00000007326c42ef17ee090f758ba328954f24313648dc0971b7b33b165427e7 fork block hash=00000013fb4596b358dd07ede7ef18c57a64e4a6fc0b33944bb86b91f0e74b32 (in IBD=false)
2026-03-27T13:15:03.788206Z [msghand] [validation] ActiveTipChange: new block hash=00000007326c42ef17ee090f758ba328954f24313648dc0971b7b33b165427e7 block height=297390
```

-------------------------

b10c | 2026-03-27 14:39:10 UTC | #10

The median ping time to the Bitcoin Core node spiked:

![grafik|690x364](upload://gaIBnba2T67uyPro4apekf87DIR.png)

And the block connection time of the Bitcoin Core node shows a similar story to the logs:

![grafik|690x336](upload://5S0v8XDHGs8rTM09RhgERy4AWcC.png)

RAM usage remained flat, but CPU spiked:

![grafik|429x500](upload://p4El4Yc5g35Wh2cigeFcMIk4hGP.png)

-------------------------

Emzy | 2026-03-27 15:15:44 UTC | #11

CPU: 6 cores Intel(R) Core(TM) i7-8700 CPU @ 3.20GHz - 64GB RAM - Bitcoin v30.1:
```
2026-03-27T13:10:40Z UpdateTip: new best=00000000d9338f3251ebb0dc01afebf34b38a2bafaf1376ef9e26e02eadb0c64 height=297387 version=0x20000000 log2_work=43.591646 tx=28983807 date='2026-03-27T13:08:33Z' progress=1.000000 cache=86.5MiB(662567txo)
2026-03-27T13:11:35Z UpdateTip: new best=00000006048ed6cfedbc6249c5eb82616a4a90cb35c76127af7a40e3198736e1 height=297388 version=0x20000000 log2_work=43.591668 tx=28983809 date='2026-03-27T13:10:22Z' progress=1.000000 cache=104.1MiB(760863txo)
2026-03-27T13:12:32Z UpdateTip: new best=00000013fb4596b358dd07ede7ef18c57a64e4a6fc0b33944bb86b91f0e74b32 height=297389 version=0x20000000 log2_work=43.591690 tx=28983811 date='2026-03-27T13:11:18Z' progress=1.000000 cache=116.1MiB(859159txo)
2026-03-27T13:14:08Z UpdateTip: new best=00000007326c42ef17ee090f758ba328954f24313648dc0971b7b33b165427e7 height=297390 version=0x20000000 log2_work=43.591711 tx=28983813 date='2026-03-27T13:12:16Z' progress=1.000000 cache=128.1MiB(957455txo)
2026-03-27T13:15:04Z UpdateTip: new best=00000002a129891c57504b01e855d29e8e4debc90a12eb092a1afe83e87b13f0 height=297391 version=0x20000000 log2_work=43.591733 tx=28983815 date='2026-03-27T13:13:52Z' progress=1.000000 cache=140.1MiB(1055751txo)
2026-03-27T13:15:51Z UpdateTip: new best=0000000cd04ef18d4a43fa7fc093b8c3a6d29685d899f29e20373bfd04bab78d height=297392 version=0x20000000 log2_work=43.591755 tx=28983817 date='2026-03-27T13:14:45Z' progress=1.000000 cache=152.1MiB(1154047txo)
```

CPU: 24 cores 12th Gen Intel i9-12900K (24) @ 5.100GHz - 128GB RAM - Bitcoin v30.2:
```
2026-03-27T13:10:38.321078Z UpdateTip: new best=00000000d9338f3251ebb0dc01afebf34b38a2bafaf1376ef9e26e02eadb0c64 height=297387 version=0x20000000 log2_work=43.591646 tx=28983807 date='2026-03-27T13:08:33Z' progress=1.000000 cache=13.6MiB(98716txo)
2026-03-27T13:11:27.837353Z UpdateTip: new best=00000006048ed6cfedbc6249c5eb82616a4a90cb35c76127af7a40e3198736e1 height=297388 version=0x20000000 log2_work=43.591668 tx=28983809 date='2026-03-27T13:10:22Z' progress=1.000000 cache=26.9MiB(197413txo)
2026-03-27T13:12:25.332805Z UpdateTip: new best=00000013fb4596b358dd07ede7ef18c57a64e4a6fc0b33944bb86b91f0e74b32 height=297389 version=0x20000000 log2_work=43.591690 tx=28983811 date='2026-03-27T13:11:18Z' progress=1.000000 cache=38.9MiB(296110txo)
2026-03-27T13:14:01.145243Z UpdateTip: new best=00000007326c42ef17ee090f758ba328954f24313648dc0971b7b33b165427e7 height=297390 version=0x20000000 log2_work=43.591711 tx=28983813 date='2026-03-27T13:12:16Z' progress=1.000000 cache=53.7MiB(394807txo)
2026-03-27T13:14:54.316139Z UpdateTip: new best=00000002a129891c57504b01e855d29e8e4debc90a12eb092a1afe83e87b13f0 height=297391 version=0x20000000 log2_work=43.591733 tx=28983815 date='2026-03-27T13:13:52Z' progress=1.000000 cache=65.7MiB(493505txo)
2026-03-27T13:15:43.205182Z UpdateTip: new best=0000000cd04ef18d4a43fa7fc093b8c3a6d29685d899f29e20373bfd04bab78d height=297392 version=0x20000000 log2_work=43.591755 tx=28983817 date='2026-03-27T13:14:45Z' progress=1.000000 cache=78.0MiB(592202txo)
```

Mempool-Space video from 24 cores 12th Gen Intel i9-12900K server:
https://x.com/emzy/status/2037545385036509488

Also saw a load spike on the 6 cores Intel(R) Core(TM) i7-8700 CPU:
![load-pinpoint=1774569329,1774622249|690x384](upload://lFNycncjOpyndjbMDW49LWZFrN3.png)

-------------------------

Antoine | 2026-03-27 15:36:20 UTC | #12

The same inputs that were used to create the reorged-out attack blocks have now been swept in BIP54-compliant transactions. To be BIP54-compliant they had to be split up into multiple transactions. The rule has been designed this way to still make it possible to spend any coin, only not do so in a way that exacerbates quadratic behaviour in validation.

The transactions were swept in blocks [`0000000397510798d759ef2454ada5b3ef56116bd70bcddc66d6103e6d30b32a`](https://mempool.emzy.de/signet/block/0000000397510798d759ef2454ada5b3ef56116bd70bcddc66d6103e6d30b32a), [`000000095d46e25212b74909d83ebb181b8a751be9e0931a348bb192b187cce9`](https://mempool.emzy.de/signet/block/000000095d46e25212b74909d83ebb181b8a751be9e0931a348bb192b187cce9), [`00000007173a71f8e605e9396e3a96a2bd2c736f95112c333dd8680a0f1d3f86`](https://mempool.emzy.de/signet/block/00000007173a71f8e605e9396e3a96a2bd2c736f95112c333dd8680a0f1d3f86), [`0000000e494e65bcb3ec2646a0fcd2887216bb3a9280742e6c3d161e5da9c7cc`](https://mempool.emzy.de/signet/block/0000000e494e65bcb3ec2646a0fcd2887216bb3a9280742e6c3d161e5da9c7cc), [`0000000fd5be05c3021c66bc52c4d379441517cfa0df92e52dd6358330fc99a8`](https://mempool.emzy.de/signet/block/0000000fd5be05c3021c66bc52c4d379441517cfa0df92e52dd6358330fc99a8), and [`000000013a17736f4fbf34074b066641580831e8fc1ca1076e6825cb2bd3cce4`](https://mempool.emzy.de/signet/block/000000013a17736f4fbf34074b066641580831e8fc1ca1076e6825cb2bd3cce4). They can be identified by the single `OP_RETURN` output they burn the inputs to, with the message “BIP54”.

As you can see for yourself, those blocks spend the same inputs as the blocks that were reorged out, but are significantly lighter to validate.

-------------------------

Antoine | 2026-03-27 16:58:19 UTC | #13

[quote="b10c, post:9, topic:100"]
The full debug logs of my nodes are here (for a while):

* https://signet.peer.observer/debug-logs/node01/debug-node01-Core-v31.0rc1.log.gz
* https://signet.peer.observer/debug-logs/node02/debug-node02-Inquisition-v29.2.log.gz

[/quote]

The compact blocks dynamic in the presence of a slowish block is interesting here. For instance take the first block. It was first announced to you by peer 8:

```
2026-03-27T13:10:26.039635Z [msghand] Saw new cmpctblock header hash=00000000d9338f3251ebb0dc01afebf34b38a2bafaf1376ef9e26e02eadb0c64 height=297387 peer=8 peeraddr=35.217.13.118:38333
```

But when you asked this peer about the missing block transaction:

```
2026-03-27T13:10:26.044783Z [msghand] [net] sending getblocktxn (34 bytes) peer=8
```

It was unable to reply to you for a while, presumably because it was still validating the block. Its reply came much later:

```
2026-03-27T13:11:38.266321Z [msghand] [net] received: blocktxn (999590 bytes) peer=8
```

But meanwhile your node also received the block from peer 6, asked it for the block content and it was faster to reply:

```
2026-03-27T13:10:34.197281Z [msghand] [net] received: cmpctblock (358 bytes) peer=6
...
2026-03-27T13:10:34.198177Z [msghand] [net] sending getblocktxn (34 bytes) peer=6
...
2026-03-27T13:10:36.108428Z [msghand] [net] received: blocktxn (999590 bytes) peer=6
```

---

Same for the second block, where it was first announced by your non-HB peer 9:

```
2026-03-27T13:11:38.667001Z [msghand] Saw new header hash=00000006048ed6cfedbc6249c5eb82616a4a90cb35c76127af7a40e3198736e1 height=297388 peer=9 peeraddr=49.13.117.253:38333
2026-03-27T13:11:38.667055Z [msghand] [net] Requesting block 00000006048ed6cfedbc6249c5eb82616a4a90cb35c76127af7a40e3198736e1 from  peer=9
```

Whom you asked for transactions to reconstruct the compact block it sent you:

```
2026-03-27T13:11:38.676032Z [msghand] [net] received: cmpctblock (358 bytes) peer=9
...
2026-03-27T13:11:38.676914Z [msghand] [net] sending getblocktxn (34 bytes) peer=9
```

And it only replied to you over a minute later:

```
2026-03-27T13:12:41.889462Z [msghand] [net] received: blocktxn (999590 bytes) peer=9
```

But you had also received it from peers 6 and 8:

```
2026-03-27T13:11:38.668539Z [msghand] [net] received: cmpctblock (358 bytes) peer=6
...
2026-03-27T13:11:38.669192Z [msghand] [net] sending getblocktxn (34 bytes) peer=6
...
2026-03-27T13:11:38.669849Z [msghand] [net] received: cmpctblock (358 bytes) peer=8
...
2026-03-27T13:11:38.670348Z [msghand] [net] sending getblocktxn (34 bytes) peer=8

```

And peer 6 was once again the fastest to reply:

```
2026-03-27T13:11:38.737880Z [msghand] [net] received: blocktxn (999590 bytes) peer=6
...
2026-03-27T13:12:42.285702Z [msghand] [net] received: blocktxn (999590 bytes) peer=8
```

---

So i guess the takeaway from this is that you were lucky to have a peer running on a beefy machine that was able to validate the slowish blocks in a matter of seconds before serving them to you, otherwise you would have been stalled waiting for your peers to finish validating it, and then stalled again validating it yourself.

-------------------------

b10c | 2026-03-27 22:04:08 UTC | #14

[quote="Antoine, post:13, topic:100"]
a peer running on a beefy machine
[/quote]

I wondering how someone can verify a block in 2 seconds where e.g. emzy's fast machine still takes tens of seconds..

The IP suggests it's a Hetzner box, maybe a very fast one.

-------------------------

ajtowns | 2026-03-29 02:57:10 UTC | #15

For anyone who missed out, the reorged-out blocks are available here https://github.com/ajtowns/stale-blocks-signet/tree/master/blocks

-------------------------

Antoine | 2026-03-30 14:13:41 UTC | #16

Verification time is highly dependent on some CPU optimizations. I have beefy workstation here that takes under 2 seconds to validate it. My modern laptop takes about 4 seconds.

Given the specs Emzy gave for his servers, i would be very surprised if validation took over a handful of seconds for him. Where did you get the tens of seconds figure from?

-------------------------

b10c | 2026-03-30 14:22:31 UTC | #17

[quote="Antoine, post:16, topic:100"]
Where did you get the tens of seconds figure from?
[/quote]


[quote="Emzy, post:11, topic:100"]
CPU: 24 cores 12th Gen Intel i9-12900K (24) @ 5.100GHz - 128GB RAM - Bitcoin v30.2:

```
2026-03-27T13:10:38.321078Z UpdateTip: new best=00000000d9338f3251ebb0dc01afebf34b38a2bafaf1376ef9e26e02eadb0c64 height=297387 version=0x20000000 log2_work=43.591646 tx=28983807 date='2026-03-27T13:08:33Z' progress=1.000000 cache=13.6MiB(98716txo)
2026-03-27T13:11:27.837353Z UpdateTip: new best=00000006048ed6cfedbc6249c5eb82616a4a90cb35c76127af7a40e3198736e1 height=297388 version=0x20000000 log2_work=43.591668 tx=28983809 date='2026-03-27T13:10:22Z' progress=1.000000 cache=26.9MiB(197413txo)
2026-03-27T13:12:25.332805Z UpdateTip: new best=00000013fb4596b358dd07ede7ef18c57a64e4a6fc0b33944bb86b91f0e74b32 height=297389 version=0x20000000 log2_work=43.591690 tx=28983811 date='2026-03-27T13:11:18Z' progress=1.000000 cache=38.9MiB(296110txo)
2026-03-27T13:14:01.145243Z UpdateTip: new best=00000007326c42ef17ee090f758ba328954f24313648dc0971b7b33b165427e7 height=297390 version=0x20000000 log2_work=43.591711 tx=28983813 date='2026-03-27T13:12:16Z' progress=1.000000 cache=53.7MiB(394807txo)
2026-03-27T13:14:54.316139Z UpdateTip: new best=00000002a129891c57504b01e855d29e8e4debc90a12eb092a1afe83e87b13f0 height=297391 version=0x20000000 log2_work=43.591733 tx=28983815 date='2026-03-27T13:13:52Z' progress=1.000000 cache=65.7MiB(493505txo)
2026-03-27T13:15:43.205182Z UpdateTip: new best=0000000cd04ef18d4a43fa7fc093b8c3a6d29685d899f29e20373bfd04bab78d height=297392 version=0x20000000 log2_work=43.591755 tx=28983817 date='2026-03-27T13:14:45Z' progress=1.000000 cache=78.0MiB(592202txo)
```
[/quote]

I was looking at the difference between these timestamps, but you are right, we don't actually know when the block was received and how long the validation took.

-------------------------

davidgumberg | 2026-04-01 17:28:57 UTC | #18

Have not done any analysis yet, but these are logs from 297380 until 297450 running on a container on a relatively powerful server with `debug=net` and `debug=bench` enabled:

https://gist.github.com/davidgumberg/1b52f92c74e078c3a295d69b7bccedfd

-------------------------

b10c | 2026-04-01 21:12:35 UTC | #19

Looking at the one I posted about in https://bnoc.xyz/t/slowish-blocks-on-signet/100/9:

```
2026-03-27T13:14:23.281615Z [bench]   - Using cached block
2026-03-27T13:14:23.281765Z [bench]   - Load block from disk: 0.08ms
2026-03-27T13:14:23.281879Z [bench]     - Sanity checks: 0.04ms [0.00s (0.01ms/blk)]
2026-03-27T13:14:24.030233Z [bench]     - Fork checks: 748.28ms [2.68s (32.67ms/blk)]
2026-03-27T13:14:24.190088Z [bench]       - Connect 2 transactions: 159.71ms (79.857ms/tx, 0.398ms/txin) [0.59s (7.23ms/blk)]
2026-03-27T13:14:31.862081Z [bench]     - Verify 401 txins: 7831.68ms (19.530ms/txin) [29.78s (363.21ms/blk)]
2026-03-27T13:14:31.864113Z [bench]     - Write undo data: 2.28ms [0.07s (0.88ms/blk)]
2026-03-27T13:14:31.864158Z [bench]     - Index writing: 0.05ms [0.01s (0.07ms/blk)]
2026-03-27T13:14:31.864224Z [bench]   - Connect total: 8582.53ms [32.56s (397.03ms/blk)]
2026-03-27T13:14:32.239817Z [bench]   - Flush: 375.44ms [0.85s (10.31ms/blk)]
2026-03-27T13:14:32.239990Z [bench]   - Writing chainstate: 0.33ms [0.01s (0.08ms/blk)]
2026-03-27T13:14:32.240714Z UpdateTip: new best=00000007326c42ef17ee090f758ba328954f24313648dc0971b7b33b165427e7 height=297390 version=0x20000000 log2_work=43.591711 tx=28983813 date='2026-03-27T13:12:16Z' progress=1.000000 cache=60.0MiB(446041txo)
2026-03-27T13:14:32.240799Z [bench]   - Connect postprocess: 0.80ms [2.85s (34.78ms/blk)]
2026-03-27T13:14:32.240851Z [bench] - Connect block: 8959.18ms [36.27s (442.29ms/blk)]
```

I took you `Verify 401 txins: 7831.68ms` vs me `Verify 401 txins: 63155.40ms`.

-------------------------

b10c | 2026-04-13 09:59:53 UTC | #20

Note that there were three more runs of this: https://delvingbitcoin.org/t/consensus-cleanup-demo-of-slow-blocks-on-signet/2367/

-------------------------

