# Compact block reconstruction degradation between September - October 2026

m4ycon | 2026-10-23 21:07:09 UTC | #1

On April, I was working on adding some stats based on logs about compact block reconstruction in peer-observer (see [420](https://github.com/peer-observer/peer-observer/pull/420) and [465](https://github.com/peer-observer/peer-observer/pull/465)), since then, I've been looking to the added panels to validate them and I've seen some degradation around one of them: Compact block reconstruction without transaction requests per day.

In a simple way, ideally, when a block is mined and someone relay it to us, we'd have all transactions on our mempool. The sender send us a set of short ids of each transaction in that block instead of the full raw version of it, saving some bytes. If we don't have one of the transactions, we ask the sender for them to be able to reconstruct the full block -- a roundtrip that ideally wouldn't happen. See [BIP-152](https://github.com/bitcoin/bips/blob/master/bip-0152.mediawiki) for more details.

Example of a reconstruction log:

```
2026-04-06T15:02:09.404125Z [cmpctblock] Successfully reconstructed block 000000...6b6ad5
  with 1 txn prefilled,
  2714 txn from mempool (incl at least 2 from extra pool)
  and 4 txn (886 bytes) requested

```

I broke some lines to help reading, but it's just a single line. This log tells us that: 1 transaction came prefilled, coinbase always comes prefilled as probably we wouldn't have; 2714 were in our mempool and 2 of them were in extrapool, this extra acts like a "pre-discard", instead of simply erasing it from the mempool, we keep it for some time; and the focus of this post, 4 **transactions requested**, this causes the roundtrip, making us send a `getblocktxn` to the sender.

## The degradation

The below image shows how much reconstructions requested zero transactions from the sender, based on the previous log. Higher is better.

![image|690x404](upload://t23XoV3fE7SDhIzZ5lywFARqL3R.png)

It shows a clear degradation in this metric from 2026-07-18 to 2026-10-18, from around 35\~60% to at most 10% inside the period. This can be also seen in b10c's nodes as the below image shows, see [delving#1052](https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/53?u=m4ycon) tables for a longer period.

![image|690x403](upload://s0gfgquvJdt7yYAbfEPVtB86MmH.png)

What does it mean for the network? More roundtrips happening in reconstructions, so more `getblocktxn` being sent from nodes when (ideally) it shouldn't happen -- among other problems of network.

For a very long time, as a newbie in bitcoin, I had no idea of what could be causing this. But I recently read some posts/comments that opened a great hypothesis for this.

## /p2aburn.\*/

After reading [#193](https://bnoc.xyz/t/satoshi-31-0-0-peers-with-no-service-flags-and-protocol-70015-pushed-transactions-then-stopped-together-on-oct-18/193?u=m4ycon), I took some time investigating those strange agents: `/Sat0shi:31.0.0/` and `/Satoshi:31.0.0/` with protocol version `70015`. I also found another agent behaving similarly `/p2aburn.*/`, that was also mentioned later in the same post. Later, I found `/txbroadcast.*/` which also behaves similarly to those peers.

The moment those nodes first appear seems to correlate with the degradation start and they make sense to impact on this. As mentioned by the author, and also seen on my node, they were sending many unsolicited transactions to our nodes.

At [#193 comment](https://bnoc.xyz/t/satoshi-31-0-0-peers-with-no-service-flags-and-protocol-70015-pushed-transactions-then-stopped-together-on-oct-18/193/5?u=m4ycon), I built a first timeline with each event, but here it is a more updated version:


[grid]

![image|690x263](upload://xQRNZBQP4ryP55LvJoNY93XZc1X.png)

![image|690x217](upload://yjtGmxN9CSW9QB9gzPjx81jQr1K.png)

![image|690x219](upload://scdVhuPcXVzAGJdCLwT1M3kAzJF.png)


[/grid]

Notes:

* The bar panels are based on logs and they go from now until 2026-07-08.
* The query used for the peer-observer data (line panels) is `sum by (useragent) (increase(peerobserver_p2p_version_useragent{useragent=~"/txbroadcast.*|/p2aburn.*|/Sat0shi:31.0.0/"}[1d]))`. Also, it doesn't mean that they held X connections on that day.
* There's no way to filter `Satoshi:31.0.0 70015` in peer-observer data, but they appear on the panel based on logs.

Timeline:

 1. 2026-07-03: `/p2aburn-probe:0.1/` first appearance;
 2. 2026-07-04: `/txbroadcast:0.1/` first appearance;
 3. 2026-07-07: a single `/p2aburn:0.1/` connection;
 4. 2026-07-14: `/p2aburn:1.0/` first appearance;
 5. 2026-07-18: compact block reconstruction degradation starts (below 10% from 2026-07-23);
 6. 2026-07-25: `/txbroadcast:0.1/` last appearance;
 7. 2026-07-28: `/Sat0shi:31.0.0/` first appearance;
 8. 2026-09-21: `/Satoshi:31.0.0/` (protocol 70015) first appearance;
 9. 2026-09-22: `/Sat0shi:31.0.0/` last appearance;
10. 2026-10-18: `/Satoshi:31.0.0/` (protocol 70015) last appearance;
11. 2026-10-18: compact block reconstruction degradation stops;
12. 2026-10-19: after some peaks, `/p2aburn:1.0/` falls to about 30\~50 connections per day and a very low volume of messages.

At the same time that `/p2aburn:1.0/` arrived and started sending a meaningful volume of messages, the metric started declining. And just recently, since many VPS providers rebooted their machines due to CVE-2026-99999 (including mine), see more at [#189](https://bnoc.xyz/t/effect-of-linux-kernel-cve-2026-99999-cvss-9-3-pwnscape-on-the-bitcoin-network/189?u=m4ycon), this metric bumped to the usual 40\~60%. This may have another reasons, but at the moment is my only clue on why they've stopped.

Note: from now on, I will call `/txbroadcast:0.1/`, `/Sat0shi:31.0.0/` and `/Satoshi:31.0.0/` (protocol 70015) set as the **"fleet"** -- because their behavior are similar, unlike `/p2aburn.*/`.

Currently, we have zero connections to the fleet and just a few `/p2aburn.*/` active, but sending a way lower volume of messages.

Also, see how much tx messages they were sending to my node (based on logs, until 2026-07-08):

![image|690x225](upload://aCRF0C4L0Cz9X7rlo2hewpUivwA.png)

## Differences in behavior

For this specific section, most part of it was written by a llm checking my data/logs, it seems to make sense with all the data I've seen.

### The "fleet" (builds the chains)

* **It pushes transactions without announcing them.** We received 32.9M tx messages from it against only 1.8M inv. A normal peer announces with inv and sends the transaction only when asked. At its peak (Oct 5) it sent \~1.33M transactions a day.
* **It reconnects constantly.** We saw \~31.7k handshakes over the period.
* **It builds P2A chains carrying Runes:**
  * A root transaction, funded by a wallet input, creates an anchor (290 sats in the chain we followed; other roots use 280, 350 and so on).
  * Each link spends the previous anchor, pays 10 sats of fee and creates an anchor 10 sats smaller.
  * When the anchor reaches 240 sats (the dust limit), a refill transaction tops it up again.
  * A closing transaction pays 679 sats of fee and ends the chain.
  * Each link mints 1 unit of rune 1:0. Under the mint rule, the runes accumulate on the anchor until the closing transaction.

### p2aburn (breaks the chains)

* **It says the bare minimum.** We received only `tx` (2.96M), `pong`, `version` and `verack` from it. It never sends `inv`, `ping`, `addr` or `headers`, so it does not announce anything either: it just pushes transactions.
* **It reconnects a lot.** We saw 28,770 handshakes, close to 3k a day at the peak (Oct 17).
* **It sweeps anchors.** Each of its transactions spends an anchor in the middle of a fleet chain and turns the anchor's whole value into fee. The verified example is sweeper `0b88a628...`: 66 vB, 290 sats of fee, and it replaced links 1 to 4 in our mempool. Its average transaction size, \~66 to 80 bytes, fits this. Under the Runes mint rule, a sweep would also burn the runes accumulated on the anchor. That part is inferred: we never decoded a sweeper.
* **It was already sending transactions on Jul 22,** a week before the fleet showed up. We don't know what it was sweeping then.
* **It almost stopped after Oct 18.** The following days saw \~150 transactions and \~40 connections a day, against 69k transactions on Oct 17. That fits: it ran out of chains to sweep.

## The transaction chains

A transaction can spend an output of another transaction that is not confirmed yet. Doing this repeatedly gives a chain: tx1 is in the mempool, tx2 spends tx1's output, tx3 spends tx2's, and so on. A miner can include the whole chain in one block, as long as each link comes after its parent.

The "fleet" builds these chains on top of P2A (pay-to-anchor) outputs. A P2A output has a 4-byte script and no key: anyone can spend it without a signature, and the input is the smallest there is (41 vB). Each link in the fleet's chains:

* spends the P2A anchor created by the previous link;
* creates a new anchor 10 sats smaller than the one it spends (from 290 down to 240, the dust limit), and a closing tx sweeps the last anchor with a wallet input, paying 679 sats;
* carries a Runes `OP_RETURN`;
* is 94 to 107 bytes and pays 10 sats of fee (\~0.1 sat/vB).

The chains are up to 25 links long. Since there is no key, the fleet can build and broadcast whole chains very fast. The flip side is that the same property lets anyone spend an anchor in the middle of a chain.

Those 25 txs clusters are very common to be in mempool, take a look at the below metric taken out of [Cluster Mempool Observer histogram](https://cluster-mempool-observer.m4ycon.com/clusters?v=h&s=t&c=t&b=50). Btw it's a personal project to track a history of every movement of the mempool and its clusters (still experimental). [Here](https://cluster-mempool-observer.m4ycon.com/clusters?v=t&s=t&c=t&n=250&b=50) you can look at many examples of them individually, and [here](https://mempool.space/tx/16b6b4106898fd3bed1a941d2e7412cab0f0107610a3c43f538e436546d8a591?cpfp=true) you can see them in mempool space.

![image|632x500, 75%](upload://sAFTbeOiRRKGA2yMkq6qtbmtIrj.png)

Also those "Rune mint chains" possibility is mentioned at [delving#1052](https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/56?u=m4ycon).

## How a mid-chain replacement could degrade compact block reconstruction

I personally didn't know much about P2A, tried to learn a bit about it. **Feel free to correct me** if I say anything wrong.

This is my main hypothesis right now, since a single transaction is all that's need to trigger a `getblocktxn` in reconstruction, I think this can be great part of the reason why we see this degradation.

Anyone who gets a conflicting spend of one link into the mempool can cut a chain of unconfirmed transactions. For example:

1. A chain of 10 transactions, tx1 to tx10, each spending an output of the previous one.
2. Someone broadcasts tx5', which spends the same input as tx5 and pays a higher fee.
3. My node correctly accepts tx5' under the RBF rules and evicts tx5 along with its descendants, tx6 to tx10. If tx5' arrives first, the node rejects tx5 instead, and tx6 to tx10 never get in because their inputs are missing.
4. A miner that has the original chain and never takes tx5' mines all 10.
5. When the block arrives, my node is missing tx5 to tx10. It cannot rebuild the block from the compact block alone and has to fetch them with `getblocktxn`. Bitcoin Core keeps recently replaced transactions in extrapool for this case, but at high enough volume they no longer fit.

My node did nothing wrong at any step. Its mempool holds a valid history that differs from the one the miner chose.

### Cost

With plain RBF, the replacement must pay more in absolute fees than everything it evicts. It costs nothing only when it never confirms, which is what happens in the example: the block containing the original chain invalidates it. If a miner picks up tx5' instead, the sender pays.

P2A anchors remove most of that cost. Because anyone can spend an anchor, the sweeper's fee comes almost entirely from the anchor's own value. In what I saw, a sweeper spends an anchor and turns its whole value into fee (290 sats for the root anchor), so the sender adds nothing of their own.

### Real case

1. without the sweeper tx

   * [Confirmed chain](https://mempool.space/tx/13b821bcdf10da153ab6f1e98b58bd45772cfd1e02a0e51369a2b0e319092d2a?cpfp=true) at mempool space.
   * Log of a mid-chain replace transaction (sweep):

   ```
   02:52:51.520852 [mempool] replacing mempool tx 13b821bcdf10da153ab6f1e98b58bd45772cfd1e02a0e51369a2b0e319092d2a (fees=10, vsize=94). New tx 0b88a6…e6b (fees=290, vsize=66)
   ```

[details="0b88a6…e6b log history"]
```
2026-10-18T02:52:46.375697Z [net] got inv: wtx 0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b  new peer=558834
2026-10-18T02:52:47.654915Z [net] got inv: wtx 0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b  new peer=579887
2026-10-18T02:52:47.968011Z [net] got inv: wtx 0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b  new peer=559137
2026-10-18T02:52:49.006334Z [net] Requesting wtx 0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b peer=558834
2026-10-18T02:52:49.900944Z [net] got inv: wtx 0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b  new peer=198695
2026-10-18T02:52:50.026483Z [mempoolrej] 0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b (wtxid=0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b) from peer=558834 was not accepted: bad-txns-inputs-missingorspent
2026-10-18T02:52:50.026531Z [txpackages] added peer=558834 as a candidate for resolving orphan 0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b
2026-10-18T02:52:50.026558Z [txpackages] stored orphan tx 0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b (wtxid=0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b), weight: 264 (mapsz 3000 outsz 547)
2026-10-18T02:52:50.027014Z [txpackages] added peer=198695 as a candidate for resolving orphan 0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b
2026-10-18T02:52:50.027049Z [txpackages] added peer=198695 as announcer of orphan tx 0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b (wtxid=0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b)
2026-10-18T02:52:50.029756Z [txpackages] added peer=559137 as a candidate for resolving orphan 0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b
2026-10-18T02:52:50.029854Z [txpackages] added peer=559137 as announcer of orphan tx 0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b (wtxid=0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b)
2026-10-18T02:52:50.030228Z [txpackages] added peer=579887 as a candidate for resolving orphan 0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b
2026-10-18T02:52:50.030299Z [txpackages] added peer=579887 as announcer of orphan tx 0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b (wtxid=0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b)
2026-10-18T02:52:50.436991Z [net] got inv: wtx 0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b  have peer=68215
2026-10-18T02:52:51.350667Z [txpackages] added 0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b (wtxid=0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b) to peer 579887 workset
2026-10-18T02:52:51.520852Z [mempool] replacing mempool tx 13b821bcdf10da153ab6f1e98b58bd45772cfd1e02a0e51369a2b0e319092d2a (wtxid=13b821bcdf10da153ab6f1e98b58bd45772cfd1e02a0e51369a2b0e319092d2a, fees=10, vsize=94). New tx 0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b (wtxid=0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b, fees=290, vsize=66)
2026-10-18T02:52:51.520937Z [mempool] replacing mempool tx 4f8c3171b8113f58908a49aabfa1e9fc0c132424744bb590ca5748092fa6b076 (wtxid=4f8c3171b8113f58908a49aabfa1e9fc0c132424744bb590ca5748092fa6b076, fees=10, vsize=94). New tx 0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b (wtxid=0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b, fees=290, vsize=66)
2026-10-18T02:52:51.521007Z [mempool] replacing mempool tx 5474f4ed1416e5eb4e6c08f304e7ae9cc7d8810550c3cc50fe58d3f674214278 (wtxid=5474f4ed1416e5eb4e6c08f304e7ae9cc7d8810550c3cc50fe58d3f674214278, fees=10, vsize=94). New tx 0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b (wtxid=0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b, fees=290, vsize=66)
2026-10-18T02:52:51.521052Z [mempool] replacing mempool tx ef435405d8d1d26004227a4ccb9bba0f986ed341e0e2b90953b874208a78cca3 (wtxid=ef435405d8d1d26004227a4ccb9bba0f986ed341e0e2b90953b874208a78cca3, fees=10, vsize=94). New tx 0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b (wtxid=0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b, fees=290, vsize=66)
2026-10-18T02:52:51.521427Z [validation] Enqueuing TransactionAddedToMempool: txid=0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b wtxid=0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b
2026-10-18T02:52:51.521636Z [txpackages]    accepted orphan tx 0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b (wtxid=0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b)
2026-10-18T02:52:51.521716Z [txpackages] removed orphan tx 0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b (wtxid=0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b) (4 announcements)
2026-10-18T02:52:51.521746Z [mempool] AcceptToMemoryPool: peer=579887: accepted 0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b (wtxid=0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b) (poolsz 65628 txn, 203753 kB)
2026-10-18T02:52:51.522529Z [validation] TransactionAddedToMempool: txid=0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b wtxid=0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b
2026-10-18T02:52:53.404301Z [net] received getdata for: wtx 0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b peer=525174
  ... many messages like this one ...
2026-10-18T02:53:09.123461Z [net] received getdata for: wtx 0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b peer=203622
2026-10-18T02:53:32.038941Z [net] received getdata for: witness-tx 0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b peer=575294
2026-10-18T02:53:33.445418Z [net] received getdata for: witness-tx 0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b peer=189287
2026-10-18T02:53:38.900648Z [net] received getdata for: witness-tx 0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b peer=159574
2026-10-18T03:51:20.505211Z [validation] Enqueuing TransactionRemovedFromMempool: txid=0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b wtxid=0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b reason=conflict
2026-10-18T03:51:20.505399Z [validation] TransactionRemovedFromMempool: txid=0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b wtxid=0b88a6283cd045dadc500d1fc92a735da0c35357351c7d46111c18930e5e8e6b reason=conflict
```

[/details]

2. with the sweeper tx

   * [Confirmed sweeper](https://mempool.space/tx/fada93f79fdfd38ffd9049ffe61195e858b5b110fdffefa16f1440a62078e89b?cpfp=true) case.
   * In this case, my node already have the rest of the chain, so it rejected the sweeper, but later a miner mined the sweeper.

[details="fada93...89b log history"]
```
# sweeper fada93f79fdfd38ffd9049ffe61195e858b5b110fdffefa16f1440a62078e89b and its parent 9d887fdb2cd62c6af31801f4f9dc2dece40b0c69255c8a46125275368bf8b788

2026-10-13T05:45:50.736096Z \[validation\] Enqueuing TransactionAddedToMempool: txid=9d887fdb2cd62c6af31801f4f9dc2dece40b0c69255c8a46125275368bf8b788 wtxid=265a8c7dad0c3e0fb0329777c279aab78b031b149333357ec3fade3ec42d7c4f
2026-10-13T05:45:50.736226Z \[mempool\] AcceptToMemoryPool: peer=492350: accepted 9d887fdb2cd62c6af31801f4f9dc2dece40b0c69255c8a46125275368bf8b788 (wtxid=265a8c7dad0c3e0fb0329777c279aab78b031b149333357ec3fade3ec42d7c4f) (poolsz 80331 txn, 219945 kB)
2026-10-13T05:45:50.736435Z \[validation\] TransactionAddedToMempool: txid=9d887fdb2cd62c6af31801f4f9dc2dece40b0c69255c8a46125275368bf8b788 wtxid=265a8c7dad0c3e0fb0329777c279aab78b031b149333357ec3fade3ec42d7c4f
2026-10-13T05:45:50.882843Z \[mempoolrej\] fada93f79fdfd38ffd9049ffe61195e858b5b110fdffefa16f1440a62078e89b (wtxid=fada93f79fdfd38ffd9049ffe61195e858b5b110fdffefa16f1440a62078e89b) from peer=491503 was not accepted: insufficient fee, rejecting replacement fada93f79fdfd38ffd9049ffe61195e858b5b110fdffefa16f1440a62078e89b, not enough additional fees to relay; 0.00 < 0.00000007
2026-10-13T05:45:50.882883Z \[txpackages\] tx fada93f79fdfd38ffd9049ffe61195e858b5b110fdffefa16f1440a62078e89b (wtxid=fada93f79fdfd38ffd9049ffe61195e858b5b110fdffefa16f1440a62078e89b) failed but reconsiderable, looking for child in orphanage
2026-10-13T05:45:50.979074Z \[net\] got inv: tx 9d887fdb2cd62c6af31801f4f9dc2dece40b0c69255c8a46125275368bf8b788 have peer=492350
2026-10-13T05:45:50.996410Z \[net\] got inv: tx 9d887fdb2cd62c6af31801f4f9dc2dece40b0c69255c8a46125275368bf8b788 have peer=492349
2026-10-13T05:45:51.016461Z \[net\] got inv: tx 9d887fdb2cd62c6af31801f4f9dc2dece40b0c69255c8a46125275368bf8b788 have peer=492352
2026-10-13T05:45:51.191786Z \[mempoolrej\] 9d887fdb2cd62c6af31801f4f9dc2dece40b0c69255c8a46125275368bf8b788 (wtxid=9d887fdb2cd62c6af31801f4f9dc2dece40b0c69255c8a46125275368bf8b788) from peer=454673 was not accepted: txn-same-nonwitness-data-in-mempool
2026-10-13T05:45:54.662342Z \[net\] got inv: wtx fada93f79fdfd38ffd9049ffe61195e858b5b110fdffefa16f1440a62078e89b have peer=453525
2026-10-13T05:45:55.571249Z \[net\] received getdata for: witness-tx 9d887fdb2cd62c6af31801f4f9dc2dece40b0c69255c8a46125275368bf8b788 peer=439623
 ... many messages like this one ...
2026-10-13T05:46:01.483448Z \[net\] received getdata for: witness-tx 9d887fdb2cd62c6af31801f4f9dc2dece40b0c69255c8a46125275368bf8b788 peer=446573

# block 971201 (0000000000000000000036fa723572e1e835152288cc97f72e0bafd5cdbb80cd) on our node

2026-10-13T06:19:55.156703Z Saw new header hash=0000000000000000000036fa723572e1e835152288cc97f72e0bafd5cdbb80cd height=971201 peer=320080
2026-10-13T06:19:55.717381Z \[cmpctblock\] Successfully reconstructed block 0000000000000000000036fa723572e1e835152288cc97f72e0bafd5cdbb80cd with 1 txn prefilled, 4395 txn from mempool (incl at least 3 from extra pool) and 1784 txn (203298 bytes) requested
2026-10-13T06:19:56.484269Z UpdateTip: new best=0000000000000000000036fa723572e1e835152288cc97f72e0bafd5cdbb80cd height=971201 version=0x20170000 log2_work=96.388563 tx=1458976279 date='2026-10-13T06:19:32Z' progress=1.000000 cache=526.0MiB(3921176txo)
```

[/details]

## Final thoughts

* Why is `p2aburn` still active but not harming the metric? Maybe because the fleet is not sending transactions? So they don't have anything to harm? I suppose fleet operators didn't realize it yet (nodes off), as we don't have connections to them? And when they do, will we have the same degradation?
* I still need to cross data around what is the reason that each block is not fully on our mempool, requiring `getblocktxn` call, if data points out to "most blocks are missing a tx from some rune chain" instead of the other options mentioned at [delving#1052](https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/56?u=m4ycon), it will strengthen this hypothesis.
* I still need to really understand P2A, it shouldn't be that easy to cause this mess in the network, probably I'm missing something out.

Although this post focus on this hypothesis about P2A and sweepers, feel free to comment about other theories. The focus is on **why do we see this reconstruction degradation on the network**.

-------------------------

benunskilled | 2026-10-23 11:20:51 UTC | #2

Thanks for putting this together. I don't log cmpctblock, but I have a side measurement that moves at the same time: for each new block, the gap between the first job from a local stratum server fed by my own Core and the fastest of three public pools.

Same node, no restart, the same manual peers until Oct 21. Median gap:

Oct 7 – Oct 18 13:28 UTC (last fleet session here): 249 ms over 1,741 blocks

Oct 18 13:28 – Oct 22: 115 ms over 600 blocks   I had to restart my node on Oct  22.

My node's own block detection minus the fastest pool drops the same way (209 → 98 ms), so it's not just template building. And since my node wasn't restarted around Oct 18, the change here isn't from a reboot.

My guess is your effect: my mempool was missing transactions from new blocks, so Core had to fetch them first. One extra round trip fits the size of the step. It's one node and only a correlation, and my data starts mid-September.

-------------------------

benunskilled | 2026-10-23 12:18:47 UTC | #3

Follow-up: I checked every block from Oct 7 to Oct 22 for fleet txs. Blocks without any sped up just the same. SecPool and Luxor never included a fleet tx or a sweep, yet on my node:

SecPool: 356 → 114 ms

Luxor: 330 → 98 ms

So here it doesn't look like the chain txs inside the block were the main cause. Something else in the mempool, maybe? Small samples after Oct 18, and no cmpctblock logs, so I can't say more. Sorry for the hasty guess earlier.

-------------------------

octaviolucca | 2026-10-23 21:10:43 UTC | #4

I had some peer-observer archives from Aug 12 and Aug 18–19, so I went looking for the fleet and decoded the txs it pushed to us. They look exactly like the P2A chains described above!



The fleet showed up as /Sat0shi:31.0.0/, always inbound. It sent around 3.4k tx and only ~130 inv, and it never requested anything back. Every tx carries a runestone. Almost all of them are 25-long chains:
- a root tx with a \~474 sat P2A output
- 24 links, each spending the previous anchor and paying 10–11 sats of fee (~0.1 sat/vB)
- a tail tx paying \~13 sat/vB, which pulls the whole chain in with CPFP

On Aug 12 we also had mempool events, and I could see the sweeps happening. They're 66 vB txs that pay exactly the anchor's 474 sats as fee, and each one evicted up to 17 links. On the same day, a good chunk of the fleet's txs were mined, others were replaced, and a few hundred were rejected for missing inputs.

p2aburn did connect to this node, but it never sent a tx. It only did handshakes, so the sweeps reached us through other peers.

I haven't cross-checked any of this against our cmpctblock getblocktxn yet
Will post it once I have it.

-------------------------

octaviolucca | 2026-10-24 19:06:14 UTC | #5

[quote="octaviolucca, post:4, topic:198"]
I haven’t cross-checked any of this against our cmpctblock getblocktxn yet
Will post it once I have it.
[/quote]

I cross-checked against our `cmpctblock` / `getblocktxn`


- Only 5 of 162 compact blocks were reconstructed without a round trip.

- About 96% of the txs we had to request were fleet chain links, and another 2–4% were sweeps. In 53 blocks, nothing else was missing. The worst block, [963060](https://mempool.space/block/0000000000000000000024a18b8c8b76b78e3ace721dc95137a5ef720446a174), needed 4,757 of its 7,049 txs, and 4,715 of those were fleet
- Without the fleet and sweep misses, 36% of these blocks would have reconstructed with no round trip at all (vs 3% actually), and 54% would have been missing at most one other tx.
- Most of the missing links had already reached us before the block, relayed by normal peers. We had rejected them with `bad-txns-inputs-missingorspent` (~87% on Aug 12) because their anchor input was gone or already spent in our mempool. The mined sweeps had been rejected for `insufficient fee`.


The three worst blocks look different: [963059](https://mempool.space/block/000000000000000000018693f97f89697142f4e2a894f5cac1a3cc1cb43d1073) (Foundry), [963060](https://mempool.space/block/0000000000000000000024a18b8c8b76b78e3ace721dc95137a5ef720446a174) (Binance, 14 s later) and [963130](https://mempool.space/block/00000000000000000001fcc56da1693add8f94890c1974ccbc4e98cba62f4144) (AntPool). Each one came during a big fleet burst.
Incoming txs jumped ~15x right before 963130. During the burst, every tx (not just fleet ones) took ~10–30 s to show up on our node instead of under a second, so the pools mined the burst before we had it. That might also explain what @benunskilled saw: his node got faster at picking up new blocks after Oct 18, even for blocks with no fleet txs at all (SecPool, Luxor)

If anyone has data from another node around Aug 18 14:48 UTC or Aug 19 04:32 UTC, comparing would be great

I'm happy to check anything else in these archives too, any questions? I hope so because this isnt really clear for me yet but idk what else to search for

-------------------------

m4ycon | 2026-10-27 22:58:09 UTC | #6

[quote="benunskilled, post:3, topic:198"]
SecPool and Luxor never included a fleet tx or a sweep, yet on my node

[/quote]

Good catch, I didn't know there were pools that didn't mine them.

[quote="benunskilled, post:3, topic:198"]
So here it doesn’t look like the chain txs inside the block were the main cause.

[/quote]

I have a guess about it, no easy way to prove it, but I think as node's extrapools were being flooded by this sweeper problem, other "innocent" clusters (of txs) were being harmed and not properly mounted in the mempool (orphan eviction).

[quote="octaviolucca, post:5, topic:198"]
* About 96% of the txs we had to request were fleet chain links, and another 2–4% were sweeps.

[/quote]

I was seeing a similar estimative around this, and although there were another types of txs missing, great part of it were fleet chain links. I imagine that miners have a really "boosted" node, so their extrapool is quite far bigger that the default 100 size, and it ends helping them to build the best clusters of txs -- which is usually the fleet one, not the sweeper.

---

For reasons of **reproducibility** of this post, I organized a [repository](https://github.com/m4ycon/cmpct-block-reconstruction-degradation/) that allows you to go through your node's logs and see similar graphs. It requires some `debug` flags turned on: `net` (main one), `cmpctblock`, `mempoolrej`. Its readme also contains which logs are being used, if you want to do an independent check. I changed to not use peer-observer data, as not everyone has it on their nodes, although readme still mentions related promql.

Besides that, I'm working on gathering the reasons of each requested tx and also building a warnet simulation of each actor from this post (fleet, sweeper...). I'll say upfront that, the **real problem** is when the fleet AND sweeper (`p2aburn`) are announcing txs. The fleet building P2A chains and the sweeper cutting them, in volume, kills the purpose of the extrapool (and maybe also `TxOrphanage`?).

Extra: P2A had a great increase in "Input Types by Count" since 2026-07-01 until 2026-10-18, which fits our observations. See [Input Types by Count](https://mainnet.observer/charts/inputs-types-by-count/), in 1d moving average you can see the start and end of it.

-------------------------

b10c | 2026-11-01 10:27:25 UTC | #7

Thank you all for the investigation! I posted my current understanding of it to https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/62. I think this is mostly solved for now but feel free to continue the discussion.

-------------------------

b10c | 2026-11-01 10:33:17 UTC | #8

[quote="m4ycon, post:6, topic:198"]
Extra: P2A had a great increase in “Input Types by Count” since 2026-07-01 until 2026-10-18, which fits our observations. See [Input Types by Count](https://mainnet.observer/charts/inputs-types-by-count/), in 1d moving average you can see the start and end of it.
[/quote]

[quote="benunskilled, post:3, topic:198, full:true"]
Follow-up: I checked every block from Oct 7 to Oct 22 for fleet txs. Blocks without any sped up just the same. SecPool and Luxor never included a fleet tx or a sweep, yet on my node:

SecPool: 356 → 114 ms

Luxor: 330 → 98 ms

So here it doesn’t look like the chain txs inside the block were the main cause. Something else in the mempool, maybe? Small samples after Oct 18, and no cmpctblock logs, so I can’t say more. Sorry for the hasty guess earlier.
[/quote]


Oh nice spot. I think SecPool, Luxor, along with Poolin, Binance Pool, BTC.com, ... don't create a template with a Bitcoin Core v28.0 yet. They might still be relying on v27.x or older. See also https://bnoc.xyz/t/bitcoin-core-versions-run-by-mining-pools/57 and https://mainnet.observer/charts/mining-pools-mining-p2a/. 


![image|676x500](upload://fSjueEJVUvTviEo8MY22F92gPn6.png)

-------------------------

m4ycon | 2026-11-04 00:28:44 UTC | #9

As a last contribution to this post and to not throw it away, I did a warnet experiment to try to prove those affirmations. It's included in this [repository](https://github.com/m4ycon/cmpct-block-reconstruction-degradation) if you want to check in details. But here it is the most important informations about the simulation:

1. 36 nodes (core v31): 3 miners, 30 innocents and the actors (mint, fleet, sweeper);
   1. **Mint**: create common rune mints, without P2A, chains between 20 to 24 txs; sends 4.7 tx/s;
   2. **Fleet**: create P2A chains, on each chain we have a root tx, links (P2A txs), tail (CPFP), refill (increase feerate); sends 2.1 tx/s;
   3. **Sweeper**: each 1 second it queries the mempool looking for P2A chains, choses a random P2A tx from each found chain and send a sweep tx spending everything as fee.
2. Each node receives 1 or 2 nodes via `addnode` initially, then they start to connect as usual;
3. `blockmaxweight` 400000 (10% of the default value);
4. Extrapool cap `blockreconstructionextratxn` 20 (default is 100);
5. Each block is mined every 1 minute;
6. Each miner creates its template every 15s and just after every mined block;
7. Phases (\~2h):
   1. 5 min warmup;
   2. 7 phases of 17 min: control -> all → no-sweeper → all → no-fleet → all → no-mint;

The next images show similar metrics as reported in the first comment, but for the simulation. We can see that clearly, if the fleet and the sweeper are active, the metric is degraded.


[grid]

![Reconstruction, actors and rejections per minute|472x500](upload://dCJJ8svPtlXSHQlkjYP7ZxdcooN.png)

![Messages received per minute and peer group (solid color is tx messages, others are hatched)|491x500](upload://b5BPG6mGFzebNEHfHqbMk1j6CVV.png)


[/grid]

It's interesting to see that even the mint node not participanting directly on the degradation, it did some snow balling effect, with it disabled the metric raised from \~73% to 83%. As I commented last week, I think that as other transactions that also needs the extrapool to be mounted properly (as the chains sent by mint node), this increases the harm of it.

![Each phase and its reconstruction without request rate|460x409, 75%](upload://zxoku6Da8KGvYCUlitMqW28y1LZ.png)

I ran some tests with variations of `blockreconstructionextratxn` (extrapool cap), and as expected, it had a great correlation on how many reconstructions didn't need a `getblocktxn`.

![Different extrapool caps and how they affected reconstruction|690x319, 75%](upload://AgVQ6nABiaDVxUr2Flsqo57XafE.png)

---

Additionally, I asked for a llm to query for possible related projects to this case based on the data I already had. So summarizing its findings: it seems that a project called [alkanes-rs](https://github.com/kungfuflex/alkanes-rs) did a [fork](https://github.com/kungfuflex/alkanes-rs/pull/317) in its way of working in height [972000](https://mempool.space/block/00000000000000000001f09a6919251b4c3dd5261ee68c8a17ec718667d35f20), which matches the last P2A chains being relayed/mined -- and if that's really the case, invalidates my initial hypothesis that it stopped due to vps reboots related to CVE-2026-99999.

[details="How the llm identified who it was?"]
Example tx: [`13b821bc...092d2a`](https://mempool.space/tx/13b821bcdf10da153ab6f1e98b58bd45772cfd1e02a0e51369a2b0e319092d2a) (the "Confirmed chain" above), block 971942.

The proof is in three parts of the OP_RETURN, each defined in the `alkanes-rs` code. Only the first is visible in the raw hex; the other two appear after decoding the tag's value:

```
6a5d12 14011400 ff7f 818cec82d08bc0a88281d215
                ^^^^ ^^^^^^^^^^^^^^^^^^^^^^^^
                tag  value, decoded: 01 06 5b 00 5d 00 51 8280b402
                                     ^^                   ^^^^^^^^
                                     protocol             call: 02 00 4d
```

| Part of the tx | Value | Meaning | Where the project defines it |
|----|----|----|----|
| `ff7f` | 16383 | Protocol field, which carries the protostone | [`tag.rs:26`](https://github.com/kungfuflex/alkanes-rs/blob/ea38c878931ff4b6dd64dd011962f2203d6e0a35/crates/ordinals/src/runestone/tag.rs#L26): `Protocol = 16383` |
| `01` (1st decoded byte) | 1 | **Alkanes protocol** | [`message.rs:205`](https://github.com/kungfuflex/alkanes-rs/blob/ea38c878931ff4b6dd64dd011962f2203d6e0a35/src/message.rs#L205): `fn protocol_tag() -> u128 { 1 }` |
| `02 00` (inside `8280b402`) | `2:0` | **DIESEL alkane** | [`precompile_diesel.rs:75`](https://github.com/kungfuflex/alkanes-rs/blob/ea38c878931ff4b6dd64dd011962f2203d6e0a35/src/precompile_diesel.rs#L75): `DIESEL_ID = AlkaneId { block: 2, tx: 0 }` |
| `4d` (inside `8280b402`) | 77 | **mint opcode** | [`precompile_diesel.rs:336-338`](https://github.com/kungfuflex/alkanes-rs/blob/ea38c878931ff4b6dd64dd011962f2203d6e0a35/src/precompile_diesel.rs#L336-L338): `cellpack.target == DIESEL_ID` and `cellpack.inputs[0] == 77` |

**The most direct link is DIESEL's own mint counter.** At [`precompile_diesel.rs:317`](https://github.com/kungfuflex/alkanes-rs/blob/ea38c878931ff4b6dd64dd011962f2203d6e0a35/src/precompile_diesel.rs#L317) it skips protostones with `protocol_tag != 1`, and at lines 336-338 it counts those calling `2:0` with opcode 77. The tx carries exactly these values, so the project's code counts it as a DIESEL mint.

The project identifier is the `01`, not the `ff7f`: tag 16383 only says there is a protostone, and the `1` says it belongs to Alkanes.

[/details]

I didn't go too far on this as it's not of my interest understand those projects, and we already have a great understanding of what's the problem in the network.

-------------------------

b10c | 2026-11-04 18:21:20 UTC | #10

[quote="m4ycon, post:9, topic:198"]
Additionally, I asked for a llm to query for possible related projects to this case based on the data I already had. So summarizing its findings: it seems that a project called [alkanes-rs](https://github.com/kungfuflex/alkanes-rs) did a [fork](https://github.com/kungfuflex/alkanes-rs/pull/317) in its way of working in height [972000](https://mempool.space/block/00000000000000000001f09a6919251b4c3dd5261ee68c8a17ec718667d35f20), which matches the last P2A chains being relayed/mined – and if that’s really the case, invalidates my initial hypothesis that it stopped due to vps reboots related to CVE-2026-99999.
[/quote]

Yes, that project (what ever it does, I don't know) seems to very much related.

https://subfrost.io/metrics and https://vdto88.github.io/alkanes-opreturn-stats/ both show the number of transactions dying down around October 18th, right when the reconstructions got better again. 

![image|690x297](upload://wB10BiqeIaRikwgTHPGidKod3ma.png)

I haven't found any P2P code that pushes out these transactions yet.

-------------------------

b10c | 2026-11-05 04:16:47 UTC | #11

[quote="m4ycon, post:1, topic:198"]
* [Confirmed chain](https://mempool.space/tx/13b821bcdf10da153ab6f1e98b58bd45772cfd1e02a0e51369a2b0e319092d2a?cpfp=true) at mempool space.
[/quote]

This shows up on their explorer as https://explorer.subfrost.io/tx/13b821bcdf10da153ab6f1e98b58bd45772cfd1e02a0e51369a2b0e319092d2a 

![image|690x186](upload://lyXnT0zxyzq7z0s7cOC92M6eeC8.png)


I also learned about [4ed97a14313db94233738ed9898f08c677d81aec008fa708d110d3f79010c041](https://mempool.space/tx/4ed97a14313db94233738ed9898f08c677d81aec008fa708d110d3f79010c041), which was not see in mempool and seems to be a different kind of runestone mint, which is also using P2A.

![image|690x134](upload://njxSGWutB8zHzcL7X35uFE8RWGe.png)

With 80 vB, these are even smaller and only pay 8 sat in fees. They mined by AntPool. I suspect they are submitted to AntPool directly as the 50sat output is below the default `-dustrelayfee` of 80 vB × 3 sat/vB = 240 sat . This also means they won't propagate and nobody is able to P2A-burn them. They'll also cause a compact block reconstruction round-trip.

-------------------------

b10c | 2026-11-07 15:31:47 UTC | #12

Came across this https://x.com/mononautical/status/2118967907774513275 

> these ultra-compact p2a rune minting transactions have spread to ViaBTC and F2Pool.
>
> these use a new scheme with chains of transactions paying 1 satoshi each in fees, boosted by a final fee-bearing child.
>
> these would not normally be relayed, so likely transmitted out-of-band.

![image|690x388](upload://rafkktnVjdQDZMzo3yxxjsSGCah.png)

-------------------------

benunskilled | 2026-11-08 10:34:04 UTC | #13

On stratum.work, the other pools' first jobs on top of these mint blocks arrived a median 381 ms later than for normal blocks of similar size

Following my [earlier numbers](https://bnoc.xyz/t/204/10), I checked all 488 blocks from Nov 3–8. I counted 41 as mint blocks: at least 1,000 unseen transactions in mempool.space's audit, all containing UNCOMMON•GOODS mints. This wave is separate from the earlier Alkanes/DIESEL P2A wave that ended around Oct 18. Normal blocks had at most 50 unseen transactions; I left out the 12 blocks in between. 

All 41 were later than normal blocks within ±10 % in bytes. Matching the mining pool too (±15 % bytes) gave 33 of 34 later, median +339 ms. Matching transaction count instead (±30 %) gave 37 of 38 later, median +292 ms.

AntPool, F2Pool and ViaBTC showed median gaps of +376 to +406 ms; SpiderPool's was +85 ms across four blocks. For the first job carrying transactions, the size-matched gap was a median +619 ms.

![image|690x436](upload://1HDlE8z388kLkC9JBvdQdvhZGka.png)


Maxwell [measured](https://bitcointalk.org/index.php?topic=1162684.msg13127052#msg13127052) pool switch times against block size in 2015. Here the mint blocks were smaller (median 1.33 vs 1.63 MB) and still slower.

Since Nov 6, my home node (Core 32.1) had to fetch 98 kB to 1 MB of missing transactions for 29 of these blocks. The mint blocks' fees were a median 5.3 % below mempool.space's audit template, vs 0.9 % for 40 normal blocks of similar size. Rough comparison only; it doesn't show what was left out.

Across all 41 mint blocks, mints go to `bc1qq9qx0jj6glxe7dcgj98uke8yr4ze7sadt2qjgj` in 40, in blocks from all five pools, and to `bc1qmcvv20xmujhhelyas5r59gkgvl92dhdwr9v4t4` in 33, among others.

For each block H, I use the [stratum.work API](https://stratum.work/api/mining-notify?height=974558), keep jobs with H's hash as prevhash, and take each pool's first. I measure delays from the fastest pool, then take the median excluding H's miner. These are raw collector receive times, without latency correction, not pool-side times.

This is a correlation. Mint blocks have a median of about 3.4× as many transactions as size-matched normal blocks. 19 of the 41 mint blocks have more than 8,000 transactions; my largest normal block had 7,958. So I cannot fully separate unseen transactions from transaction count.

Related: 0xB10C's [reconstruction stats](https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052), instagibbs' [missing-transaction investigation](https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/56), and AtlasPool's [notification races](https://atlaspool.io/resources/articles/block-notification-speed.html).

Peer Map now shows these counts for your own node.

Does anyone with pool-side timing know where the extra time goes: the getblocktxn round trip, or validating many small transactions?

[details="All 41 mint blocks"]

| Block | Pool | tx | MB | unseen (mempool.space) | switch, ms | same-size blocks, ms (n) | delta, ms | fees below template | fetched on my node |
|---|---|--:|--:|--:|--:|--:|--:|--:|--:|
| 974,541 | AntPool | 5,355 | 1.52 | 2,227 | 690 | 415 (262) | +275 | 3.5 % | – |
| 974,549 | AntPool | 10,531 | 1.18 | 9,451 | 1153 | 308 (15) | +845 | 7.1 % | – |
| 974,557 | AntPool | 10,573 | 1.20 | 8,875 | 798 | 304 (16) | +494 | 8.9 % | – |
| 974,565 | AntPool | 9,431 | 1.22 | 8,325 | 900 | 301 (17) | +599 | 3.0 % | – |
| 974,579 | AntPool | 6,989 | 1.44 | 5,025 | 573 | 398 (129) | +176 | 7.7 % | – |
| 974,627 | AntPool | 10,484 | 1.16 | 9,875 | 906 | 295 (11) | +610 | 11.9 % | – |
| 974,751 | AntPool | 9,302 | 1.26 | 8,250 | 717 | 311 (22) | +406 | 10.6 % | – |
| 974,753 | AntPool | 9,112 | 1.51 | 8,526 | 1039 | 411 (245) | +628 | 28.5 % | – |
| 974,794 | AntPool | 8,701 | 1.33 | 6,775 | 897 | 352 (46) | +545 | 22.5 % | – |
| 974,855 | SpiderPool | 5,090 | 1.43 | 2,523 | 455 | 394 (117) | +61 | 5.4 % | – |
| 974,856 | AntPool | 2,648 | 2.83 | 1,275 | 491 | 290 (19) | +201 | 2.4 % | – |
| 974,862 | SpiderPool | 5,539 | 1.41 | 3,376 | 498 | 391 (91) | +107 | 6.4 % | 624 kB |
| 974,890 | AntPool | 8,810 | 1.24 | 7,725 | 864 | 308 (19) | +557 | 2.6 % | 714 kB |
| 974,891 | F2Pool | 4,199 | 1.47 | 2,675 | 824 | 399 (161) | +426 | 3.7 % | 306 kB |
| 974,894 | AntPool | 8,024 | 1.27 | 6,626 | 634 | 315 (25) | +319 | 2.2 % | 613 kB |
| 974,897 | F2Pool | 8,118 | 1.52 | 6,700 | 647 | 417 (260) | +230 | 17.8 % | 619 kB |
| 974,899 | ViaBTC | 9,447 | 1.16 | 8,675 | 1190 | 295 (11) | +895 | 5.3 % | 802 kB |
| 974,902 | AntPool | 7,415 | 1.30 | 5,922 | 879 | 339 (34) | +540 | 2.2 % | 547 kB |
| 974,911 | AntPool | 7,491 | 1.36 | 5,625 | 621 | 363 (64) | +259 | 5.2 % | 520 kB |
| 974,913 | TrustPool | 6,953 | 1.30 | 5,496 | 892 | 326 (30) | +566 | 0.3 % | 507 kB |
| 974,924 | AntPool | 8,587 | 1.47 | 5,226 | 890 | 399 (161) | +491 | 31.4 % | 483 kB |
| 974,934 | AntPool | 5,819 | 1.41 | 4,100 | 415 | 393 (90) | +23 | 2.2 % | 379 kB |
| 974,961 | AntPool | 11,255 | 1.10 | 10,975 | 643 | 260 (6) | +384 | 5.8 % | 1014 kB |
| 974,966 | AntPool | 11,093 | 1.10 | 11,037 | 640 | 260 (6) | +381 | 8.7 % | 1018 kB |
| 974,967 | F2Pool | 5,505 | 1.51 | 3,748 | 710 | 414 (250) | +297 | 7.5 % | 346 kB |
| 974,970 | F2Pool | 7,559 | 1.33 | 5,663 | 768 | 354 (45) | +414 | 6.3 % | 522 kB |
| 974,972 | F2Pool | 9,893 | 1.23 | 8,773 | 790 | 304 (18) | +485 | 27.3 % | 807 kB |
| 974,974 | F2Pool | 7,239 | 1.47 | 2,651 | 835 | 400 (164) | +435 | 0.4 % | 245 kB |
| 974,976 | ViaBTC | 7,535 | 1.35 | 5,049 | 1114 | 361 (58) | +754 | 0.0 % | 466 kB |
| 974,978 | F2Pool | 6,703 | 1.50 | 2,647 | 595 | 402 (215) | +192 | 2.0 % | 244 kB |
| 974,982 | F2Pool | 3,930 | 1.57 | 1,070 | 750 | 411 (294) | +339 | 5.2 % | 98 kB |
| 974,984 | ViaBTC | 9,354 | 1.24 | 7,300 | 533 | 308 (19) | +225 | 5.7 % | 675 kB |
| 974,986 | F2Pool | 7,214 | 1.37 | 5,344 | 668 | 361 (67) | +307 | 8.6 % | 493 kB |
| 974,989 | AntPool | 7,790 | 1.33 | 6,776 | 790 | 354 (49) | +435 | 2.5 % | 626 kB |
| 974,995 | SpiderPool | 3,868 | 1.53 | 1,426 | 474 | 412 (276) | +62 | 1.9 % | 132 kB |
| 974,996 | ViaBTC | 7,436 | 1.35 | 5,422 | 581 | 361 (60) | +220 | 1.1 % | 501 kB |
| 974,997 | SpiderPool | 10,539 | 1.23 | 8,400 | 444 | 304 (18) | +140 | 24.5 % | – |
| 975,005 | AntPool | 11,360 | 1.09 | 11,175 | 500 | 260 (6) | +240 | 26.0 % | 1033 kB |
| 975,009 | ViaBTC | 10,556 | 1.15 | 9,824 | 653 | 275 (9) | +378 | 2.4 % | 908 kB |
| 975,011 | AntPool | 6,975 | 1.31 | 5,062 | 691 | 345 (40) | +346 | 1.8 % | 467 kB |
| 975,028 | F2Pool | 7,262 | 1.35 | 5,251 | 850 | 361 (59) | +488 | 4.7 % | 565 kB |

[/details]

Script and data: [github.com/benunskilled/mint-switch-delay](https://github.com/benunskilled/mint-switch-delay)

-------------------------

deadmanoz | 2026-11-13 01:47:07 UTC | #14

@m4ycon your warnet simulation results, `blockreconstructionextratxn` at 100 shows 99% reconstructions without request, but isn't this the current default setting? Or, is the issue of requiring extra (round-tripped) TX data mitigated by bumping the extrapool size? I'm sure it seems a bit off to most of us that a handful of actors can have such an impact on CBR..

> these ultra-compact p2a rune minting transactions have spread to ViaBTC and F2Pool.
>
> these use a new scheme with chains of transactions paying 1 satoshi each in fees, boosted by a final fee-bearing child.
>
>these would not normally be relayed, so likely transmitted out-of-band.

Though not much can be done at the P2P level when we have direct miner submissions going on!!

-------------------------

m4ycon | 2026-11-14 03:32:44 UTC | #15

[quote="deadmanoz, post:14, topic:198"]
@m4ycon your warnet simulation results, `blockreconstructionextratxn` at 100 shows 99% reconstructions without request, but isn’t this the current default setting? Or, is the issue of requiring extra (round-tripped) TX data mitigated by bumping the extrapool size?
[/quote]

Yes, 100 is the default value for `blockreconstructionextratxn`. And yes, I tried to show that its size is directly correlated with the metric degradation, so a lazy way to mitigate this problem could be by bumping its size. But that's a good question, I really didn't described it.

My experiment shrinked things, e.g. mined block every 1 min (instead of 10), I needed some meaningful dataset and didn't want to run this for one entire day (or more) to get at this point.

Why also shrink extrapool? Extrapool is a ringbuffer, so txs "rotate" there, evicting some as others arrive. So it "forgets" about txs as time goes by if a constant rate of txs keep arriving, a tx survives for a limited period in extrapool. If I'm mining faster, it will be easier to fetch a tx from extrapool as it won't have time enough to rotate, so we shrink it to fit the simulation.

As it was an easy thing to test on my simulation, just needed to adjust a few things, I tested for about 1h20m with every node in default settings: extrapool cap at 100, mining each 10min and the default block size. It's way less blocks (8, which 2 are warmup) but the problem shows up the same way.

Notes: warmup is the phase where there's only miners and innocent nodes, and then mint, fleet and sweeper become active; Txs increases as P2A chains are lighter, so the block can fit more of them; Uses of extrapool are infered from the logs (based on mempoolrej and mempool debug logs); 30 is the number of innocent nodes.

| height | phase | txs confirmed | no request | used the extra pool | txs taken from the extra pool | txs requested |
|---:|:---|---:|---:|---:|---:|---:|
| 123 | warmup | 2,960 | 30/30 (100%) | 0/30 (0%) | 0 | 0 |
| 124 | warmup | 2,897 | 30/30 (100%) | 0/30 (0%) | 0 | 0 |
| 125 | actors | 3,861 | 8/30 (27%) | 13/30 (43%) | 309 | 645 |
| 126 | actors | 5,062 | 0/30 (0%) | 15/30 (50%) | 59 | 553 |
| 127 | actors | 5,217 | 0/30 (0%) | 4/30 (13%) | 21 | 302 |
| 128 | actors | 4,513 | 9/30 (30%) | 15/30 (50%) | 304 | 925 |
| 129 | actors | 5,311 | 0/30 (0%) | 26/30 (87%) | 174 | 762 |
| 130 | actors | 5,181 | 0/30 (0%) | 30/30 (100%) | 145 | 256 |

[quote="deadmanoz, post:14, topic:198"]
I’m sure it seems a bit off to most of us that a handful of actors can have such an impact on CBR..
[/quote]

I had the same feeling at first, but based on the idea that I described in previous comments of: P2A chains being swept; those chains depending a lot on the extrapool to be built; a relevant volume of this type of txs being relayed to the network; and my simulations. I don't think this is still a guess. You could argument that there are more factors that could impact on that, but I think this is, for now, the best candidate for the "main culprit" position.

-------------------------

