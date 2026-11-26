# Logs of "Mempool in non-optimal ordering after block/additions(s)"

b10c | 2026-05-12 12:33:32 UTC | #1

While chatting with @instagibbs, he mentioned we should not be seeing any `Mempool in non-optimal ordering after X` logs on a node with mempool logging turned on. 

https://github.com/bitcoin/bitcoin/blob/10ca73c02cbff59f2134c0c7da3b8d0a7e727475/src/txmempool.cpp#L225

https://github.com/bitcoin/bitcoin/blob/10ca73c02cbff59f2134c0c7da3b8d0a7e727475/src/txmempool.cpp#L384

Turns out, while grepping for it, there appear to be a few of these log messages in my logs:

```
debug.log-20260502-alice.gz:2026-05-02T10:21:57.209033Z [msghand] [mempool] Mempool in non-optimal ordering after block.
debug.log-20260502-alice.gz:2026-05-02T10:21:57.494597Z [msghand] [mempool] Mempool in non-optimal ordering after addition(s).
debug.log-20260502-alice.gz:2026-05-02T10:21:57.543092Z [msghand] [mempool] Mempool in non-optimal ordering after addition(s).
debug.log-20260502-dave.gz:2026-05-02T10:21:57.170824Z [msghand] [mempool] Mempool in non-optimal ordering after block.
debug.log-20260502-dave.gz:2026-05-02T10:21:57.428782Z [msghand] [mempool] Mempool in non-optimal ordering after addition(s).
debug.log-20260502-dave.gz:2026-05-02T10:21:57.481277Z [msghand] [mempool] Mempool in non-optimal ordering after addition(s).
debug.log-20260502-greg.gz:2026-05-02T10:21:58.480026Z [msghand] [mempool] Mempool in non-optimal ordering after block.
debug.log-20260502-greg.gz:2026-05-02T10:21:59.101458Z [msghand] [mempool] Mempool in non-optimal ordering after addition(s).
debug.log-20260502-greg.gz:2026-05-02T10:21:59.246079Z [msghand] [mempool] Mempool in non-optimal ordering after addition(s).
debug.log-20260502-kane.gz:2026-05-02T10:21:57.370745Z [msghand] [mempool] Mempool in non-optimal ordering after block.
debug.log-20260502-kane.gz:2026-05-02T10:21:58.372083Z [msghand] [mempool] Mempool in non-optimal ordering after addition(s).
debug.log-20260502-kane.gz:2026-05-02T10:21:58.387310Z [msghand] [mempool] Mempool in non-optimal ordering after addition(s).
debug.log-20260502-luke.gz:2026-05-02T10:22:00.051254Z [msghand] [mempool] Mempool in non-optimal ordering after block.
debug.log-20260502-luke.gz:2026-05-02T10:22:01.221771Z [msghand] [mempool] Mempool in non-optimal ordering after addition(s).
debug.log-20260502-luke.gz:2026-05-02T10:22:01.869515Z [msghand] [mempool] Mempool in non-optimal ordering after addition(s).
debug.log-20260502-mike.gz:2026-05-02T10:21:58.392768Z [msghand] [mempool] Mempool in non-optimal ordering after block.
debug.log-20260502-mike.gz:2026-05-02T10:21:58.591779Z [msghand] [mempool] Mempool in non-optimal ordering after addition(s).
debug.log-20260502-mike.gz:2026-05-02T10:21:58.620257Z [msghand] [mempool] Mempool in non-optimal ordering after addition(s).
debug.log-20260502-owen.gz:2026-05-02T10:21:56.400585Z [msghand] [mempool] Mempool in non-optimal ordering after block.
debug.log-20260502-owen.gz:2026-05-02T10:21:56.740554Z [msghand] [mempool] Mempool in non-optimal ordering after addition(s).
debug.log-20260502-owen.gz:2026-05-02T10:21:56.927533Z [msghand] [mempool] Mempool in non-optimal ordering after addition(s).
debug.log-20260503-alice.gz:2026-05-03T11:07:02.853936Z [msghand] [mempool] Mempool in non-optimal ordering after block.
debug.log-20260503-alice.gz:2026-05-03T22:40:04.199623Z [msghand] [mempool] Mempool in non-optimal ordering after block.
debug.log-20260503-dave.gz:2026-05-03T11:07:03.200111Z [msghand] [mempool] Mempool in non-optimal ordering after block.
debug.log-20260503-dave.gz:2026-05-03T22:40:04.808721Z [msghand] [mempool] Mempool in non-optimal ordering after block.
debug.log-20260503-greg.gz:2026-05-03T11:07:03.733736Z [msghand] [mempool] Mempool in non-optimal ordering after block.
debug.log-20260503-greg.gz:2026-05-03T22:40:07.687305Z [msghand] [mempool] Mempool in non-optimal ordering after block.
debug.log-20260503-kane.gz:2026-05-03T11:07:02.255613Z [msghand] [mempool] Mempool in non-optimal ordering after block.
debug.log-20260503-kane.gz:2026-05-03T22:40:03.207174Z [msghand] [mempool] Mempool in non-optimal ordering after block.
debug.log-20260503-luke.gz:2026-05-03T11:07:07.459751Z [msghand] [mempool] Mempool in non-optimal ordering after block.
debug.log-20260503-luke.gz:2026-05-03T22:40:11.845625Z [msghand] [mempool] Mempool in non-optimal ordering after block.
debug.log-20260503-mike.gz:2026-05-03T11:07:04.036649Z [msghand] [mempool] Mempool in non-optimal ordering after block.
debug.log-20260503-mike.gz:2026-05-03T22:40:05.604810Z [msghand] [mempool] Mempool in non-optimal ordering after block.
debug.log-20260503-owen.gz:2026-05-03T11:07:02.204334Z [msghand] [mempool] Mempool in non-optimal ordering after block.
debug.log-20260503-owen.gz:2026-05-03T22:40:03.341977Z [msghand] [mempool] Mempool in non-optimal ordering after block.
```

