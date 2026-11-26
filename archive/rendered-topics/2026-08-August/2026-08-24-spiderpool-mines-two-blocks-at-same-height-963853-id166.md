# SpiderPool mines two blocks at same height 963853

b10c | 2026-08-24 11:50:51 UTC | #1

I happened to catch it while the split was on-going which allowed to check which of the SpiderPool blocks the pools were mining on-top of. 

Note that AntPool & Friends don't all mine on the same block here. I suspect that e.g. the Poolin endpoint is getting it's block template from a different node than e.g. AntPool is. These nodes are likely connected to each other.

![image|655x500](upload://653rjkPN4ON7v98s3wtzKEDrCxG.png)

-------------------------

b10c | 2026-08-24 13:15:53 UTC | #2

from https://x.com/mononautical/status/2091865868888367154 

![image|690x375](upload://aeLNWxcRfjEEh8ZobKWgJizVFLe.png)

-------------------------

ajtowns | 2026-08-25 12:18:12 UTC | #3

Looks like I saw `542c` (the winner, 11:28:27 timestamp) 0.36 seconds before `a108` (the loser, 11:25:04 timestamp) and took 0.77 seconds to download/reconstruct the first block and an additional 0.66 seconds to verify it? So, extremely racy, despite the different in timestamps on the blocks. Seems like the winning block might have had better compact block relay for some reason?

```
2026-08-24T11:25:51.933505Z Saw new cmpctblock header hash=000000000000000000000258f8107849bdd8b1866769633d29825e1aaffe542c height=963853 peer=158601

2026-08-24T11:25:51.934114Z [cmpctblock] Initializing PartiallyDownloadedBlock for block 000000000000000000000258f8107849bdd8b1866769633d29825e1aaffe542c using a cmpctblock of 39399 bytes
2026-08-24T11:25:52.007433Z [cmpctblock] Initialized PartiallyDownloadedBlock for block 000000000000000000000258f8107849bdd8b1866769633d29825e1aaffe542c using a cmpctblock of 39399 bytes

2026-08-24T11:25:52.294188Z Saw new header hash=00000000000000000000ec5e4ceb3434e0dff696460ae35b83e18313bf59a108 height=963853 peer=26229

2026-08-24T11:25:52.294254Z [net] Requesting block 00000000000000000000ec5e4ceb3434e0dff696460ae35b83e18313bf59a108 from peer=26229

2026-08-24T11:25:52.393411Z [cmpctblock] Initializing PartiallyDownloadedBlock for block 000000000000000000000258f8107849bdd8b1866769633d29825e1aaffe542c using a cmpctblock of 39399 bytes
2026-08-24T11:25:52.491415Z [cmpctblock] Initialized PartiallyDownloadedBlock for block 000000000000000000000258f8107849bdd8b1866769633d29825e1aaffe542c using a cmpctblock of 39399 bytes
2026-08-24T11:25:52.536975Z [cmpctblock] Initializing PartiallyDownloadedBlock for block 000000000000000000000258f8107849bdd8b1866769633d29825e1aaffe542c using a cmpctblock of 39399 bytes
2026-08-24T11:25:52.599870Z [cmpctblock] Initialized PartiallyDownloadedBlock for block 000000000000000000000258f8107849bdd8b1866769633d29825e1aaffe542c using a cmpctblock of 39399 bytes

2026-08-24T11:25:52.708319Z [cmpctblock] Successfully reconstructed block 000000000000000000000258f8107849bdd8b1866769633d29825e1aaffe542c with 1 txn prefilled, 6304 txn from mempool (incl at least 6 from extra pool) and 203 txn (29000 byte
s) requested

2026-08-24T11:25:52.898351Z [net] PeerManager::NewPoWValidBlock sending header-and-ids 000000000000000000000258f8107849bdd8b1866769633d29825e1aaffe542c to peer=119632

2026-08-24T11:25:53.561827Z UpdateTip: new best=000000000000000000000258f8107849bdd8b1866769633d29825e1aaffe542c height=963853 version=0x3fffe000 log2_work=96.330526 tx=1424200254 date='2026-08-24T11:28:27Z' progress=1.000000 cache=315.8MiB
(2381101txo)

2026-08-24T11:26:03.448163Z [net] received block 00000000000000000000ec5e4ceb3434e0dff696460ae35b83e18313bf59a108 peer=26229
```

-------------------------

b10c | 2026-09-01 20:00:41 UTC | #4

here's the stratum.work timing chart for this fork

![image|690x288](upload://aBlGvYkn0Ll0DkNZ3vH8lL1mP0y.png)

-------------------------

ajtowns | 2026-09-02 05:19:04 UTC | #5

Do you have stats available for how long various pools take to pick up new blocks more generally? WhiteBIT taking ~13s and ckpool/pyBLOCK taking ~3s both seem perhaps a little slow in this example.

-------------------------

b10c | 2026-09-02 14:36:59 UTC | #6

I haven't looked into this, but I'm also not sure how accurate the timings via stratum are. Two reasons:

- there is some network latency between the stratum endpoint and the collector. Can probably be derived from TCP latency a bit or by using multiple (time-synced) collectors in different regions 
- Some pools send out new jobs to higher-hashrate miners first. So someone just listening on jobs, but not providing hashrate, will be the last to receive job updates

-------------------------

