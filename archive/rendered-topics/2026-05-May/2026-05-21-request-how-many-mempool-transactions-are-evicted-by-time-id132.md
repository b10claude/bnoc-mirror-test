# Request: How many mempool transactions are evicted by time?

rustaceanrob | 2026-05-24 11:47:18 UTC | #1

Sadeeq raised a [potential issue](https://github.com/bitcoin/bitcoin/issues/33510) with time-based expiry of mempool transactions whereby a transaction that is likely to be mined in the next block could be evicted. David responded with a great history of time-based mempool expiry. After reading the thread, I’m not particularly convinced we need to index by time, but I would like to know how many transactions are expired due to the default timeout of 2 weeks.

I came across this issue when researching what it would take to remove the boost multi-index from Bitcoin Core dependencies. No matter the approach, removing time as a key would greatly simplify the patch-set. 

This is probably derivable from the other data offers, but I thought I would post this for discussion anyway.

-------------------------

b10c | 2026-05-21 11:35:20 UTC | #2

I have logs since early 2024 from multiple nodes that include `[validation] TransactionRemovedFromMempool: txid=xyz wtxid=abc reason=expiry`.

I might also have backups of mempool-observer databases that include this. I would need to check - it's been a while since I worked with them.

Would a graph with time-based evictions per day be helpful? Do you need raw data?

-------------------------

rustaceanrob | 2026-05-21 13:19:07 UTC | #3

I think a graph would be great! I am just trying to get a gut-feel for how often this may occur.

-------------------------

b10c | 2026-05-28 14:04:34 UTC | #4

I noticed that we log two lines for each expiring transaction, so just grepping for a `reason=expiry` will yield two log entries for each transaction that expires.

```
[validation] Enqueuing TransactionRemovedFromMempool ... reason=expiry
[validation] TransactionRemovedFromMempool ... reason=expiry
```

While analyzing the data, it took me a while to find something that conveys what I'm seeing: The upper part shows the average number of expiries per day on the nodes that saw at least one expiry on that day. This is usually somewhere between 10 and 10k. There are also days without any expiries. This is shown in the bottom part of the chart: when it reaches 100%, all nodes didn't see an expiry.

![image|601x500](upload://gr8GJtOPYGWNULKkE7BMS5STiza.png)
 

I was surprised to see only very few days between 2025-02-01 and 2025-09-15 with expires. I see the other obvious mempool removal reasons on these dates (`block`, `conflict`, ...) but no `reason=expiry`.

-------------------------

b10c | 2026-05-28 14:57:52 UTC | #5

The most transaction expires per day in my data, with roughly 57k expired, happened on 2025-09-30. These expired in two batches:

1. a smaller batch at around 8:00 am UTC
2. a larger batch at around 11:00 am UTC

![image|690x342](upload://erGVAbz4WFo150gYcwYawrADfKG.png)

I manually looked up some of the txids of the two batches:

1. small batch at 8am
- [283010443254facdf72e7e3445e45ea608d06105950213925b4c025766983d1e](https://mempool.space/tx/283010443254facdf72e7e3445e45ea608d06105950213925b4c025766983d1e)
- [638a0d23a145f989c6bdeb8aaefe1cf05e2007c592d958317e5457b8a9b1b3fc](https://mempool.space/tx/638a0d23a145f989c6bdeb8aaefe1cf05e2007c592d958317e5457b8a9b1b3fc)
- [8aae8b644ba485e128afe65c4284b849862711fe15ff00d878cd403153fab653](https://mempool.space/tx/8aae8b644ba485e128afe65c4284b849862711fe15ff00d878cd403153fab653)
- [20aeff4fee6ff3a8b11971bec0bff621308a6df15660f4126b83eee43069ac2b](https://mempool.space/tx/20aeff4fee6ff3a8b11971bec0bff621308a6df15660f4126b83eee43069ac2b)
2. larger batch 11am:
- [97c588cb4eb2d71a235aecd07afa53715d964c1a3dc34e8adf817b99ed63f1ed](https://mempool.space/tx/97c588cb4eb2d71a235aecd07afa53715d964c1a3dc34e8adf817b99ed63f1ed)
-  [a93fe961c4a0e7c4a0ca574a0c2f87ceef7347ae5c0b3797b256b23fdadf7b5c](https://mempool.space/tx/a93fe961c4a0e7c4a0ca574a0c2f87ceef7347ae5c0b3797b256b23fdadf7b5c)
- [dfcd93a9fde18f92fdb3ebd5d618ca3104b06005dbe91a4450e897527fb948e1](https://mempool.space/tx/dfcd93a9fde18f92fdb3ebd5d618ca3104b06005dbe91a4450e897527fb948e1)
- [9ad32067b6fd4059b72dc540deef39f8a6b21eadd4da7377ede43d62cc97652f](https://mempool.space/tx/9ad32067b6fd4059b72dc540deef39f8a6b21eadd4da7377ede43d62cc97652f)


For both batches, all transactions I looked at were eventually mined. So either someone rebroadcast them, or pools kept them around. The first batch transactions all seem to reveal an inscription and have a runestone OP_RETURN. The second batch all seem to have a OP_RETURN runestone, but don't reveal an inscription.

-------------------------

b10c | 2026-05-28 15:19:56 UTC | #6

I was wondering if these transactions were rebroadcast or if the miners still had them. We don't know for sure what the miners did, but grepping for the txids show that they all were re-added to my mempool on 2025-10-03.

1. small batch at 8am:
- 283010443254facdf72e7e3445e45ea608d06105950213925b4c025766983d1e: `2025-10-03T11:10:36.863086Z AcceptToMemoryPool`
- 638a0d23a145f989c6bdeb8aaefe1cf05e2007c592d958317e5457b8a9b1b3fc: `2025-10-03T11:19:04.324639Z AcceptToMemoryPool`
- 8aae8b644ba485e128afe65c4284b849862711fe15ff00d878cd403153fab653: `2025-10-03T11:40:55.635440Z AcceptToMemoryPool`
- 20aeff4fee6ff3a8b11971bec0bff621308a6df15660f4126b83eee43069ac2b: `2025-10-03T11:57:13.099842Z AcceptToMemoryPool`

2. larger batch 11am:
- 97c588cb4eb2d71a235aecd07afa53715d964c1a3dc34e8adf817b99ed63f1ed: `2025-10-03T11:45:05.443985Z AcceptToMemoryPool`
- a93fe961c4a0e7c4a0ca574a0c2f87ceef7347ae5c0b3797b256b23fdadf7b5c: `2025-10-03T11:47:00.555131Z AcceptToMemoryPool`
- dfcd93a9fde18f92fdb3ebd5d618ca3104b06005dbe91a4450e897527fb948e1: `2025-10-03T11:57:25.844020Z AcceptToMemoryPool`
- 9ad32067b6fd4059b72dc540deef39f8a6b21eadd4da7377ede43d62cc97652f: `2025-10-03T11:09:19.685492Z AcceptToMemoryPool`

-------------------------

rustaceanrob | 2026-06-03 08:45:20 UTC | #7

Thanks for the comprehensive research, certainly an interesting result. Given the example of the mass expiry with a big wave of rebroadcast, it seems the expiry mechanism is just adding marginal bandwidth use for no gain, as they were all eventually mined. I wonder if we can find examples of 1. a transaction is “expired,” was not seen in a later rebroadcast announcement, but was later mined, indicating miners are running a longer expiry. 2. a transaction was “expired” and was in fact replaced by adding/changing inputs. (1) is not possible to prove with certainty of course, but if a new tx announcement does not come up in a well-connected node’s logs and yet the (expired) tx was mined, I think we can have high confidence the default expiry was not used by miners. In investigating (1) if it was found that all transactions end up being re-broadcast, that would indicate to me that time isn’t doing much at all in practice.

-------------------------

b10c | 2026-06-05 14:41:48 UTC | #8

This sounds doable, but I can't promise I'll get to this anytime soon.

-------------------------

ismaelsadeeq | 2026-11-16 16:46:26 UTC | #9

Following up with some numbers. I took @b10c's reason=expiry extract and ran the whole set through a confirmation scan against an archival node. Across the full window (2024-02-16 to 2026-10-21, 938,157 of unique expired transactions):

- 92.0 percent (863,451) were later mined; only 8.0 percent (74,706) never confirmed.
- At least 34 percent (316,381) show rebroadcast evidence, and 87 percent of those confirmed.
- Of the ones that confirm, half are mined within about 5 days of first expiry and ninety percent within about 55 days, so there is a long tail that bounces for weeks before getting in.

![fig_outcome|690x252, 100%](upload://ww5zz8D3t3AHntbEbTMnxqlE6fr.png)

![fig_delay|690x306](upload://HjajJoZ5knIHv4BWX2vDwCDNJv.png)

Nearly everything time-based expiry evicts is mined anyway, alot of it after a rebroadcast. @rustaceanrob's indeed expiry causes unnecessary relay bandwidth.

![fig_rebroadcast|690x252](upload://gWE6051Vyk87m468aFXkeooJacH.png)

On "expired then replaced": @b10c I don't think the logs can catch it. Once a transaction expires it is already evicted, so a later conflicting transaction is never logged as replacing it, there is nothing in the mempool to replace. The only way would be to take the expired transaction's spent outpoints and check whether a later mempool entry or mined transaction spends them, which needs data the txid-only logs don't carry. Given 92 percent confirm anyway  the lost ones are minuscule of a concern, but it is the one piece this dataset can't answer.

Reproducer and more graphs: https://github.com/ismaelsadeeq/mempool-expiry

-------------------------

b10c | 2026-11-19 20:20:27 UTC | #10

To get a better understanding of expires in general: You might also want to look into e.g. surges of things expiring from mempool or if it's more a constant stream of expires, if there are more or less transactions at certain times that end up being mined, and if expiry happens on multiple nodes at a similar time.

-------------------------

ismaelsadeeq | 2026-11-24 11:30:41 UTC | #11

[quote="b10c, post:10, topic:132"]
ou might also want to look into e.g. surges of things expiring from mempool or if it’s more a constant stream of expires
[/quote]

Mostly surges. Most days are quiet, around 100 txs expire. But a handful of days carry the bulk: the top 10 days are 31% of all expiries, the top 30 days 57%. So it is a low daily baseline with occasional large spikes.

![fig_surges|690x265](upload://usmzQwtOXGO89I2SRPvCjjof7KX.png)

[quote="b10c, post:10, topic:132"]

If there are more or less transactions at certain times that end up being mined
[/quote]

By time here, you mean mempool congestion time? I dont have mempool history so can't tell but on the lens of expires, the share mined does not depend on that. It happens even when a lot expire at once: 91.8% mined on the top-30 surge days vs 92.3% on all other days.

![fig_by_month|690x286](upload://jDf9as0pkvScy24oDDa8Cbko0B3.png)


[quote="b10c, post:10, topic:132"]
if expiry happens on multiple nodes at a similar time.
[/quote]

Usually close. For txs seen by 2+ nodes, 40% expire within 10 seconds of each other and 55% within a minute. About 24% are more than 14 days apart. The wide gaps most likely come from rebroadcasts: the tx re-entered the network and different nodes picked it up at different times, so their 14-day timers started weeks apart. 

![fig_crossnode|690x387](upload://mQJrgsfbDkClMFvNKgL85lJI0v6.png)


I noticed something interesting from the data `nico` logged `reason=expiry` for transactions that had already been mined on-chain about 14 days earlier. It seems it was not removing confirmed transactions from its mempool, so they sat there until the 14-day expiry fired on an already-mined tx.

This is ~252k txids (about 29% of the "expired then confirmed" set), almost all on the Aug-2026 spike in the surge plot. It does not impact the numbers much when we subtract, expires then confirmed drop to 89% and then expired and rebroadcast is still along a same percentage.

three txids nico expired on 2026-09-19, all mined 14 days earlier on 2026-09-05

```
nico 2026-09-19T00:59:50Z TransactionRemovedFromMempool: txid=5ca2aefb16004da51ad7f902cfcf624fa578fe4221b9599f8884eeaea5c50e69 reason=expiry
nico 2026-09-19T00:59:50Z TransactionRemovedFromMempool: txid=28f72683d34d38dd234e92b140c1c3dbdda627131dacaed5759b53c656ba8628 reason=expiry
nico 2026-09-19T00:59:50Z TransactionRemovedFromMempool: txid=644cd4812d6318f2822aa8a30e6086c1d3bc8a1114cd95a73c37412ad81a4bec reason=expiry
```

| txid | mined in block | mined date | nico expired it |
| --- | --- | --- | --- |
| `5ca2aefb…0e69` | 965,545 | 2026-09-05 | 2026-09-19 |
| `28f72683…8628` | 965,544 | 2026-09-05 | 2026-09-19 |
| `644cd481…4bec` | 965,544 | 2026-09-05 | 2026-09-19 |

-------------------------

b10c | 2026-11-24 18:03:30 UTC | #12

[quote="ismaelsadeeq, post:11, topic:132"]
I noticed something interesting from the data `nico` logged `reason=expiry` for transactions that had already been mined on-chain about 14 days earlier. It seems it was not removing confirmed transactions from its mempool, so they sat there until the 14-day expiry fired on an already-mined tx.

This is \~252k txids (about 29% of the “expired then confirmed” set), almost all on the Aug-2026 spike in the surge plot. It does not impact the numbers much when we subtract, expires then confirmed drop to 89% and then expired and rebroadcast is still along a same percentage.

three txids nico expired on 2026-09-19, all mined 14 days earlier on 2026-09-05

```
nico 2026-09-19T00:59:50Z TransactionRemovedFromMempool: txid=5ca2aefb16004da51ad7f902cfcf624fa578fe4221b9599f8884eeaea5c50e69 reason=expiry
nico 2026-09-19T00:59:50Z TransactionRemovedFromMempool: txid=28f72683d34d38dd234e92b140c1c3dbdda627131dacaed5759b53c656ba8628 reason=expiry
nico 2026-09-19T00:59:50Z TransactionRemovedFromMempool: txid=644cd4812d6318f2822aa8a30e6086c1d3bc8a1114cd95a73c37412ad81a4bec reason=expiry

```

| txid | mined in block | mined date | nico expired it |
|----|----|----|----|
| `5ca2aefb…0e69` | 965,545 | 2026-09-05 | 2026-09-19 |
| `28f72683…8628` | 965,544 | 2026-09-05 | 2026-09-19 |
| `644cd481…4bec` | 965,544 | 2026-09-05 | 2026-09-19 |
[/quote]

Good catch! The `nico` node was running Knots with the BIP-110 fork for a while to monitor the hard fork (see https://bnoc.xyz/t/brainstorming-what-data-to-collect-and-monitor-during-the-bip-110-bip-300-forks-in-august-2026/139/16). I suspect these transactions were mined on Bitcoin, but were not mined on the BIP-110 chain as there was little to no hashrate left to find DSHA256 blocks. Maybe excluding or looking at the data from `nico` separately is better here since it's not Bitcoin Core.

-------------------------

ajtowns | 2026-11-25 01:09:55 UTC | #13

[quote="ismaelsadeeq, post:11, topic:132"]
`5ca2aefb16004da51ad7f902cfcf624fa578fe4221b9599f8884eeaea5c50e69`
[/quote]

The bip110 fork happened on Aug 8th, and the blake2b hardfork happened at block 961640 on Aug 30th, so presuming nico didn't update to the blake2b hardfork, nothing mined after Aug 30th, and most things mined after Aug 8th won't have been confirmed as far as it was concerned. If it had updated to the blake2b hard fork, those txs were all confirmed at height 967766 on 2026-09-05 according to https://mempool.maveth.ca/

-------------------------

