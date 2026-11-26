# Increased b-msghand thread utilization due to runestone transactions on 2026-02-17

b10c | 2026-02-18 16:38:05 UTC | #1

I noticed my peer-observer nodes spending a lot of time in `b-msghand` thread today on 2026-02-17 starting around 1:30 am UTC. Note that the screenshots are UTC+1.

![image|689x396](upload://2plfoXNWKY57O4EccyUwjEY1We1.png)

(red means we spend 1000ms out of 1000ms (i.e. 100%) of our time in the thread)


Around the same time, the mempools started to fill up from around 6% to 60%

![image|690x285](upload://hNx1H943gZ8wFTkKT0lOiD5iiOH.png)

and the sum(inv-to-send) sizes across all peers increased significantly. To about 1.7 M on some nodes.

![image|690x381](upload://24p0Ey7oYkcNBYuds0qjcYAY6Xr.png)


with the maxium inv-to-send sizes being about 60k

![image|690x405](upload://szhnCXzyzD51KSIEAsJUDezYsDq.png)


edit: It was also visible in the Bitcoin protocol Ping-Pong time monitoring I do on localhost:

![image|690x455](upload://tMJn2uR3QBvngSZ2xnJ64qbVoIY.png)


---

Randomly sampling from some of the transactions my nodes saw:
- https://www.oklink.com/bitcoin/tx/cc472d9cec6a8155de69e610f6ad7981040b324c2b3141eec208f55333f6364b/transfer
- https://www.oklink.com/bitcoin/tx/a9dcfedaf4771950f9d384dabf45a3556764a41145f638c46140990603d3a4e5/transfer
- https://www.oklink.com/bitcoin/tx/8b9e4a4c7e4a77c9c6f05f18ac3407c5aa02517d9b55e74ba653c846f57d8179/transfer


All include a UNCOMMON•GOODS rune, some also inscriptions, and NFT related content.

-------------------------

b10c | 2026-02-17 21:06:12 UTC | #2

Interestingly, the last time I noticed this was also on a 17th: https://bnoc.xyz/t/increased-b-msghand-thread-utilization-due-to-many-352-byte-runestone-inscriptions-on-2025-11-17/58

-------------------------

b10c | 2026-02-17 21:14:42 UTC | #3

Another broadcast happend at 17:20 UTC

![image|690x440](upload://7W24bsUopevS4BjpuqY8xqlLt5m.png)


![image|690x440](upload://6c1mOhjMcMr6hQtBBHm3Ak2kUM7.png)

-------------------------

b10c | 2026-02-17 21:19:34 UTC | #4

Here's a snapshot of the continues profiling flamegraphs I've been experimenting with from the 1:30am broadcast: https://pprof.me/442e174f4a5d11019fe0f152b64f6ca8/

It doesn't show anything too suspicious I think. The `getrawaddrman` RPC taking long is known to me, but unrelated to this.

-------------------------

b10c | 2026-02-17 21:28:59 UTC | #5

Looking on a different node at the broadcast at around 17:20 UTC shows that we spend about 20% of our time in `CompareMiningScoreWithTopology()` (i.e. the new name of `CompareDepthAndScore`). 

![image|690x337](upload://wbd9wPeyse00b3uYIpaqcWDk9kO.png)

Would one possibility be to have the inv-to-send sets always sorted from the beginning to avoid doing it every time we decide to INV something?

-------------------------

ajtowns | 2026-02-17 23:50:51 UTC | #6

[quote="b10c, post:5, topic:81"]
Would one possibility be to have the inv-to-send sets always sorted from the beginning to avoid doing it every time we decide to INV something?

[/quote]

Sorting before sending ensures that you’re not leaking info about the order in which you received the txs by the order in which you announce them.

I think have a global queue for rate limiting outbound announcements is the solution here, fwiw. Here’s a gist:

https://gist.github.com/ajtowns/d61bea974a07190fa6c6c8eaef3638b9

I've been running that code with a very low rate limit for inbounds (4tx/s instead of the 14tx/s target from core) to ensure it behaves well when backlogs occur, and it seems to.

-------------------------

b10c | 2026-02-18 00:00:55 UTC | #7

To add: here are the transaction inv-sizes to a local spy-node-like peer (does not INV any transactions to the node). 

![grafik|690x334](upload://6IH2ULeuN8qxeextNirNr4OM3Ja.png)


And here is the rate at which my local spy-node-like peer received WTx invs.

Normally, one would expect the rate at which we send INVs to remain fairly constant since we're on a fixed timer. However, it seems like for some nodes it actually slowed INV-sending down by about 50% while for others it (at least briefly) speed up. My theory for slowing down is: the node is overloaded to a point where it can't send out INVs at a normal rate. 


![grafik|690x444](upload://fB9G9YPVdPuizoe1sKYeaeergym.jpeg)

-------------------------

b10c | 2026-02-18 00:14:19 UTC | #8

[quote="ajtowns, post:6, topic:81"]
[quote="b10c, post:5, topic:81"]
Would one possibility be to have the inv-to-send sets always sorted from the beginning to avoid doing it every time we decide to INV something?
[/quote]

Sorting before sending ensures that you’re not leaking info about the order in which you received the txs by the order in which you announce them.
[/quote]

Sure. I think I wasn't clear in my description: Don't keep a set (as we do currently), but keep a (sorted) queue. When inserting a to-be-announced transaction, put it in the right place in the queue. This avoids having to re-sort the whole set every 5s (or 2s for outbounds) for each peer. The queue is already sorted, so we can just pick the top 70 + x transactions to INV. Then, do some clean up removing evicted/confirmed transactions by iterating the queue once.


Maybe that's similar to you gloabl queue. I'll have a look.

-------------------------

ajtowns | 2026-02-19 03:14:35 UTC | #9

[quote="b10c, post:8, topic:81"]
Sure. I think I wasn’t clear in my description: Don’t keep a set (as we do currently), but keep a (sorted) queue.
[/quote]

As far as data structures go, a sorted queue is best stored as a set anyway; problem is that with cluster mempool the sort order doesn't stay consistent as txs are added -- a cpfp tx can bump the ordering of the pre-existing parent, eg. That breaks set invariants, so risks UB if using `std::set`, and I couldn't see a simpler way of dealing with it properly without just doing a re-sort.

-------------------------

ajtowns | 2026-02-20 05:31:15 UTC | #10

Cleaned up the code, added tests etc, and PRed as:

https://github.com/bitcoin/bitcoin/pull/34628

-------------------------

b10c | 2026-03-12 09:52:01 UTC | #11

There seems to have been a small mass-broadcast event a few hours ago. Here are some observations:

On `bob`, running #34628 with default `txsendrate`, the inv-to-send queues stayed a lot smaller. This is expected as we drain the per-peer queue immediately with 34628.

![image|680x500](upload://gGcLBTfXiwRqjPsUgVSMhKXD8R4.png)

On `bob`, we spend a lot less time in the `b-msghand` thread:

![image|690x254](upload://hTb8dlfWEGbZHxGk0yGvofYk908.png)

And the response time for a localhost `ping` didn't increase for `bob`, while it did for the other nodes.

![image|690x345](upload://erJOUf3QxYeuSfqeG4RIqCbzzCW.png)

The INVs sent by `bob` were larger than the ones by the other nodes. With 34628, we fully drain the per-peer queue, so INVs can be larger than before, were we capped it at 70 (unless the queue got large). 

![image|690x340](upload://rGpMoBEkkf0SYeF4OeKUbWYZrel.jpeg)

-------------------------

ajtowns | 2026-03-12 12:51:50 UTC | #12

[quote="b10c, post:11, topic:81"]
[
image1215×609 123 KB
](https://bnoc.xyz/uploads/default/original/1X/654127fe5799f79ea49ebbc75eaee56895a37052.png)

The INVs sent by `bob` were larger than the ones by the other nodes.
[/quote]

Double-size INVs might not be verymeaningful -- when there's a backlog with #34628 the timing can be out of sync, acting like "send-inv, send-inv, populate-inv-queue, populate-inv-queue, send-inv", so that the second send-inv is empty, and the third send-inv has to tranches of txs. Because populate-inv-queue targets a particular tx rate, send-inv over time should still average to the same 70tx-per-send-inv rate, even though individual send-inv's can be two (or more) times that.

Are you able to do a rolling-average over 30s or 60s for that graph by any chance? I think that should bring the outgoing inv rates in line with each other.

-------------------------

b10c | 2026-03-12 22:12:34 UTC | #13

I have "number of WTx entries send per second, averaged over 60s". Note that these are to an `-addnode` peer (outbound), so we send INVs every two seconds.

![image|655x500](upload://96ZzQ6gdmP2bLlxvodRRs3jy07h.jpeg)

-------------------------

b10c | 2026-03-13 08:47:32 UTC | #14

Node `jade` also runs the patch and is using the new `-txsendrate=4` arg. During the mass broadcast, we see it announcing 10 transactions per second to the outbound addnode peer. `-txsendrate` is configuring the relay rate to inbound connections. As we relay to oubounds at 2.5x the rate, we'd expect 2.5 * 4 = 10, which exactly matches our expectation.

It's visible that node `jade` takes a lot longer than the other nodes to process the annoucements.


![image|690x310](upload://3zMYmFMkjO5HWg4Sgi9AyA5RiqY.jpeg)

-------------------------

ajtowns | 2026-03-13 14:52:26 UTC | #15

Is jade also avoiding high b-msghand thread time? If so, it's behaving as expected: 4tx/s is too slow for mainnet for inbound connections (5000tx/block is about 8 tx/s), so it's mostly a good way of observing the backlog behaviour, rather than something sensible to run.

The 'rate of WTx over 60s' graph looks good to me. Interesting that the floor rose (~2tx/s between 3:10 and 3:20 vs 5tx/s between 3:40 and 3:50).

-------------------------

b10c | 2026-03-23 11:00:40 UTC | #16

[quote="ajtowns, post:15, topic:81"]
Is jade also avoiding high b-msghand thread time?
[/quote]

yes! Though `jade` also has a stronger and different CPU that the others, so the numbers aren't directly comparable.

Looking at a recent event, now that the inbound slots on `bob` have filled up fully, it's visible that the time we spend in `b-msghand` is mostly transaction validation, but not transaction propagation anymore. On the other nodes, we have a higher `b-msghand` utilization for longer, as we first do transaction validation and then the expensive transaction propagation.

![grafik|690x421](upload://cKiJhxeOEYkW0B7dtkcs9QZ91vQ.jpeg)

-------------------------