-------------------------

b10c | 2026-05-12 12:34:32 UTC | #2

I'm now running https://github.com/instagibbs/bitcoin/tree/nonoptimal-cluster-dump at https://github.com/instagibbs/bitcoin/commit/b36ab29fc76d72785b9815508275dffcbeef4d05 on one of the demo.peer.observer nodes to have some more data to debug this.

-------------------------

instagibbs | 2026-05-12 12:41:51 UTC | #3

Copying my comments from IRC:

```
14:42 <instagibbs> sipa b10c I think what's happening is pretty straight forward: mempool is full of \~25 count linear chain clusters, all roughly the same cfr. a block comes in, skims off a bunch of the cluster prefixes (1 or two tx each), leaving most of hte clusters still with almost a couple dozen. looks like most recent block I measured touched almost 40 such
14:42 <instagibbs> clusters, and it exhausts the DoWork budget with \~11 clusters left over.
14:44 <instagibbs> obviously it makes good progress each incantation of DoWork
```


So basically I think this could happen even in typical operation. I think seeing how often it happens and how “bad” it is is also helpful for future DoWork re-budgeting efforts that may happen.

-------------------------

b10c | 2026-05-17 22:35:47 UTC | #4

I've uploaded a few `cluster_dump_1778*.json` files to https://bitcoin-noc.github.io/datashare-website/ into the `2026-05-non-optimal-mempool-dumps` folder.

-------------------------

b10c | 2026-08-05 08:21:22 UTC | #5

I've been running https://github.com/instagibbs/bitcoin/commit/a2996f6d3d342d94e3a3e7d57b72c418383ea416 since end of may, but haven't seen any new dumps since then. My understanding is that this means the to-be-dumped clusters aren't of `ACCEPTABLE` quality.

I'll repurpose the node for something else now, but if this becomes interesting again, let me know.

-------------------------

