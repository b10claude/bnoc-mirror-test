# Invalid blocks catalogue

deadmanoz | 2026-09-23 02:21:31 UTC | #1

I've [written up some research on invalid Bitcoin blocks](https://deadmanoz.xyz/posts/2026/invalid-blocks), alongside a [catalogue of 143 established cases](https://github.com/bitcoin-data/invalid-blocks) spanning 2010 to 2026.

These are blocks that met Bitcoin's PoW requirement but failed a consensus rule. The work started with two recent F2Pool timestamp failures found in merge-mined chains, neither with a known Bitcoin-side capture. You can see both on the merge-mining monitor: [April](https://mmm.deadmanoz.xyz/?tree_window=generated&tree_from=946197&tree_to=946229&tree_height=946213&selected=00000000000000000000c3d95a4bdc068dfe0c6d1e7ad13045c6f570e58d9ed7) and [July](https://mmm.deadmanoz.xyz/?tree_window=generated&tree_from=957764&tree_to=957796&tree_height=957780&selected=0000000000000000000198e12592edbe83c84a78f75b3f8d67a3fe2075ef2ffb).

The post covers the historical failure patterns and how evidence was recovered from auxiliary chains, archived explorers and old node data, including 89 blocks carrying the same P2SH-invalid transaction in 2012.

The catalogue brings together the surviving evidence so each failure can be independently verified, even though 127 cases have no complete block body. I also emphasise the case for monitoring merge-mined chains as a source of both stale and invalid Bitcoin blocks.

I'd also welcome suggestions on [how to include and classify descendants of invalid blocks](https://github.com/bitcoin-data/invalid-blocks/issues/23). I opted to hold them out initially, but as Core treats these as invalid, they probably no different than the others, and should be included too!

-------------------------

b10c | 2026-09-24 19:29:41 UTC | #2

I had a look at my debug.logs for the two recent F2Pool invalid blocks but did not find anything. 

However, stratum.work reports a fork event for both of these:

For `00000000000000000000c3d95a4bdc068dfe0c6d1e7ad13045c6f570e58d9ed7` (946213, 2026-04-15) [stratum.work/height/946214](https://stratum.work/height/946214): 

![image|690x464](upload://kc212JyaDmOXfVuiz1agr4pq8oE.png)
![image|690x349](upload://WKvv0a5rlJggUj604hnREbhLsT.png)


For `0000000000000000000198e12592edbe83c84a78f75b3f8d67a3fe2075ef2ffb` (957780, 2026-06-29) [stratum.work/height/957781](https://stratum.work/height/957781): 

![image|690x478](upload://uZ96UpRRilt4ikJM9nfe6JKqkot.png)
![image|690x358](upload://atecUrecylhHlYPQ5i5oBmPCpmf.png)


This seems to indicate that not only F2Pool, but also e.g. SpiderPool mined on these blocks (which however didn't propagate well).

-------------------------

