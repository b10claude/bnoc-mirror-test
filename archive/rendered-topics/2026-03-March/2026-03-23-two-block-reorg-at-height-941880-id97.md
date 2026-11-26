# Two block reorg at height 941880

b10c | 2026-03-24 10:26:07 UTC | #1

We just had a rare-ish two block reorg where Foundry mined a couple of blocks in a row winning a two block long race against AntPool and ViaBTC.

![image|690x322](upload://vhWudm9A2SmGWG6dPQyVn9X3UIt.png)

Foundry ended up mining seven blocks in a row:

![image|690x160](upload://r4xHQMDVLQCvIUg3jQeQsglAH9C.png)

The stale blocks are:

```
00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 (AntPool) at height 941881
00000000000000000000c81cbf94a12ca498e72eb8530f7061c8746cf9687b2e (ViaBTC) at height 941882
```

While Foundry mined the following blocks to win the race:

```
00000000000000000000bd4930a5982911e7749eb491886206e71abdc1ec0cc6 (Foundry) at height 941881
00000000000000000000724eac69a18c6699c9f7aaab24bcf18beb2723ccadd2 (Foundry) at height 941882
000000000000000000009c9acd0bc3207fa181f79f8573bf27d8a81d1ef3aa8e (Foundry) at height 941883
```

-------------------------

jungly | 2026-03-23 16:43:27 UTC | #2

Can you share the timestamps on those blocks or even the headers if possible? Am wonder if this was a result of network latency?

-------------------------

b10c | 2026-03-23 16:58:28 UTC | #3

Welcome!

I just added the headers and full blocks to the stale-block dataset: https://github.com/bitcoin-data/stale-blocks/pull/90

Will check the arrival times on those four too.

-------------------------

murchandamus | 2026-03-23 16:56:56 UTC | #4

You can see them on [fork.observer](https://fork.observer), just click the blocks for details:

Stale chaintip:
941881 — 1774280975
941882 — 1774281079

Best chain:
941881 — 1774280987
941882 — 1774281085

Note that the timestamps only need to be accurate within ±2h, so more interesting would be the arrival times instead of the timestamps.

![image|690x279](upload://zXfglRzH4ols5bVHnfK1gtNSPZ7.png)

-------------------------

b10c | 2026-03-23 17:07:49 UTC | #5

I found it interesting that boerst's stratum-work did not see any stratum jobs from Foundry mining on their winning blocks. See e.g. [941882 on stratum.work](https://stratum.work/height/941882). 

Maybe they were only mining on them in one region, and stratum-work is connected to a different one, or they kept quite about them (i.e. selfish mining), or it's a bug on stratum-work :slight_smile:

-------------------------

jungly | 2026-03-23 19:53:03 UTC | #7

Yup, I am just hoping these pool operators are running sensible clocks - if not using ntp.

I looked into this cause I am interested in the uncles probability in p2poolv2. If we look at the fork monitor, it looks like if blocks are within 15-30 seconds of each other it results in a fork. This makes me think if we can get the mean/stddev on the fork blocks timestamps deltas Again, assuming clock drift is not too high.

It’ll be fascinating to see how this delta changes between different pairs of pools. Detect friends and enemies :slight_smile:

-------------------------

b10c | 2026-03-23 20:56:04 UTC | #8

There is data on block arrival times and block header timestamps in https://github.com/bitcoin-data/block-arrival-times if you want to compare it over time.

@willcl-ark recently shared this plot with me showing 12s-21s deltas on average:

![grafik|690x246](upload://iOVTlW9H85gf0uXqh4WI3OdQyhV.jpeg)


(which makes sense since most pools send out new jobs to miners in 30s intervals)

-------------------------

jungly | 2026-03-23 23:19:41 UTC | #9

Yeah, but they should also send a new job immediately on seeing a new block. Unless of course there are some strategies they use to detect how to react to blocks from different pools. Might be interesting to uncover :slight_smile:

Thanks for that link to the data. We don’t see the pool name there, right? Do you think we can include that for the data from now on? Or it might be in another data set somewhere that I can join. We want to get the pool names for the orphan blocks too.

Sorry, am new to all your work, so probably asking naive questions.

EDIT: Just this: https://bnoc.xyz/t/offer-stale-block-dataset/13

-------------------------

ajtowns | 2026-03-24 00:31:06 UTC | #10

[quote="b10c, post:1, topic:97"]
We just had a rare-ish two block reorg
[/quote]

Per the stale-block repo, previous known two block stale chains:

 * 788687 / 788686 - 2023-05-08 ; 153k blocks ago
 * 656478 / 656477 - 2020-11-12 ; 132k blocks earlier
 * 358999 / 358998 - 2015-06-02 ; 300k blocks earlier
 * 261199 / 261198 - 2013-10-02 ; 98k blocks earlier

So perhaps every ~3 years or 150k blocks?

I'm not sure what the maths would be to figure out what to expect there -- naively I would have thought you'd square the frequency of one-block reorgs (since you need two blocks in a row to be found almost simultaneously to avoid everyone agreeing on a single tip) which would lead to expecting about a million blocks between 2-block reorgs if we're seeing 1-block reorgs every thousand blocks, but perhaps you get different results if you model internal delays getting jobs/work distributed between the pool and ASICs separately from network block propagation. 

My timings for the headers in question were:

```
2026-03-23T15:49:53.982265Z Saw new cmpctblock header hash=00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 height=941881 peer=14899 peeraddr=45.32.83.173:54302
2026-03-23T15:51:47.008245Z Saw new header hash=00000000000000000000c81cbf94a12ca498e72eb8530f7061c8746cf9687b2e height=941882 peer=38718 peeraddr=124.156.199.113:36184
2026-03-23T15:55:03.500660Z Saw new header hash=000000000000000000009c9acd0bc3207fa181f79f8573bf27d8a81d1ef3aa8e height=941883 peer=36252 peeraddr=65.109.99.249:35498
```

I didn't see Foundry's racing blocks until the reorg. (Which might suggest that 1-block stale blocks are much more common than 1-in-a-thousand, but they just aren't visible)

-------------------------

boerst | 2026-03-24 01:13:54 UTC | #11

FWIW, I’m not collecting Foundry’s templates on https://stratum.work/ - I could never get a working account from them.

From the pools that I do collect, I can see that none of the other pools were sending work building on top of Foundry’s 941881 and 941882 blocks. Everyone else was seemingly following the AntPool/ViaBTC chain.

-------------------------

b10c | 2026-03-24 15:17:07 UTC | #12

Thanks for clarifying. My Foundry stratum endpoint doesn't seem to work either. I and I don't see Foundry listed on [mempool.space/stratum](https://mempool.space/stratum) either.

-------------------------

b10c | 2026-03-26 08:36:50 UTC | #13

I looked a bit at the header and block arrival times in the debug.logs of my monitoring nodes. Here, "header" means we either got an INV for this block, saw a `cmpctblock` or a header. Full block means we  received the block or successfully reconstructed the block from a compact block. 

```
                               node           block       event
timestamp                                                      
2026-03-23 15:49:53.864840      ian  941881 AntPool      header
2026-03-23 15:49:53.903500     dave  941881 AntPool      header
2026-03-23 15:49:53.965877     jade  941881 AntPool      header
2026-03-23 15:49:53.972246      ian  941881 AntPool  full_block
2026-03-23 15:49:53.976826     mike  941881 AntPool      header
2026-03-23 15:49:54.029989     owen  941881 AntPool      header
2026-03-23 15:49:54.057771     jade  941881 AntPool  full_block
2026-03-23 15:49:54.133473     owen  941881 AntPool  full_block
2026-03-23 15:49:54.239330  charlie  941881 AntPool      header
2026-03-23 15:49:54.241502      bob  941881 AntPool      header
2026-03-23 15:49:54.256592     nico  941881 AntPool      header
2026-03-23 15:49:54.350779    frank  941881 AntPool      header
2026-03-23 15:49:54.356334    alice  941881 AntPool      header
2026-03-23 15:49:54.400475     greg  941881 AntPool      header
2026-03-23 15:49:54.446445     erin  941881 AntPool      header
2026-03-23 15:49:54.457890      bob  941881 AntPool  full_block
2026-03-23 15:49:54.582114    hazel  941881 AntPool      header
2026-03-23 15:49:54.600324  charlie  941881 AntPool  full_block
2026-03-23 15:49:54.604217     mike  941881 AntPool  full_block
2026-03-23 15:49:54.612627     nico  941881 AntPool  full_block
2026-03-23 15:49:54.715069     dave  941881 AntPool  full_block
2026-03-23 15:49:54.764564     greg  941881 AntPool  full_block
2026-03-23 15:49:54.812221     kane  941881 AntPool      header
2026-03-23 15:49:54.824742     luke  941881 AntPool      header
2026-03-23 15:49:54.893326     erin  941881 AntPool  full_block
2026-03-23 15:49:55.037321    hazel  941881 AntPool  full_block
2026-03-23 15:49:55.238127    frank  941881 AntPool  full_block
2026-03-23 15:49:55.440619     luke  941881 AntPool  full_block
2026-03-23 15:49:56.627557    alice  941881 AntPool  full_block
2026-03-23 15:49:57.215005     kane  941881 AntPool  full_block
2026-03-23 15:51:47.052497     nico   941882 ViaBTC      header
2026-03-23 15:51:47.058206    alice   941882 ViaBTC      header
2026-03-23 15:51:47.061556  charlie  941881 Foundry      header
2026-03-23 15:51:47.069931     luke   941882 ViaBTC      header
2026-03-23 15:51:47.078155     greg   941882 ViaBTC      header
2026-03-23 15:51:47.079686     jade   941882 ViaBTC      header
2026-03-23 15:51:47.082866      bob  941881 Foundry      header
2026-03-23 15:51:47.083817    alice   941882 ViaBTC  full_block
2026-03-23 15:51:47.085359      ian   941882 ViaBTC      header
2026-03-23 15:51:47.087298     mike   941882 ViaBTC      header
2026-03-23 15:51:47.092817  charlie   941882 ViaBTC      header
2026-03-23 15:51:47.098123     erin   941882 ViaBTC      header
2026-03-23 15:51:47.101483    frank   941882 ViaBTC      header
2026-03-23 15:51:47.102551     jade   941882 ViaBTC  full_block
2026-03-23 15:51:47.103210      ian   941882 ViaBTC  full_block
2026-03-23 15:51:47.110371      bob   941882 ViaBTC      header
2026-03-23 15:51:47.118183     owen   941882 ViaBTC      header
2026-03-23 15:51:47.128487     nico   941882 ViaBTC  full_block
2026-03-23 15:51:47.130324     kane   941882 ViaBTC      header
2026-03-23 15:51:47.132378     greg   941882 ViaBTC  full_block
2026-03-23 15:51:47.133369     mike   941882 ViaBTC  full_block
2026-03-23 15:51:47.152286     owen   941882 ViaBTC  full_block
2026-03-23 15:51:47.160858     erin   941882 ViaBTC  full_block
2026-03-23 15:51:47.163834  charlie   941882 ViaBTC  full_block
2026-03-23 15:51:47.175300     kane   941882 ViaBTC  full_block
2026-03-23 15:51:47.195791    hazel   941882 ViaBTC      header
2026-03-23 15:51:47.238768     dave   941882 ViaBTC      header
2026-03-23 15:51:47.244357      bob   941882 ViaBTC  full_block
2026-03-23 15:51:47.247765    frank   941882 ViaBTC  full_block
2026-03-23 15:51:47.263158    hazel   941882 ViaBTC  full_block
2026-03-23 15:51:47.536036     dave  941881 Foundry      header
2026-03-23 15:51:47.767039     greg  941881 Foundry      header
2026-03-23 15:51:48.526856     dave   941882 ViaBTC  full_block
2026-03-23 15:51:50.377779     luke   941882 ViaBTC  full_block
2026-03-23 15:55:00.641682      bob  941883 Foundry      header
2026-03-23 15:55:01.176160  charlie  941882 Foundry      header
2026-03-23 15:55:01.191329     dave  941882 Foundry      header
2026-03-23 15:55:01.370924      bob  941882 Foundry  full_block
2026-03-23 15:55:01.370934     greg  941882 Foundry      header
2026-03-23 15:55:01.429284     owen  941882 Foundry      header
2026-03-23 15:55:01.711011     greg  941883 Foundry      header
2026-03-23 15:55:01.714383      ian  941883 Foundry      header
2026-03-23 15:55:01.778498    alice  941883 Foundry      header
2026-03-23 15:55:01.780852     owen  941883 Foundry      header
2026-03-23 15:55:01.816236      bob  941883 Foundry  full_block
2026-03-23 15:55:02.773480     mike  941883 Foundry      header
2026-03-23 15:55:03.360435  charlie  941883 Foundry      header
2026-03-23 15:55:03.491469     owen  941883 Foundry  full_block
2026-03-23 15:55:03.542388      ian  941881 Foundry  full_block
2026-03-23 15:55:03.698902     luke  941883 Foundry      header
2026-03-23 15:55:03.716347     nico  941881 Foundry      header
2026-03-23 15:55:03.716464     nico  941882 Foundry      header
2026-03-23 15:55:03.716509     nico  941883 Foundry      header
2026-03-23 15:55:04.374432  charlie  941883 Foundry  full_block
2026-03-23 15:55:04.456908     dave  941883 Foundry      header
2026-03-23 15:55:04.973663     jade  941883 Foundry      header
2026-03-23 15:55:05.439823    frank  941883 Foundry      header
2026-03-23 15:55:05.886777     erin  941881 Foundry      header
2026-03-23 15:55:05.886891     erin  941882 Foundry      header
2026-03-23 15:55:05.886936     erin  941883 Foundry      header
2026-03-23 15:55:06.085654     dave  941883 Foundry  full_block
2026-03-23 15:55:06.374803     erin  941881 Foundry  full_block
2026-03-23 15:55:06.747076     erin  941882 Foundry  full_block
2026-03-23 15:55:06.801136     mike  941881 Foundry  full_block
2026-03-23 15:55:07.071938     erin  941883 Foundry  full_block
2026-03-23 15:55:07.172630    hazel  941883 Foundry      header
2026-03-23 15:55:07.231769     nico  941881 Foundry  full_block
2026-03-23 15:55:07.351077     mike  941882 Foundry  full_block
2026-03-23 15:55:07.901623     mike  941883 Foundry  full_block
2026-03-23 15:55:08.888249     nico  941882 Foundry  full_block
2026-03-23 15:55:09.346723    hazel  941881 Foundry  full_block
2026-03-23 15:55:09.965627     jade  941881 Foundry  full_block
2026-03-23 15:55:10.133469    hazel  941882 Foundry  full_block
2026-03-23 15:55:10.326101     nico  941883 Foundry  full_block
2026-03-23 15:55:10.670198    hazel  941883 Foundry  full_block
2026-03-23 15:55:10.681589     kane  941883 Foundry      header
2026-03-23 15:55:11.418276      ian  941882 Foundry  full_block
2026-03-23 15:55:13.304834     greg  941883 Foundry  full_block
2026-03-23 15:55:14.318127     jade  941882 Foundry  full_block
2026-03-23 15:55:16.414858      ian  941883 Foundry  full_block
2026-03-23 15:55:17.683597     jade  941883 Foundry  full_block
2026-03-23 15:55:17.998145    alice  941881 Foundry  full_block
2026-03-23 15:55:19.254253     luke  941881 Foundry  full_block
2026-03-23 15:55:20.573447     kane  941881 Foundry  full_block
2026-03-23 15:55:22.239878    alice  941882 Foundry  full_block
2026-03-23 15:55:24.322924    alice  941883 Foundry  full_block
2026-03-23 15:55:25.850183    frank  941881 Foundry  full_block
2026-03-23 15:55:27.524423     kane  941882 Foundry  full_block
2026-03-23 15:55:28.616653     luke  941882 Foundry  full_block
2026-03-23 15:55:29.847000    frank  941882 Foundry  full_block
2026-03-23 15:55:31.190630    frank  941883 Foundry  full_block
2026-03-23 15:55:32.942391     kane  941883 Foundry  full_block
2026-03-23 15:55:34.202208     luke  941883 Foundry  full_block
2026-03-23 16:01:48.751482  charlie  941881 Foundry  full_block
2026-03-23 16:01:49.014432     dave  941881 Foundry  full_block
2026-03-23 16:01:49.573302  charlie  941882 Foundry  full_block
2026-03-23 16:01:50.206303     dave  941882 Foundry  full_block
2026-03-23 16:01:54.667334      bob  941881 Foundry  full_block
2026-03-23 16:05:03.395825     owen  941881 Foundry  full_block
2026-03-23 16:05:04.331536     greg  941881 Foundry  full_block
2026-03-23 16:05:04.384588     owen  941882 Foundry  full_block
2026-03-23 16:05:05.058914     greg  941882 Foundry  full_block
```

I created the following plot from this.

![image](upload://xKuGJRODiYu4n4Yj50DTQPkManJ.png)

My interpretation of this is:
- I received the headers and blocks for 941881 AntPool (red) on all nodes at roughly the same time.
- I did not hear about a header or block of 941881 Foundry (blue).
- Then, the ViaBTC block and Foundry block 941882 (green) were mined.
- I learned about ViaBTCs header and block (orange) on all nodes at roughly the same time. I did not learn about Foundry block 941882 (green).
- At the same time, I learned about 941881 Foundry (blue) headers on node `greg`, `bob`, `charlie`, `dave`.  I did not learn about the full block.
- At a later time, Foundry 941883 (purple, the winning block) was mined and I learned about he Foundry headers and blocks 
- On some nodes (e.g. `owen` and `greg`), I only learned about the full Foundry blocks >5min later.

-------------------------

zawy12 | 2026-03-24 16:46:09 UTC | #14

Foundry released their 1st block (header) immediately after the others’ 2nd block was found. According to their own timestamp on their 1st and 2nd blocks, they found them a few seconds after the others’ 1st and 2nd blocks.  They released their 2nd and 3rd at the same time, exactly when the 3rd block was found, winning the race.  This is effectively a selfish-mining attack by definition even if it was on “accident” or network hiccup (to the extent “attack” doesn’t imply intentional).  But it all seems to point to intentional.

Intentional or not, other miners should ignore 2 of Foundry’s blocks. Without enforcing accurate timestamps, this how selfish mining can be made a “nothing burger”. >50% needs to collude to disincentivize future attacks. If Foundry stops displaying it’s name to prevent this, the only solution is to enforce more accurate timestamps. For example, the rule would be to ignore a header for 600 seconds if its timestamp is more than 15 seconds different from local time (rounded to the nearest 10 s interval) when it arrives. This works because the attacker has to assign a timestamp before he knows when he will need to release it. People complain that this can cause a real problem in real network partitions and it’s true a chain split would last longer if that’s the case, but it will eventually resolve itself based on PoW and which partition has the most hashrate. Rounding to the nearest 10 second interval prevents an attack on the interval. Clocks shouldn’t be off more than 2 seconds which is the other big complaint. Also, miners would have to update the timestamp every 2 seconds.

Concerning not being able to get Foundry’s templates, Grok says:

Yes, restricting public or easy access to block templates can serve Foundry (or any large pool) if they were engaging in illicit or strategically deviant behavior like selfish mining or block withholding—primarily by reducing detectability and transparency.

-------------------------

jungly | 2026-03-25 09:15:39 UTC | #16

[quote="zawy12, post:14, topic:97"]
This is effectively a selfish-mining attack by definition even if it was on “accident” or network hiccup (to the extent “attack” doesn’t imply intentional). But it all seems to point to intentional.

[/quote]

Yup. I have reached the same conclusion. Happy to see you are thinking along the same lines.

-------------------------

murchandamus | 2026-03-25 19:58:12 UTC | #17

@b10c, it would also be interesting to see this chart split by mining pool. I wonder whether some mining pools that time-roll would have a distinctly different pattern than pools that don’t. Also, I was curious how accurate timestamps of the involved pools are, i.e., whether the timestamps on these concrete competing blocks would lend credence to the idea that Foundry happened to actually find both their blocks right after the competing block as the timestamps seem to hint.

-------------------------

matthias | 2026-03-25 21:00:25 UTC | #18

I looked at the arrival times of the inv messages corresponding to these blocks at one of our [monitor nodes](https://www.dsn.kastel.kit.edu/bitcoin/). These monitor nodes receive and log inv messages but do not request the data for headers or blocks.

The following list of blocks contains in the first column the point in time at which the monitor received the first inv message for a certain block. The last column shows the number of peers from which the monitor node received the inv message.

```
23.03.2026 15:49:53.731	AntPool	 941881	inv	9914
23.03.2026 15:49:56.669	Foundry	 941881	inv	36
23.03.2026 15:51:46.992	ViaBTC 	 941882	inv	9904
23.03.2026 15:55:00.579	Foundry	 941883	inv	8183
23.03.2026 15:55:05.038	Foundry	 941882	inv	26
23.03.2026 16:02:30.817	Foundry	 941884	inv	9087
```

There are two interesting aspects:

* An announcement for Foundry’s block at height 941881 was received before any announcement for a block at height 941882 was received.
* The monitor node received announcements for Foundry’s blocks at heights 941881 and 941882 only from a few peers. I don’t have an idea why. I would expect that nearly all peers should announce these blocks once they become part of the active chain.
  EDIT: The majority of nodes announcing these blocks has in common that they announce btcd as their user agent. It seems that Bitcoin Core does not send inv messages for these blocks to our monitor.

-------------------------

davidgumberg | 2026-03-26 18:29:17 UTC | #19

Looking at debug logs for one of @achow101's node which was stalled from reorging to the foundry chain until \~16:05, I constructed the following table of events:


| Time         | Block     | Msg/Action | From Peer | To Peer |
|--------------|-----------|----------- |-----------|---------|
| 15:49:53.834 | Antpool 1 | INV | 199 |  |
| 15:49:53.835 | Antpool 1 | GETHEADERS |  | 199 |
| 15:49:54.176 | Antpool 1 | HEADERS | 3952229 |  |
| 15:49:54.176 | Antpool 1 | GETDATA |  | 3952229 |
| 15:49:54.282 | Antpool 1 | CMPCTBLOCK | 3 |  |
| 15:49:54.305 | Antpool 1 | GETBLOCKTXN |  | 3 |
| 15:49:54.356 | Antpool 1 | CMPCTBLOCK | 3952229 |  |
| 15:49:54.379 | Antpool 1 | GETBLOCKTXN |  | 3952229 |
| 15:49:54.425 | Antpool 1 | BLOCKTXN | 3 |  |
| 15:49:54.433 | Antpool 1 | CMPCTBLOCK Reconstructed | 3 |  |
| 15:49:54.723 | Antpool 1 | Update Tip |  |  |
| 15:50:01.464 | Foundry 1 | INV | 199 |  |
| 15:50:01.464 | Foundry 1 | GETHEADERS |  | 199 |
| 15:51:47.071 | Antpool 2 | INV | 199 |  |
| 15:51:47.071 | Antpool 2 | GETHEADERS |  | 199 |
| 15:51:47.075 | Antpool 2 | CMPCTBLOCK | 1271642 |  |
| 15:51:47.08  | Antpool 2 | HEADERS | 1271642 |  |
| 15:51:47.079 | Antpool 2 | CMPCTBLOCK Reconstructed |  |  |
| 15:51:47.176 | Antpool 2 | UpdateTip | 1271642 |  |
| 15:51:47.270 | Foundry 1 | HEADERS | 199 |  |
| 15:55:01.161 | Foundry 2 | INV | 199 |  |
| 15:55:01.161 | Foundry 2 | GETHEADERS |  | 199 |
| 15:55:01.358 | Foundry 3 | INV | 199 |  |
| 15:55:01.583 | Foundry 2 | HEADERS | 199 |  |
| 15:55:01.583 | Foundry 1 | GETDATA |  | 199 |
| 15:55:01.583 | Foundry 2 | GETDATA |  | 199 |
| 15:55:06.356 | Foundry 3 | HEADERS | 8302907 |  |
| 15:55:06.356 | Foundry 3 | GETDATA | 8302907 |  |
| 15:55:07.295 | Foundry 3 | BLOCK | 8302907 |  |
| 16:02:30.919 | Main 4    | INV | 199 |  |
| 16:02:30.920 | Main 4    | GETHEADERS |  | 199 |
| 16:02:30.970 | Main 4    | HEADERS | 6312471 |  |
| 16:02:30.970 | Main 4    | GETDATA | 6312471 |  |
| 16:02:31.324 | Main 4    | CMPCTBLOCK | 1283269 |  |
| 16:02:31.342 | Main 4    | GETBLOCKTXN |  | 1283269 |
| 16:02:32.049 | Main 4    | BLOCKTXN | 1283269 |  |
| 16:02:32.049 | Main 4    | CMPCTBLOCK Reconstructed |  |  |
| 16:04:49.393 | Main 5    | INV | 199 |  |
| 16:04:49.393 | Main 5    | GETHEADERS |  | 199 |
| 16:04:49.595 | Main 5    | HEADERS | 4392345 |  |
| 16:04:49.595 | Main 5    | GETDATA |  | 4392345 |
| 16:04:50.220 | Main 5    | BLOCK |  | 4392345 |
| 16:05:01.590 | Foundry 1 | Block stall timeout, disconnect peer | 199 |  |
| 16:05:01.612 | Foundry 1 | GETDATA |  | 8302907 |
| 16:05:01.612 | Foundry 2 | GETDATA |  | 8302907 |
| 16:05:02.593 | Foundry 1 | BLOCK | 8302907 |  |
| 16:05:03.322 | Foundry 2 | BLOCK | 8302907 |  |
| 16:05:03.434 | Antpool 2 | Block Disconnected |  |  |
| 16:05:03.844 | Foundry 1 | Update Tip |  |  |
| 16:05:04.065 | Foundry 2 | Update Tip |  |  |
| 16:05:04.355 | Foundry 3 | Update Tip |  |  |
| 16:05:04.425 | Antpool 1 | Block Disconnected |  |  |
| 16:05:08.862 | Main 4    | Update Tip |  |  |
| 16:05:09.152 | Main 5    | Update Tip |  |  |


<details>

<summary>Table with full log messages</summary>

| Time | Block | Msg/Action | From Peer | To Peer | Log message |
|----|----|----|----|----|----|
| 15:49:53.834 | Antpool 1 | INV | 199 |  | 2026-03-23T15:49:53.834333Z \[msghand\] \[../../src/net_processing.cpp:4146\] \[ProcessMessage\] \[net\] got inv: block 00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 new peer=199 |
| 15:49:53.835 | Antpool 1 | GETHEADERS |  | 199 | 2026-03-23T15:49:53.834575Z \[msghand\] \[../../src/net_processing.cpp:4190\] \[ProcessMessage\] \[net\] getheaders (941880) 00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 to peer=199 |
| 15:49:54.176 | Antpool 1 | HEADERS | 3952229 |  | 2026-03-23T15:49:54.175539Z \[msghand\] \[../../src/net_processing.cpp:3546\] \[LogBlockHeader\] Saw new header hash=00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 height=941881 peer=3952229, peeraddr=\[2600:1702:7aa0:10b0:266e:96ff:fe46:9218\]:35822 |
| 15:49:54.176 | Antpool 1 | GETDATA |  | 3952229 | 2026-03-23T15:49:54.175654Z \[msghand\] \[../../src/net_processing.cpp:2876\] \[HeadersDirectFetchBlocks\] \[net\] Requesting block 00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 from peer=3952229 |
| 15:49:54.282 | Antpool 1 | CMPCTBLOCK | 3 |  | 2026-03-23T15:49:54.280740Z \[msghand\] \[../../src/net_processing.cpp:3575\] \[ProcessMessage\] \[net\] received: cmpctblock (27910 bytes) peer=3 \\n 2026-03-23T15:49:54.281870Z \[msghand\] \[../../src/blockencodings.cpp:61\] \[InitData\] \[cmpctblock\] Initializing PartiallyDownloadedBlock for block 00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 using a cmpctblock of 27910 bytes |
| 15:49:54.305 | Antpool 1 | GETBLOCKTXN |  | 3 | 2026-03-23T15:49:54.305168Z \[msghand\] \[../../src/blockencodings.cpp:178\] \[InitData\] \[cmpctblock\] Initialized PartiallyDownloadedBlock for block 00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 using a cmpctblock of 27910 bytes \\n 2026-03-23T15:49:54.305744Z \[msghand\] \[../../src/net.cpp:4078\] \[PushMessage\] \[net\] sending getblocktxn (93 bytes) peer=3 |
| 15:49:54.356 | Antpool 1 | CMPCTBLOCK | 3952229 |  | 2026-03-23T15:49:54.354679Z \[msghand\] \[../../src/net_processing.cpp:3575\] \[ProcessMessage\] \[net\] received: cmpctblock (27910 bytes) peer=3952229 \\n 2026-03-23T15:49:54.355897Z \[msghand\] \[../../src/blockencodings.cpp:61\] \[InitData\] \[cmpctblock\] Initializing PartiallyDownloadedBlock for block 00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 using a cmpctblock of 27910 bytes |
| 15:49:54.379 | Antpool 1 | GETBLOCKTXN |  | 3952229 | 2026-03-23T15:49:54.378914Z \[msghand\] \[../../src/blockencodings.cpp:178\] \[InitData\] \[cmpctblock\] Initialized PartiallyDownloadedBlock for block 00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 using a cmpctblock of 27910 bytes \\n 2026-03-23T15:49:54.379443Z \[msghand\] \[../../src/net.cpp:4078\] \[PushMessage\] \[net\] sending getblocktxn (93 bytes) peer=3952229 |
| 15:49:54.425 | Antpool 1 | BLOCKTXN | 3 |  | 2026-03-23T15:49:54.425321Z \[msghand\] \[../../src/net_processing.cpp:3575\] \[ProcessMessage\] \[net\] received: blocktxn (21507 bytes) peer=3 |
| 15:49:54.433 | Antpool 1 | CMPCTBLOCK Reconstructed | 3 |  | 2026-03-23T15:49:54.432974Z \[msghand\] \[../../src/blockencodings.cpp:228\] \[FillBlock\] \[cmpctblock\] Successfully reconstructed block 00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 with 1 txn prefilled, 4510 txn from mempool (incl at least 0 from extra pool) and 56 txn (21474 bytes) requested |
| 15:49:54.723 | Antpool 1 | Update Tip |  |  | 2026-03-23T15:49:54.722505Z \[msghand\] \[../../src/validation.cpp:2867\] \[UpdateTipLog\] UpdateTip: new best=00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 height=941881 version=0x3092c000 log2_work=96.137382 tx=1327000957 date=‘2026-03-23T15:49:35Z’ progress=1.000000 cache=218.5MiB(1597395txo) |
| 15:50:01.464 | Foundry 1 | INV | 199 |  | 2026-03-23T15:50:01.463926Z \[msghand\] \[../../src/net_processing.cpp:4146\] \[ProcessMessage\] \[net\] got inv: block 00000000000000000000bd4930a5982911e7749eb491886206e71abdc1ec0cc6 new peer=199 |
| 15:50:01.464 | Foundry 1 | GETHEADERS |  | 199 | 2026-03-23T15:50:01.464206Z \[msghand\] \[../../src/net_processing.cpp:4190\] \[ProcessMessage\] \[net\] getheaders (941881) 00000000000000000000bd4930a5982911e7749eb491886206e71abdc1ec0cc6 to peer=199 |
| 15:51:47.071 | Antpool 2 | INV | 199 |  | 2026-03-23T15:51:47.070886Z \[msghand\] \[../../src/net_processing.cpp:4146\] \[ProcessMessage\] \[net\] got inv: block 00000000000000000000c81cbf94a12ca498e72eb8530f7061c8746cf9687b2e new peer=199 |
| 15:51:47.071 | Antpool 2 | GETHEADERS |  | 199 | 2026-03-23T15:50:01.464206Z \[msghand\] \[../../src/net_processing.cpp:4190\] \[ProcessMessage\] \[net\] getheaders (941881) 00000000000000000000bd4930a5982911e7749eb491886206e71abdc1ec0cc6 to peer=199 |
| 15:51:47.075 | Antpool 2 | CMPCTBLOCK | 1271642 |  | 2026-03-23T15:51:47.074890Z \[msghand\] \[../../src/net_processing.cpp:3575\] \[ProcessMessage\] \[net\] received: cmpctblock (5773 bytes) peer=1271642 \\n 2026-03-23T15:51:47.075326Z \[msghand\] \[../../src/net_processing.cpp:3546\] \[LogBlockHeader\] Saw new cmpctblock header hash=00000000000000000000c81cbf94a12ca498e72eb8530f7061c8746cf9687b2e height=941882 peer=1271642, peeraddr=\[2600:8801:2f80:ac:f522:7bf5:2ae7:47fd\]:60099 \\n 2026-03-23T15:51:47.075428Z \[msghand\] \[../../src/blockencodings.cpp:61\] \[InitData\] \[cmpctblock\] Initializing PartiallyDownloadedBlock for block 00000000000000000000c81cbf94a12ca498e72eb8530f7061c8746cf9687b2e using a cmpctblock of 5773 bytes |
| 15:51:47.08 | Antpool 2 | HEADERS | 1271642 |  | 2026-03-23T15:51:47.075326Z \[msghand\] \[../../src/net_processing.cpp:3546\] \[LogBlockHeader\] Saw new cmpctblock header hash=00000000000000000000c81cbf94a12ca498e72eb8530f7061c8746cf9687b2e height=941882 peer=1271642, peeraddr=\[2600:8801:2f80:ac:f522:7bf5:2ae7:47fd\]:60099 |
| 15:51:47.079 | Antpool 2 | CMPCTBLOCK Reconstructed |  |  | 2026-03-23T15:51:47.089420Z \[msghand\] \[../../src/blockencodings.cpp:228\] \[FillBlock\] \[cmpctblock\] Successfully reconstructed block 00000000000000000000c81cbf94a12ca498e72eb8530f7061c8746cf9687b2e with 1 txn prefilled, 871 txn from mempool (incl at least 1 from extra pool) and 0 txn (0 bytes) requested |
| 15:51:47.176 | Antpool 2 | UpdateTip | 1271642 |  | 2026-03-23T15:51:47.175709Z \[msghand\] \[../../src/validationinterface.cpp:182\] \[UpdatedBlockTip\] \[validation\] Enqueuing UpdatedBlockTip: new block hash=00000000000000000000c81cbf94a12ca498e72eb8530f7061c8746cf9687b2e fork block hash=00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 (in IBD=false) |
| 15:51:47.270 | Foundry 1 | HEADERS | 199 |  | 2026-03-23T15:51:47.269999Z \[msghand\] \[../../src/net_processing.cpp:3546\] \[LogBlockHeader\] Saw new header hash=00000000000000000000bd4930a5982911e7749eb491886206e71abdc1ec0cc6 height=941881 peer=199, peeraddr=80.251.125.221:46532 |
| 15:55:01.161 | Foundry 2 | INV | 199 |  | 2026-03-23T15:55:01.160946Z \[msghand\] \[../../src/net_processing.cpp:4146\] \[ProcessMessage\] \[net\] got inv: block 00000000000000000000724eac69a18c6699c9f7aaab24bcf18beb2723ccadd2 new peer=199 |
| 15:55:01.161 | Foundry 2 | GETHEADERS |  | 199 | 2026-03-23T15:55:01.161244Z \[msghand\] \[../../src/net_processing.cpp:4190\] \[ProcessMessage\] \[net\] getheaders (941882) 00000000000000000000724eac69a18c6699c9f7aaab24bcf18beb2723ccadd2 to peer=199 |
| 15:55:01.358 | Foundry 3 | INV | 199 |  | 2026-03-23T15:55:01.357525Z \[msghand\] \[../../src/net_processing.cpp:4146\] \[ProcessMessage\] \[net\] got inv: block 000000000000000000009c9acd0bc3207fa181f79f8573bf27d8a81d1ef3aa8e new peer=199 |
| 15:55:01.583 | Foundry 2 | HEADERS | 199 |  | 2026-03-23T15:55:01.583065Z \[msghand\] \[../../src/net_processing.cpp:3546\] \[LogBlockHeader\] Saw new header hash=00000000000000000000724eac69a18c6699c9f7aaab24bcf18beb2723ccadd2 height=941882 peer=199, peeraddr=80.251.125.221:46532 |
| 15:55:01.583 | Foundry 1 | GETDATA |  | 199 | 2026-03-23T15:55:01.583122Z \[msghand\] \[../../src/net_processing.cpp:2876\] \[HeadersDirectFetchBlocks\] \[net\] Requesting block 00000000000000000000bd4930a5982911e7749eb491886206e71abdc1ec0cc6 from peer=199 |
| 15:55:01.583 | Foundry 2 | GETDATA |  | 199 | 2026-03-23T15:55:01.583148Z \[msghand\] \[../../src/net_processing.cpp:2876\] \[HeadersDirectFetchBlocks\] \[net\] Requesting block 00000000000000000000724eac69a18c6699c9f7aaab24bcf18beb2723ccadd2 from peer=199 |
| 15:55:06.356 | Foundry 3 | HEADERS | 8302907 |  | 2026-03-23T15:55:06.355712Z \[msghand\] \[../../src/net_processing.cpp:3546\] \[LogBlockHeader\] Saw new header hash=000000000000000000009c9acd0bc3207fa181f79f8573bf27d8a81d1ef3aa8e height=941883 peer=8302907, peeraddr=67.85.54.88:56666 |
| 15:55:06.356 | Foundry 3 | GETDATA | 8302907 |  | 2026-03-23T15:55:06.355875Z \[msghand\] \[../../src/net_processing.cpp:2876\] \[HeadersDirectFetchBlocks\] \[net\] Requesting block 000000000000000000009c9acd0bc3207fa181f79f8573bf27d8a81d1ef3aa8e from peer=8302907 |
| 15:55:07.295 | Foundry 3 | BLOCK | 8302907 |  | 2026-03-23T15:55:07.294834Z \[msghand\] \[../../src/net_processing.cpp:4859\] \[ProcessMessage\] \[net\] received block 000000000000000000009c9acd0bc3207fa181f79f8573bf27d8a81d1ef3aa8e peer=8302907 |
| 16:02:30.919 | Main 4 | INV | 199 |  | 2026-03-23T16:02:30.919287Z \[msghand\] \[../../src/net_processing.cpp:4146\] \[ProcessMessage\] \[net\] got inv: block 0000000000000000000085ebdcd669c404195dbfeccbee902fc646dadc367a20 new peer=199 |
| 16:02:30.920 | Main 4 | GETHEADERS |  | 199 | 2026-03-23T16:02:30.919581Z \[msghand\] \[../../src/net_processing.cpp:4190\] \[ProcessMessage\] \[net\] getheaders (941883) 0000000000000000000085ebdcd669c404195dbfeccbee902fc646dadc367a20 to peer=199 |
| 16:02:30.970 | Main 4 | HEADERS | 6312471 |  | 2026-03-23T16:02:30.969996Z \[msghand\] \[../../src/net_processing.cpp:3546\] \[LogBlockHeader\] Saw new header hash=0000000000000000000085ebdcd669c404195dbfeccbee902fc646dadc367a20 height=941884 peer=6312471, peeraddr=\[fc57:be98:b90c:89a2:6807:69a0:827:947e\]:43692 |
| 16:02:30.970 | Main 4 | GETDATA | 6312471 |  | 2026-03-23T16:02:30.970148Z \[msghand\] \[../../src/net_processing.cpp:2876\] \[HeadersDirectFetchBlocks\] \[net\] Requesting block 0000000000000000000085ebdcd669c404195dbfeccbee902fc646dadc367a20 from peer=6312471 |
| 16:02:31.324 | Main 4 | CMPCTBLOCK | 1283269 |  | 2026-03-23T16:02:31.323094Z \[msghand\] \[../../src/net_processing.cpp:3575\] \[ProcessMessage\] \[net\] received: cmpctblock (24495 bytes) peer=1283269 \\n 2026-03-23T16:02:31.323969Z \[msghand\] \[../../src/blockencodings.cpp:61\] \[InitData\] \[cmpctblock\] Initializing PartiallyDownloadedBlock for block 0000000000000000000085ebdcd669c404195dbfeccbee902fc646dadc367a20 using a cmpctblock of 24495 bytes |
| 16:02:31.342 | Main 4 | GETBLOCKTXN |  | 1283269 | 2026-03-23T16:02:31.341592Z \[msghand\] \[../../src/net.cpp:4078\] \[PushMessage\] \[net\] sending getblocktxn (773 bytes) peer=1283269 |
| 16:02:32.049 | Main 4 | BLOCKTXN | 1283269 |  | 2026-03-23T16:02:32.028760Z \[msghand\] \[../../src/net_processing.cpp:3575\] \[ProcessMessage\] \[net\] received: blocktxn (267997 bytes) peer=1283269 |
| 16:02:32.049 | Main 4 | CMPCTBLOCK Reconstructed |  |  | 2026-03-23T16:02:32.049006Z \[msghand\] \[../../src/blockencodings.cpp:228\] \[FillBlock\] \[cmpctblock\] Successfully reconstructed block 0000000000000000000085ebdcd669c404195dbfeccbee902fc646dadc367a20 with 1 txn prefilled, 3268 txn from mempool (incl at least 76 from extra pool) and 736 txn (267962 bytes) requested |
| 16:04:49.393 | Main 5 | INV | 199 |  | 2026-03-23T16:04:49.393196Z \[msghand\] \[../../src/net_processing.cpp:4146\] \[ProcessMessage\] \[net\] got inv: block 00000000000000000001f8562235e11fc74d5eea589e4c37b671b4213e89f52f new peer=199 |
| 16:04:49.393 | Main 5 | GETHEADERS |  | 199 | 2026-03-23T16:04:49.393406Z \[msghand\] \[../../src/net_processing.cpp:4190\] \[ProcessMessage\] \[net\] getheaders (941884) 00000000000000000001f8562235e11fc74d5eea589e4c37b671b4213e89f52f to peer=199 |
| 16:04:49.595 | Main 5 | HEADERS | 4392345 |  | 2026-03-23T16:04:49.594756Z \[msghand\] \[../../src/net_processing.cpp:3546\] \[LogBlockHeader\] Saw new header hash=00000000000000000001f8562235e11fc74d5eea589e4c37b671b4213e89f52f height=941885 peer=4392345, peeraddr=10.30.1.77:55010 |
| 16:04:49.595 | Main 5 | GETDATA |  | 4392345 | 2026-03-23T16:04:49.594846Z \[msghand\] \[../../src/net_processing.cpp:2876\] \[HeadersDirectFetchBlocks\] \[net\] Requesting block 00000000000000000001f8562235e11fc74d5eea589e4c37b671b4213e89f52f from peer=4392345 |
| 16:04:50.220 | Main 5 | BLOCK |  | 4392345 | 2026-03-23T16:04:50.219701Z \[msghand\] \[../../src/net_processing.cpp:4859\] \[ProcessMessage\] \[net\] received block 00000000000000000001f8562235e11fc74d5eea589e4c37b671b4213e89f52f peer=4392345 |
| 16:05:01.590 | Foundry 1 | Block stall timeout, disconnect peer | 199 |  | 2026-03-23T16:05:01.590359Z \[msghand\] \[../../src/net_processing.cpp:6110\] \[SendMessages\] Timeout downloading block 00000000000000000000bd4930a5982911e7749eb491886206e71abdc1ec0cc6, disconnecting peer=199, peeraddr=80.251.125.221:46532 |
| 16:05:01.612 | Foundry 1 | GETDATA |  | 8302907 | 2026-03-23T16:05:01.611937Z \[msghand\] \[../../src/net_processing.cpp:6181\] \[SendMessages\] \[net\] Requesting block 00000000000000000000bd4930a5982911e7749eb491886206e71abdc1ec0cc6 (941881) peer=8302907 |
| 16:05:01.612 | Foundry 2 | GETDATA |  | 8302907 | 2026-03-23T16:05:01.611964Z \[msghand\] \[../../src/net_processing.cpp:6181\] \[SendMessages\] \[net\] Requesting block 00000000000000000000724eac69a18c6699c9f7aaab24bcf18beb2723ccadd2 (941882) peer=8302907 |
| 16:05:02.593 | Foundry 1 | BLOCK | 8302907 |  | 2026-03-23T16:05:02.592967Z \[msghand\] \[../../src/net_processing.cpp:4859\] \[ProcessMessage\] \[net\] received block 00000000000000000000bd4930a5982911e7749eb491886206e71abdc1ec0cc6 peer=8302907 |
| 16:05:03.322 | Foundry 2 | BLOCK | 8302907 |  | 2026-03-23T16:05:03.321989Z \[msghand\] \[../../src/net_processing.cpp:4859\] \[ProcessMessage\] \[net\] received block 00000000000000000000724eac69a18c6699c9f7aaab24bcf18beb2723ccadd2 peer=8302907 |
| 16:05:03.434 | Antpool 2 | Block Disconnected |  |  | 2026-03-23T16:05:03.433595Z \[scheduler\] \[../../src/validationinterface.cpp:239\] \[operator()\] \[validation\] BlockDisconnected: block hash=00000000000000000000c81cbf94a12ca498e72eb8530f7061c8746cf9687b2e block height=941882 |
| 16:05:03.844 | Foundry 1 | Update Tip |  |  | 2026-03-23T16:05:03.843581Z \[msghand\] \[../../src/validation.cpp:2867\] \[UpdateTipLog\] UpdateTip: new best=00000000000000000000bd4930a5982911e7749eb491886206e71abdc1ec0cc6 height=941881 version=0x22cd4000 log2_work=96.137382 tx=1327000861 date=‘2026-03-23T15:49:47Z’ progress=0.999990 cache=219.0MiB(1599154txo) |
| 16:05:04.065 | Foundry 2 | Update Tip |  |  | 2026-03-23T16:05:04.065420Z \[msghand\] \[../../src/validation.cpp:2867\] \[UpdateTipLog\] UpdateTip: new best=00000000000000000000724eac69a18c6699c9f7aaab24bcf18beb2723ccadd2 height=941882 version=0x3427e000 log2_work=96.137391 tx=1327005400 date=‘2026-03-23T15:51:25Z’ progress=0.999993 cache=219.3MiB(1602981txo) |
| 16:05:04.355 | Foundry 3 | Update Tip |  |  | 2026-03-23T16:05:04.355114Z \[msghand\] \[../../src/validation.cpp:2867\] \[UpdateTipLog\] UpdateTip: new best=000000000000000000009c9acd0bc3207fa181f79f8573bf27d8a81d1ef3aa8e height=941883 version=0x2fc2e000 log2_work=96.137401 tx=1327009788 date=‘2026-03-23T15:54:49Z’ progress=0.999995 cache=219.8MiB(1607191txo) |
| 16:05:04.425 | Antpool 1 | Block Disconnected |  |  | 2026-03-23T16:05:04.424781Z \[scheduler\] \[../../src/validationinterface.cpp:239\] \[operator()\] \[validation\] BlockDisconnected: block hash=00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 block height=941881 |
| 16:05:08.862 | Main 4 | Update Tip |  |  | 2026-03-23T16:05:08.862000Z \[msghand\] \[../../src/validation.cpp:2867\] \[UpdateTipLog\] UpdateTip: new best=0000000000000000000085ebdcd669c404195dbfeccbee902fc646dadc367a20 height=941884 version=0x212b4000 log2_work=96.137410 tx=1327013793 date=‘2026-03-23T16:02:14Z’ progress=0.999998 cache=220.3MiB(1610860txo) |
| 16:05:09.152 | Main 5 | Update Tip |  |  | 2026-03-23T16:05:09.152296Z \[msghand\] \[../../src/validation.cpp:2867\] \[UpdateTipLog\] UpdateTip: new best=00000000000000000001f8562235e11fc74d5eea589e4c37b671b4213e89f52f height=941885 version=0x22abe000 log2_work=96.137420 tx=1327018030 date=‘2026-03-23T16:04:46Z’ progress=1.000000 cache=220.8MiB(1614193txo) |
</details>

To kind of summarize what happened here, peer 199 (who aggressively `INV`’s blocks to this node and is often the first to do so)  sent an INV of foundry’s first block, then this node sent a `GETHEADERS` then peer 199 replied with `HEADERS`, then the node sent a `GETDATA` for the block and peer 199 did not respond, notably the block stall time out is 10 minutes, and Bitcoin Core will not request a block while there is a block in-flight from a peer, the only escape valve during this stalling period is *if* one of a node’s high-bandwidth compact block peers sends an unrequested block, but this node was unlucky enough to have all of its compact block HB peers end up on one side of the race. I suspect @b10c’s owen and greg were similarly stalled.

This was also pointed out on [IRC]( https://bitcoin-irc.chaincode.com/bitcoin-core-dev/2026-03-25#1774470438-1774471515; ) to be related to [bitcoin/bitcoin#33687](https://github.com/bitcoin/bitcoin/issues/33687).

The full log is available here if anyone else would like to analyze: https://achow101.com/files/debug.log2026-03-23-foundry-reorg.txt

I mostly built the table by hand using grep and bubblegum, but I pasted it into gemini-3.1 and asked it to write a script to generate such tables from debug.log files and (with a few tweaks) it seems (at a glance) to mostly work with a few small hiccups, if others want to automate making similar tables:

<details>

<summary>Fork timeline slop script</summary>

```bash
python geminiscript.py debug.log blocks.conf > out.csv
```

```
# blocks.conf

# Format: HASH:LABEL

00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3:Antpool1
00000000000000000000c81cbf94a12ca498e72eb8530f7061c8746cf9687b2e:Antpool2

00000000000000000000bd4930a5982911e7749eb491886206e71abdc1ec0cc6:Foundry1
00000000000000000000724eac69a18c6699c9f7aaab24bcf18beb2723ccadd2:Foundry2
000000000000000000009c9acd0bc3207fa181f79f8573bf27d8a81d1ef3aa8e:Foundry3

0000000000000000000085ebdcd669c404195dbfeccbee902fc646dadc367a20:Main4
00000000000000000001f8562235e11fc74d5eea589e4c37b671b4213e89f52f:Main5
```

```python
# geminiscript.py

import sys
import re
import argparse


def load_block_config(config_path):
    """Load block hashes and labels from a simple config file.

    Format (one per line):
        HASH:LABEL

    Blank lines and lines starting with # are ignored.
    """
    block_labels = {}
    try:
        with open(config_path, 'r') as f:
            for lineno, line in enumerate(f, 1):
                line = line.strip()
                if not line or line.startswith('#'):
                    continue
                if ':' not in line:
                    print(
                        f"Error: {config_path}:{lineno}: expected HASH:LABEL format, got '{line}'",
                        file=sys.stderr,
                    )
                    sys.exit(1)
                b_hash, b_label = line.split(':', 1)
                block_labels[b_hash.strip()] = b_label.strip()
    except FileNotFoundError:
        print(f"Error: Could not find config file {config_path}", file=sys.stderr)
        sys.exit(1)

    if not block_labels:
        print(f"Error: No block entries found in {config_path}", file=sys.stderr)
        sys.exit(1)

    return block_labels


def main():
    parser = argparse.ArgumentParser(
        description="High-performance Bitcoin debug.log block race analyzer."
    )
    parser.add_argument("log_file", help="Path to the debug.log file")
    parser.add_argument(
        "blocks_file",
        help="Path to a blocks config file (one HASH:LABEL per line)",
    )
    args = parser.parse_args()

    block_labels = load_block_config(args.blocks_file)

    # Regex for extracting timestamps accurately
    time_rx = re.compile(r'^.*?(\d{4}-\d{2}-\d{2}[T ](\d{2}:\d{2}:\d{2}(?:\.\d+)?))')

    # Define all event patterns.
    # Tuple: (Regex, Event Name, Direction of Peer (From/To))
    action_patterns = [
        (re.compile(r'got inv: block (?P<hash>[a-f0-9]{64}).*peer=(?P<peer>\d+)'), 'INV', 'From'),
        (re.compile(r'getheaders \(\d+\) (?P<hash>[a-f0-9]{64}) to peer=(?P<peer>\d+)'), 'GETHEADERS', 'To'),
        (re.compile(r'(?:Saw new header hash=|Saw new cmpctblock header hash=)(?P<hash>[a-f0-9]{64}).*peer=(?P<peer>\d+)'), 'HEADERS', 'From'),
        (re.compile(r'Requesting block (?P<hash>[a-f0-9]{64}).*peer=(?P<peer>\d+)'), 'GETDATA', 'To'),
        (re.compile(r'received block (?P<hash>[a-f0-9]{64}).*peer=(?P<peer>\d+)'), 'BLOCK', 'From'),
        (re.compile(r'Successfully reconstructed block (?P<hash>[a-f0-9]{64})'), 'CMPCTBLOCK Reconstructed', 'From'),
        (re.compile(r'UpdateTip: new best=(?P<hash>[a-f0-9]{64})'), 'Update Tip', ''),
        (re.compile(r'Timeout downloading block (?P<hash>[a-f0-9]{64}), disconnecting peer=(?P<peer>\d+)'), 'Block stall timeout: disconnect peer', 'From'),
        (re.compile(r'BlockDisconnected: block hash=(?P<hash>[a-f0-9]{64})'), 'Block Disconnected', ''),

        # Multi-line / State machine triggers
        (re.compile(r'received: cmpctblock .* peer=(?P<peer>\d+)'), 'RX_CMPCTBLOCK', ''),
        (re.compile(r'Initializing PartiallyDownloadedBlock for block (?P<hash>[a-f0-9]{64})'), 'INIT_PDB', ''),
        (re.compile(r'Initialized PartiallyDownloadedBlock for block (?P<hash>[a-f0-9]{64})'), 'INITED_PDB', ''),
        (re.compile(r'sending getblocktxn .* peer=(?P<peer>\d+)'), 'TX_GETBLOCKTXN', ''),
        (re.compile(r'received: blocktxn .* peer=(?P<peer>\d+)'), 'RX_BLOCKTXN', ''),
    ]

    # FAST PATH EXCLUSION
    fast_keywords = list(block_labels.keys()) + ['cmpctblock', 'getblocktxn', 'blocktxn']
    fast_filter = re.compile('|'.join(map(re.escape, fast_keywords)))

    # State tracking dictionaries
    peer_for_hash = {}
    hash_for_peer = {}
    pending_cmpctblock = None
    pending_getblocktxn = None

    print("Time,Block,Msg/Action,From Peer,To Peer,Log message")

    try:
        with open(args.log_file, 'r', encoding='utf-8', errors='ignore') as f:
            for line in f:
                if not fast_filter.search(line):
                    continue

                t_match = time_rx.search(line)
                if not t_match:
                    continue
                time_val = t_match.group(2)

                for rx, action, direction in action_patterns:
                    m = rx.search(line)
                    if m:
                        gd = m.groupdict()
                        h = gd.get('hash')
                        p = gd.get('peer')

                        if action == 'RX_CMPCTBLOCK':
                            pending_cmpctblock = (p, line.strip())
                            break
                        elif action == 'INIT_PDB':
                            if h in block_labels and pending_cmpctblock:
                                p_peer, p_line = pending_cmpctblock
                                combined_line = f"{p_line} \\n {line.strip()}"
                                peer_for_hash[h] = p_peer
                                hash_for_peer[p_peer] = h
                                print(f"{time_val},{block_labels[h]},CMPCTBLOCK,{p_peer},,\"{combined_line}\"")
                            pending_cmpctblock = None
                            break
                        elif action == 'INITED_PDB':
                            if h in block_labels:
                                pending_getblocktxn = (h, line.strip())
                            break
                        elif action == 'TX_GETBLOCKTXN':
                            if pending_getblocktxn:
                                p_hash, p_line = pending_getblocktxn
                                if p_hash in block_labels:
                                    combined_line = f"{p_line} \\n {line.strip()}"
                                    peer_for_hash[p_hash] = p
                                    hash_for_peer[p] = p_hash
                                    print(f"{time_val},{block_labels[p_hash]},GETBLOCKTXN,,{p},\"{combined_line}\"")
                            pending_getblocktxn = None
                            break
                        elif action == 'RX_BLOCKTXN':
                            target_hash = hash_for_peer.get(p)
                            if target_hash and target_hash in block_labels:
                                print(f"{time_val},{block_labels[target_hash]},BLOCKTXN,{p},,\"{line.strip()}\"")
                            break

                        if h:
                            if h not in block_labels:
                                break
                            label = block_labels[h]
                            if p:
                                peer_for_hash[h] = p
                                hash_for_peer[p] = h
                            else:
                                p = peer_for_hash.get(h, '')
                            from_p = p if direction == 'From' else ''
                            to_p = p if direction == 'To' else ''
                            print(f"{time_val},{label},{action},{from_p},{to_p},\"{line.strip()}\"")

                        break

    except KeyboardInterrupt:
        print("\nProcess interrupted by user.", file=sys.stderr)
    except FileNotFoundError:
        print(f"Error: Could not find file {args.log_file}", file=sys.stderr)


if __name__ == "__main__":
    main()

```

**Edit:** I have updated this script with a fix for it logging duplicate update tips and grabbing extra `BLOCKTXN` messages from the end of logs.

</details>

-------------------------

b10c | 2026-03-26 08:34:41 UTC | #20

A miner mining on Foundry shared the following stratum job data with me. I've anonymized it a bit.


| first job arrival timestamp | mining on block        | duration on this tip |
|-----------------------|------------------------|----------------------|
| 15:48:16.700          | 941880 Foundry         | ~ 98s                |
| 15:49:54.200          | 941881 AntPool (stale) | ~ 1s                 |
| 15:49:55.300          | 941881 Foundry         | ~ 112s               |
| 15:51:47.350          | 941882 ViaBTC (stale)  | ~ 1.3s               |
| 15:51:48.700          | 941882 Foundry         | ~ 192s               |
| 15:55:00.500          | 941883 Foundry         | > 5min               |

---

My takeaway from this is: 

- at 15.49:54, Foundry send a job building on top of the AntPool 941881 block, but switched to it's Foundry 941881 block around 1s later 
- then, at 15:51:47, ViaBTC found a block at height 941882, Foundry switched to this block, but after 1.3s switched to Foundry's 941882

---

Foundry switching to their own block (e.g. with `preciousblock`) is a very reasonable thing to do for them. We know Foundry has been doing this for a while, and AntPool, for whatever reason, does not: https://b10c.me/blog/014-mining-pool-behavior-during-forks/

This also shows that Foundry too saw the AntPool and ViaBTC blocks arriving first. However, it's not unreasonable that a miner submitted a valid share even after the AntPool & ViaBTC blocks where known to the network. See e.g. https://bnoc.xyz/t/antpool-mines-two-blocks-at-height-925051/60 where AntPool miners found two valid shares at a similar time.

-------------------------

zawy12 | 2026-03-26 15:09:19 UTC | #21

In a sample 2 years ago, all the pools seemed to be time-rolling because timestamps of all the pools seemed to average \~20 seconds before the header arrived and had a 20 s stdev.   5% of blocks had a stamp in the future.  0.4% had a block > 60 s in the past.  Brainspool was an exception averaging 11 seconds with stdev of 25 (they a lot of blocks with timestamps in the future).

-------------------------

b10c | 2026-03-27 09:25:02 UTC | #22

I raw two of my nodes logs through @davidgumberg's script.

`owen`, a node that got stalled (by the same peer; see `Block stall timeout: disconnect peer`) and did only receive the 941881 Foundry block at around 16:05:


[details="owen"]
|Time | Block | Msg/Action | From Peer | To Peer | Log message|
|--- | --- | --- | --- | --- | ---|
|15:49:53.833781 | Antpool1 | INV | 140374 |  | 2026-03-23T15:49:53.833781Z [msghand] [net] got inv: block 00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3  new peer=140374|
|15:49:53.834143 | Antpool1 | GETHEADERS |  | 140374 | 2026-03-23T15:49:53.834143Z [msghand] [net] getheaders (941880) 00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 to peer=140374|
|15:49:54.029989 | Antpool1 | HEADERS | 127889 |  | 2026-03-23T15:49:54.029989Z [msghand] Saw new cmpctblock header hash=00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 height=941881 peer=127889 peeraddr=X|
|15:49:54.030397 | Antpool1 | CMPCTBLOCK | 127889 |  | 2026-03-23T15:49:54.028551Z [msghand] [net] received: cmpctblock (27910 bytes) peer=127889 \n 2026-03-23T15:49:54.030397Z [msghand] [cmpctblock] Initializing PartiallyDownloadedBlock for block 00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 using a cmpctblock of 27910 bytes|
|15:49:54.056084 | Antpool1 | GETBLOCKTXN |  | 127889 | 2026-03-23T15:49:54.055526Z [msghand] [cmpctblock] Initialized PartiallyDownloadedBlock for block 00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 using a cmpctblock of 27910 bytes \n 2026-03-23T15:49:54.056084Z [msghand] [net] sending getblocktxn (93 bytes) peer=127889|
|15:49:54.123920 | Antpool1 | BLOCKTXN | 127889 |  | 2026-03-23T15:49:54.123920Z [msghand] [net] received: blocktxn (21507 bytes) peer=127889|
|15:49:54.133473 | Antpool1 | CMPCTBLOCK Reconstructed | 127889 |  | 2026-03-23T15:49:54.133473Z [msghand] [cmpctblock] Successfully reconstructed block 00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 with 1 txn prefilled, 4510 txn from mempool (incl at least 0 from extra pool) and 56 txn (21474 bytes) requested|
|15:49:54.585760 | Antpool1 | Update Tip |  |  | 2026-03-23T15:49:54.585760Z [msghand] UpdateTip: new best=00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 height=941881 version=0x3092c000 log2_work=96.137382 tx=1327000957 date='2026-03-23T15:49:35Z' progress=1.000000 cache=582.2MiB(4357927txo)|
|15:49:54.585931 | Antpool1 | UpdateTip | 127889 |  | 2026-03-23T15:49:54.585931Z [msghand] [validation] Enqueuing UpdatedBlockTip: new block hash=00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 fork block hash=0000000000000000000199a739b635c5707a2bda57231b8abe846216ca0cc989 (in IBD=false)|
|15:50:01.254651 | Foundry1 | INV | 140374 |  | 2026-03-23T15:50:01.254651Z [msghand] [net] got inv: block 00000000000000000000bd4930a5982911e7749eb491886206e71abdc1ec0cc6  new peer=140374|
|15:50:01.254993 | Foundry1 | GETHEADERS |  | 140374 | 2026-03-23T15:50:01.254993Z [msghand] [net] getheaders (941881) 00000000000000000000bd4930a5982911e7749eb491886206e71abdc1ec0cc6 to peer=140374|
|15:51:47.118183 | Antpool2 | HEADERS | 42523 |  | 2026-03-23T15:51:47.118183Z [msghand] Saw new header hash=00000000000000000000c81cbf94a12ca498e72eb8530f7061c8746cf9687b2e height=941882 peer=42523 peeraddr=X|
|15:51:47.118237 | Antpool2 | GETDATA |  | 42523 | 2026-03-23T15:51:47.118237Z [msghand] [net] Requesting block 00000000000000000000c81cbf94a12ca498e72eb8530f7061c8746cf9687b2e from  peer=42523|
|15:51:47.134567 | Antpool2 | CMPCTBLOCK | 59642 |  | 2026-03-23T15:51:47.134077Z [msghand] [net] received: cmpctblock (5773 bytes) peer=59642 \n 2026-03-23T15:51:47.134567Z [msghand] [cmpctblock] Initializing PartiallyDownloadedBlock for block 00000000000000000000c81cbf94a12ca498e72eb8530f7061c8746cf9687b2e using a cmpctblock of 5773 bytes|
|15:51:47.152286 | Antpool2 | CMPCTBLOCK Reconstructed | 59642 |  | 2026-03-23T15:51:47.152286Z [msghand] [cmpctblock] Successfully reconstructed block 00000000000000000000c81cbf94a12ca498e72eb8530f7061c8746cf9687b2e with 1 txn prefilled, 871 txn from mempool (incl at least 1 from extra pool) and 0 txn (0 bytes) requested|
|15:51:47.301996 | Antpool2 | Update Tip |  |  | 2026-03-23T15:51:47.301996Z [msghand] UpdateTip: new best=00000000000000000000c81cbf94a12ca498e72eb8530f7061c8746cf9687b2e height=941882 version=0x2008c000 log2_work=96.137391 tx=1327001829 date='2026-03-23T15:51:19Z' progress=1.000000 cache=582.2MiB(4358945txo)|
|15:51:47.302133 | Antpool2 | UpdateTip | 59642 |  | 2026-03-23T15:51:47.302133Z [msghand] [validation] Enqueuing UpdatedBlockTip: new block hash=00000000000000000000c81cbf94a12ca498e72eb8530f7061c8746cf9687b2e fork block hash=00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 (in IBD=false)|
|15:51:47.400435 | Antpool2 | INV | 140374 |  | 2026-03-23T15:51:47.400435Z [msghand] [net] got inv: block 00000000000000000000c81cbf94a12ca498e72eb8530f7061c8746cf9687b2e  have peer=140374|
|15:55:01.141852 | Foundry2 | INV | 140374 |  | 2026-03-23T15:55:01.141852Z [msghand] [net] got inv: block 00000000000000000000724eac69a18c6699c9f7aaab24bcf18beb2723ccadd2  new peer=140374|
|15:55:01.142559 | Foundry2 | GETHEADERS |  | 140374 | 2026-03-23T15:55:01.142559Z [msghand] [net] getheaders (941882) 00000000000000000000724eac69a18c6699c9f7aaab24bcf18beb2723ccadd2 to peer=140374|
|15:55:01.283400 | Foundry3 | INV | 140374 |  | 2026-03-23T15:55:01.283400Z [msghand] [net] got inv: block 000000000000000000009c9acd0bc3207fa181f79f8573bf27d8a81d1ef3aa8e  new peer=140374|
|15:55:01.429284 | Foundry2 | HEADERS | 140374 |  | 2026-03-23T15:55:01.429284Z [msghand] Saw new header hash=00000000000000000000724eac69a18c6699c9f7aaab24bcf18beb2723ccadd2 height=941882 peer=140374 peeraddr=80.251.125.221:35626|
|15:55:01.429341 | Foundry1 | GETDATA |  | 140374 | 2026-03-23T15:55:01.429341Z [msghand] [net] Requesting block 00000000000000000000bd4930a5982911e7749eb491886206e71abdc1ec0cc6 from  peer=140374|
|15:55:01.429362 | Foundry2 | GETDATA |  | 140374 | 2026-03-23T15:55:01.429362Z [msghand] [net] Requesting block 00000000000000000000724eac69a18c6699c9f7aaab24bcf18beb2723ccadd2 from  peer=140374|
|15:55:01.780852 | Foundry3 | HEADERS | 214021 |  | 2026-03-23T15:55:01.780852Z [msghand] Saw new header hash=000000000000000000009c9acd0bc3207fa181f79f8573bf27d8a81d1ef3aa8e height=941883 peer=214021 peeraddr=X|
|15:55:01.780957 | Foundry3 | GETDATA |  | 214021 | 2026-03-23T15:55:01.780957Z [msghand] [net] Requesting block 000000000000000000009c9acd0bc3207fa181f79f8573bf27d8a81d1ef3aa8e from  peer=214021|
|15:55:03.491469 | Foundry3 | BLOCK | 214021 |  | 2026-03-23T15:55:03.491469Z [msghand] [net] received block 000000000000000000009c9acd0bc3207fa181f79f8573bf27d8a81d1ef3aa8e peer=214021|
|16:02:30.896711 | Main4 | INV | 140374 |  | 2026-03-23T16:02:30.896711Z [msghand] [net] got inv: block 0000000000000000000085ebdcd669c404195dbfeccbee902fc646dadc367a20  new peer=140374|
|16:02:30.897048 | Main4 | GETHEADERS |  | 140374 | 2026-03-23T16:02:30.897048Z [msghand] [net] getheaders (941883) 0000000000000000000085ebdcd669c404195dbfeccbee902fc646dadc367a20 to peer=140374|
|16:02:30.993875 | Main4 | HEADERS | 200279 |  | 2026-03-23T16:02:30.993875Z [msghand] Saw new header hash=0000000000000000000085ebdcd669c404195dbfeccbee902fc646dadc367a20 height=941884 peer=200279 peeraddr=X|
|16:02:30.993958 | Main4 | GETDATA |  | 200279 | 2026-03-23T16:02:30.993958Z [msghand] [net] Requesting block 0000000000000000000085ebdcd669c404195dbfeccbee902fc646dadc367a20 from  peer=200279|
|16:02:31.038904 | Main4 | CMPCTBLOCK | 127889 |  | 2026-03-23T16:02:31.037396Z [msghand] [net] received: cmpctblock (24495 bytes) peer=127889 \n 2026-03-23T16:02:31.038904Z [msghand] [cmpctblock] Initializing PartiallyDownloadedBlock for block 0000000000000000000085ebdcd669c404195dbfeccbee902fc646dadc367a20 using a cmpctblock of 24495 bytes|
|16:02:31.063406 | Main4 | GETBLOCKTXN |  | 127889 | 2026-03-23T16:02:31.062281Z [msghand] [cmpctblock] Initialized PartiallyDownloadedBlock for block 0000000000000000000085ebdcd669c404195dbfeccbee902fc646dadc367a20 using a cmpctblock of 24495 bytes \n 2026-03-23T16:02:31.063406Z [msghand] [net] sending getblocktxn (769 bytes) peer=127889|
|16:02:31.190960 | Main4 | BLOCKTXN | 127889 |  | 2026-03-23T16:02:31.190960Z [msghand] [net] received: blocktxn (267101 bytes) peer=127889|
|16:02:31.216282 | Main4 | CMPCTBLOCK Reconstructed | 127889 |  | 2026-03-23T16:02:31.216282Z [msghand] [cmpctblock] Successfully reconstructed block 0000000000000000000085ebdcd669c404195dbfeccbee902fc646dadc367a20 with 1 txn prefilled, 3272 txn from mempool (incl at least 80 from extra pool) and 732 txn (267066 bytes) requested|
|16:02:35.325659 | Main4 | BLOCK | 200279 |  | 2026-03-23T16:02:35.325659Z [msghand] [net] received block 0000000000000000000085ebdcd669c404195dbfeccbee902fc646dadc367a20 peer=200279|
|16:04:49.362087 | Main5 | HEADERS | 127889 |  | 2026-03-23T16:04:49.362087Z [msghand] Saw new cmpctblock header hash=00000000000000000001f8562235e11fc74d5eea589e4c37b671b4213e89f52f height=941885 peer=127889 peeraddr=X|
|16:04:49.362198 | Main5 | GETDATA |  | 127889 | 2026-03-23T16:04:49.362198Z [msghand] [net] Requesting block 00000000000000000001f8562235e11fc74d5eea589e4c37b671b4213e89f52f from  peer=127889|
|16:04:49.376749 | Main5 | INV | 140374 |  | 2026-03-23T16:04:49.376749Z [msghand] [net] got inv: block 00000000000000000001f8562235e11fc74d5eea589e4c37b671b4213e89f52f  have peer=140374|
|16:04:50.082036 | Main5 | BLOCK | 127889 |  | 2026-03-23T16:04:50.082036Z [msghand] [net] received block 00000000000000000001f8562235e11fc74d5eea589e4c37b671b4213e89f52f peer=127889|
|16:04:55.059965 | Main5 | INV | 215836 |  | 2026-03-23T16:04:55.059965Z [msghand] [net] got inv: block 00000000000000000001f8562235e11fc74d5eea589e4c37b671b4213e89f52f  have peer=215836|
|16:05:01.441346 | Foundry1 | Block stall timeout: disconnect peer | 140374 |  | 2026-03-23T16:05:01.441346Z [msghand] Timeout downloading block 00000000000000000000bd4930a5982911e7749eb491886206e71abdc1ec0cc6, disconnecting peer=140374 peeraddr=80.251.125.221:35626|
|16:05:01.474666 | Foundry1 | GETDATA |  | 147259 | 2026-03-23T16:05:01.474666Z [msghand] [net] Requesting block 00000000000000000000bd4930a5982911e7749eb491886206e71abdc1ec0cc6 (941881) peer=147259|
|16:05:01.474694 | Foundry2 | GETDATA |  | 147259 | 2026-03-23T16:05:01.474694Z [msghand] [net] Requesting block 00000000000000000000724eac69a18c6699c9f7aaab24bcf18beb2723ccadd2 (941882) peer=147259|
|16:05:03.395825 | Foundry1 | BLOCK | 147259 |  | 2026-03-23T16:05:03.395825Z [msghand] [net] received block 00000000000000000000bd4930a5982911e7749eb491886206e71abdc1ec0cc6 peer=147259|
|16:05:04.384588 | Foundry2 | BLOCK | 147259 |  | 2026-03-23T16:05:04.384588Z [msghand] [net] received block 00000000000000000000724eac69a18c6699c9f7aaab24bcf18beb2723ccadd2 peer=147259|
|16:05:04.668570 | Antpool1 | Update Tip |  |  | 2026-03-23T16:05:04.668570Z [msghand] UpdateTip: new best=00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 height=941881 version=0x3092c000 log2_work=96.137382 tx=1327000957 date='2026-03-23T15:49:35Z' progress=0.999990 cache=582.2MiB(4358698txo)|
|16:05:04.668604 | Antpool2 | Block Disconnected |  |  | 2026-03-23T16:05:04.668604Z [msghand] [validation] Enqueuing BlockDisconnected: block hash=00000000000000000000c81cbf94a12ca498e72eb8530f7061c8746cf9687b2e block height=941882|
|16:05:04.668778 | Antpool2 | Block Disconnected |  |  | 2026-03-23T16:05:04.668778Z [scheduler] [validation] BlockDisconnected: block hash=00000000000000000000c81cbf94a12ca498e72eb8530f7061c8746cf9687b2e block height=941882|
|16:05:05.084714 | Antpool1 | Block Disconnected |  |  | 2026-03-23T16:05:05.084714Z [msghand] [validation] Enqueuing BlockDisconnected: block hash=00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 block height=941881|
|16:05:05.084967 | Antpool1 | Block Disconnected |  |  | 2026-03-23T16:05:05.084967Z [scheduler] [validation] BlockDisconnected: block hash=00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 block height=941881|
|16:05:05.405137 | Foundry1 | Update Tip |  |  | 2026-03-23T16:05:05.405137Z [msghand] UpdateTip: new best=00000000000000000000bd4930a5982911e7749eb491886206e71abdc1ec0cc6 height=941881 version=0x22cd4000 log2_work=96.137382 tx=1327000861 date='2026-03-23T15:49:47Z' progress=0.999990 cache=582.2MiB(4358725txo)|
|16:05:05.810945 | Foundry2 | Update Tip |  |  | 2026-03-23T16:05:05.810945Z [msghand] UpdateTip: new best=00000000000000000000724eac69a18c6699c9f7aaab24bcf18beb2723ccadd2 height=941882 version=0x3427e000 log2_work=96.137391 tx=1327005400 date='2026-03-23T15:51:25Z' progress=0.999993 cache=582.7MiB(4362711txo)|
|16:05:06.302796 | Foundry3 | Update Tip |  |  | 2026-03-23T16:05:06.302796Z [msghand] UpdateTip: new best=000000000000000000009c9acd0bc3207fa181f79f8573bf27d8a81d1ef3aa8e height=941883 version=0x2fc2e000 log2_work=96.137401 tx=1327009788 date='2026-03-23T15:54:49Z' progress=0.999995 cache=583.2MiB(4367114txo)|
|16:05:06.365100 | Foundry3 | UpdateTip | 214021 |  | 2026-03-23T16:05:06.365100Z [msghand] [validation] Enqueuing UpdatedBlockTip: new block hash=000000000000000000009c9acd0bc3207fa181f79f8573bf27d8a81d1ef3aa8e fork block hash=0000000000000000000199a739b635c5707a2bda57231b8abe846216ca0cc989 (in IBD=false)|
|16:05:06.962855 | Main4 | Update Tip |  |  | 2026-03-23T16:05:06.962855Z [msghand] UpdateTip: new best=0000000000000000000085ebdcd669c404195dbfeccbee902fc646dadc367a20 height=941884 version=0x212b4000 log2_work=96.137410 tx=1327013793 date='2026-03-23T16:02:14Z' progress=0.999998 cache=583.7MiB(4371336txo)|
|16:05:06.963006 | Main4 | UpdateTip | 200279 |  | 2026-03-23T16:05:06.963006Z [msghand] [validation] Enqueuing UpdatedBlockTip: new block hash=0000000000000000000085ebdcd669c404195dbfeccbee902fc646dadc367a20 fork block hash=000000000000000000009c9acd0bc3207fa181f79f8573bf27d8a81d1ef3aa8e (in IBD=false)|
|16:05:07.384763 | Main5 | Update Tip |  |  | 2026-03-23T16:05:07.384763Z [msghand] UpdateTip: new best=00000000000000000001f8562235e11fc74d5eea589e4c37b671b4213e89f52f height=941885 version=0x22abe000 log2_work=96.137420 tx=1327018030 date='2026-03-23T16:04:46Z' progress=1.000000 cache=584.2MiB(4374804txo)|
|16:05:07.384908 | Main5 | UpdateTip | 215836 |  | 2026-03-23T16:05:07.384908Z [msghand] [validation] Enqueuing UpdatedBlockTip: new block hash=00000000000000000001f8562235e11fc74d5eea589e4c37b671b4213e89f52f fork block hash=0000000000000000000085ebdcd669c404195dbfeccbee902fc646dadc367a20 (in IBD=false)|
[/details]

-------------------------

b10c | 2026-03-27 09:24:35 UTC | #23

And `erin`, a node that got the Foundry blocks quickly after the 941883 Foundry block was mined:

[details="erin"]

|Time           |Block   |Msg/Action              |From Peer|To Peer|Log message                                                                                                                                                                                                                                                                                 |
|---------------|--------|------------------------|---------|-------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|15:49:54.446727|Antpool1|GETDATA                 |         |916529 |2026-03-23T15:49:54.446727Z [msghand] [net] Requesting block 00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 from  peer=916529                                                                                                                                             |
|15:49:54.544777|Antpool1|GETBLOCKTXN             |         |33316  |2026-03-23T15:49:54.543863Z [msghand] [cmpctblock] Initialized PartiallyDownloadedBlock for block 00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 using a cmpctblock of size 27910 \n 2026-03-23T15:49:54.544777Z [msghand] [net] sending getblocktxn (93 bytes) peer=33316|
|15:49:54.831280|Antpool1|BLOCKTXN                |33316    |       |2026-03-23T15:49:54.831280Z [msghand] [net] received: blocktxn (21507 bytes) peer=33316                                                                                                                                                                                                     |
|15:49:54.893326|Antpool1|CMPCTBLOCK Reconstructed|33316    |       |2026-03-23T15:49:54.893326Z [msghand] [cmpctblock] Successfully reconstructed block 00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 with 1 txn prefilled, 4510 txn from mempool (incl at least 0 from extra pool) and 56 txn requested                                     |
|15:49:55.981257|Antpool1|Update Tip              |         |       |2026-03-23T15:49:55.981257Z [msghand] UpdateTip: new best=00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 height=941881 version=0x3092c000 log2_work=96.137382 tx=1327000957 date='2026-03-23T15:49:35Z' progress=1.000000 cache=243.8MiB(1624562txo)                      |
|15:49:55.981503|Antpool1|UpdateTip               |33316    |       |2026-03-23T15:49:55.981503Z [msghand] [validation] Enqueuing UpdatedBlockTip: new block hash=00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 fork block hash=0000000000000000000199a739b635c5707a2bda57231b8abe846216ca0cc989 (in IBD=false)                               |
|15:51:47.098370|Antpool2|GETDATA                 |         |1030531|2026-03-23T15:51:47.098370Z [msghand] [net] Requesting block 00000000000000000000c81cbf94a12ca498e72eb8530f7061c8746cf9687b2e from  peer=1030531                                                                                                                                            |
|15:51:47.160858|Antpool2|CMPCTBLOCK Reconstructed|1030531  |       |2026-03-23T15:51:47.160858Z [msghand] [cmpctblock] Successfully reconstructed block 00000000000000000000c81cbf94a12ca498e72eb8530f7061c8746cf9687b2e with 1 txn prefilled, 871 txn from mempool (incl at least 1 from extra pool) and 0 txn requested                                       |
|15:51:47.421524|Antpool2|Update Tip              |         |       |2026-03-23T15:51:47.421524Z [msghand] UpdateTip: new best=00000000000000000000c81cbf94a12ca498e72eb8530f7061c8746cf9687b2e height=941882 version=0x2008c000 log2_work=96.137391 tx=1327001829 date='2026-03-23T15:51:19Z' progress=1.000000 cache=243.8MiB(1625693txo)                      |
|15:51:47.421714|Antpool2|UpdateTip               |1030531  |       |2026-03-23T15:51:47.421714Z [msghand] [validation] Enqueuing UpdatedBlockTip: new block hash=00000000000000000000c81cbf94a12ca498e72eb8530f7061c8746cf9687b2e fork block hash=00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 (in IBD=false)                               |
|15:55:05.887027|Foundry1|GETDATA                 |         |33316  |2026-03-23T15:55:05.887027Z [msghand] [net] Requesting block 00000000000000000000bd4930a5982911e7749eb491886206e71abdc1ec0cc6 from  peer=33316                                                                                                                                              |
|15:55:05.887054|Foundry2|GETDATA                 |         |33316  |2026-03-23T15:55:05.887054Z [msghand] [net] Requesting block 00000000000000000000724eac69a18c6699c9f7aaab24bcf18beb2723ccadd2 from  peer=33316                                                                                                                                              |
|15:55:05.887075|Foundry3|GETDATA                 |         |33316  |2026-03-23T15:55:05.887075Z [msghand] [net] Requesting block 000000000000000000009c9acd0bc3207fa181f79f8573bf27d8a81d1ef3aa8e from  peer=33316                                                                                                                                              |
|15:55:06.374803|Foundry1|BLOCK                   |33316    |       |2026-03-23T15:55:06.374803Z [msghand] [net] received block 00000000000000000000bd4930a5982911e7749eb491886206e71abdc1ec0cc6 peer=33316                                                                                                                                                      |
|15:55:06.747076|Foundry2|BLOCK                   |33316    |       |2026-03-23T15:55:06.747076Z [msghand] [net] received block 00000000000000000000724eac69a18c6699c9f7aaab24bcf18beb2723ccadd2 peer=33316                                                                                                                                                      |
|15:55:07.071938|Foundry3|BLOCK                   |33316    |       |2026-03-23T15:55:07.071938Z [msghand] [net] received block 000000000000000000009c9acd0bc3207fa181f79f8573bf27d8a81d1ef3aa8e peer=33316                                                                                                                                                      |
|15:55:07.497775|Antpool1|Update Tip              |         |       |2026-03-23T15:55:07.497775Z [msghand] UpdateTip: new best=00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 height=941881 version=0x3092c000 log2_work=96.137382 tx=1327000957 date='2026-03-23T15:49:35Z' progress=0.999999 cache=243.8MiB(1625385txo)                      |
|15:55:07.497915|Antpool2|Block Disconnected      |         |       |2026-03-23T15:55:07.497915Z [msghand] [validation] Enqueuing BlockDisconnected: block hash=00000000000000000000c81cbf94a12ca498e72eb8530f7061c8746cf9687b2e block height=941882                                                                                                             |
|15:55:07.498351|Antpool2|Block Disconnected      |         |       |2026-03-23T15:55:07.498351Z [scheduler] [validation] BlockDisconnected: block hash=00000000000000000000c81cbf94a12ca498e72eb8530f7061c8746cf9687b2e block height=941882                                                                                                                     |
|15:55:08.260316|Antpool1|Block Disconnected      |         |       |2026-03-23T15:55:08.260316Z [msghand] [validation] Enqueuing BlockDisconnected: block hash=00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 block height=941881                                                                                                             |
|15:55:08.260635|Antpool1|Block Disconnected      |         |       |2026-03-23T15:55:08.260635Z [scheduler] [validation] BlockDisconnected: block hash=00000000000000000001b3ff8b13e57c3ec1eca3ba7d2937edbd9f219eb2d9f3 block height=941881                                                                                                                     |
|15:55:08.715253|Foundry1|Update Tip              |         |       |2026-03-23T15:55:08.715253Z [msghand] UpdateTip: new best=00000000000000000000bd4930a5982911e7749eb491886206e71abdc1ec0cc6 height=941881 version=0x22cd4000 log2_work=96.137382 tx=1327000861 date='2026-03-23T15:49:47Z' progress=0.999999 cache=243.8MiB(1625382txo)                      |
|15:55:09.519207|Foundry2|Update Tip              |         |       |2026-03-23T15:55:09.519207Z [msghand] UpdateTip: new best=00000000000000000000724eac69a18c6699c9f7aaab24bcf18beb2723ccadd2 height=941882 version=0x3427e000 log2_work=96.137391 tx=1327005400 date='2026-03-23T15:51:25Z' progress=0.999999 cache=243.9MiB(1629023txo)                      |
|15:55:10.206706|Foundry3|Update Tip              |         |       |2026-03-23T15:55:10.206706Z [msghand] UpdateTip: new best=000000000000000000009c9acd0bc3207fa181f79f8573bf27d8a81d1ef3aa8e height=941883 version=0x2fc2e000 log2_work=96.137401 tx=1327009788 date='2026-03-23T15:54:49Z' progress=1.000000 cache=243.9MiB(1632872txo)                      |
|15:55:10.273036|Foundry3|UpdateTip               |33316    |       |2026-03-23T15:55:10.273036Z [msghand] [validation] Enqueuing UpdatedBlockTip: new block hash=000000000000000000009c9acd0bc3207fa181f79f8573bf27d8a81d1ef3aa8e fork block hash=0000000000000000000199a739b635c5707a2bda57231b8abe846216ca0cc989 (in IBD=false)                               |
|16:02:30.912021|Main4   |HEADERS                 |33316    |       |2026-03-23T16:02:30.912021Z [msghand] Saw new cmpctblock header hash=0000000000000000000085ebdcd669c404195dbfeccbee902fc646dadc367a20 peer=33316                                                                                                                                            |
|16:02:31.006373|Main4   |CMPCTBLOCK Reconstructed|33316    |       |2026-03-23T16:02:31.006373Z [msghand] [cmpctblock] Successfully reconstructed block 0000000000000000000085ebdcd669c404195dbfeccbee902fc646dadc367a20 with 1 txn prefilled, 4004 txn from mempool (incl at least 1 from extra pool) and 0 txn requested                                      |
|16:02:31.941123|Main4   |Update Tip              |         |       |2026-03-23T16:02:31.941123Z [msghand] UpdateTip: new best=0000000000000000000085ebdcd669c404195dbfeccbee902fc646dadc367a20 height=941884 version=0x212b4000 log2_work=96.137410 tx=1327013793 date='2026-03-23T16:02:14Z' progress=1.000000 cache=243.9MiB(1636692txo)                      |
|16:02:31.941341|Main4   |UpdateTip               |33316    |       |2026-03-23T16:02:31.941341Z [msghand] [validation] Enqueuing UpdatedBlockTip: new block hash=0000000000000000000085ebdcd669c404195dbfeccbee902fc646dadc367a20 fork block hash=000000000000000000009c9acd0bc3207fa181f79f8573bf27d8a81d1ef3aa8e (in IBD=false)                               |
|16:04:49.519298|Main5   |HEADERS                 |33316    |       |2026-03-23T16:04:49.519298Z [msghand] Saw new cmpctblock header hash=00000000000000000001f8562235e11fc74d5eea589e4c37b671b4213e89f52f peer=33316                                                                                                                                            |
|16:04:49.548922|Main5   |GETBLOCKTXN             |         |33316  |2026-03-23T16:04:49.547835Z [msghand] [cmpctblock] Initialized PartiallyDownloadedBlock for block 00000000000000000001f8562235e11fc74d5eea589e4c37b671b4213e89f52f using a cmpctblock of size 25887 \n 2026-03-23T16:04:49.548922Z [msghand] [net] sending getblocktxn (57 bytes) peer=33316|
|16:04:49.587102|Main5   |BLOCKTXN                |33316    |       |2026-03-23T16:04:49.587102Z [msghand] [net] received: blocktxn (16112 bytes) peer=33316                                                                                                                                                                                                     |
|16:04:49.645486|Main5   |CMPCTBLOCK Reconstructed|33316    |       |2026-03-23T16:04:49.645486Z [msghand] [cmpctblock] Successfully reconstructed block 00000000000000000001f8562235e11fc74d5eea589e4c37b671b4213e89f52f with 1 txn prefilled, 4216 txn from mempool (incl at least 14 from extra pool) and 20 txn requested                                    |
|16:04:50.698310|Main5   |Update Tip              |         |       |2026-03-23T16:04:50.698310Z [msghand] UpdateTip: new best=00000000000000000001f8562235e11fc74d5eea589e4c37b671b4213e89f52f height=941885 version=0x22abe000 log2_work=96.137420 tx=1327018030 date='2026-03-23T16:04:46Z' progress=1.000000 cache=243.9MiB(1640026txo)                      |
|16:04:50.698627|Main5   |UpdateTip               |33316    |       |2026-03-23T16:04:50.698627Z [msghand] [validation] Enqueuing UpdatedBlockTip: new block hash=00000000000000000001f8562235e11fc74d5eea589e4c37b671b4213e89f52f fork block hash=0000000000000000000085ebdcd669c404195dbfeccbee902fc646dadc367a20 (in IBD=false)                               |
|16:21:26.500000|Main5   |BLOCKTXN                |33316    |       |2026-03-23T16:21:26.500000Z [msghand] [net] received: blocktxn (12652 bytes) peer=33316                                                                                                                                                                                                     |

[/details]

-------------------------

b10c | 2026-03-26 18:06:15 UTC | #24

The peer that stalled some of the nodes is using the UserAgent `semikek`. The code for this client seems to be https://github.com/Charterino/bitlens-rs/blob/dad40cb2ed98d4ba99792bc0ee621ec2982b4b97/src/connect/mod.rs#L60

-------------------------

murchandamus | 2026-03-27 05:09:54 UTC | #25

Perhaps charterino, its dev is completely unaware of how the node’s behavior affects other nodes. Maybe someone should open an issue there to make him aware?

-------------------------

b10c | 2026-03-27 08:57:32 UTC | #26

I've opened https://github.com/Charterino/bitlens-rs/issues/2 

Probaly good to also link the IRC discussion here: https://bitcoin-irc.chaincode.com/bitcoin-core-dev/2026-03-26#1774543334-1774545381

-------------------------

Charterino | 2026-03-27 09:17:35 UTC | #27

Thank you for bringing this up to my attention! murchandamus is correct, I was unaware of this. What do you guys think is the best thing for me to do here? Other than respond to GETDATA requests.

-------------------------

b10c | 2026-03-27 14:08:34 UTC | #28

[quote="jungly, post:16, topic:97, full:true"]
[quote="zawy12, post:14, topic:97"]
This is effectively a selfish-mining attack by definition even if it was on “accident” or network hiccup (to the extent “attack” doesn’t imply intentional). But it all seems to point to intentional.
[/quote]

Yup. I have reached the same conclusion. Happy to see you are thinking along the same lines.
[/quote]

> But it all seems to point to intentional.


While I agree that a selfish-minnig attack might look similar on monitoring tools, I don't think this was one. And if it was one, it was a poorly exectued one:

- why briefly mine on AntPools and ViaBTC's blocks?
- why reveal it to the world during a low fee period? The two reorged blocks made 0.008 + 0.017 BTC in fees.. This is a bad risk (of e.g. miners moving away) reward I would not take.

I guess if I'm wrong, then we are going to see it again soonish.

However, my main reason is the following: The data we've seen exactly matches the expected network and relay behavior. I've written a Bitcoin Core functional test that shows this.

To summarize some data:
1. We know Foundry uses `preciousblock` and we've seen them use it multiple times before in e.g. https://b10c.me/blog/014-mining-pool-behavior-during-forks/ - and it's a very reasonable thing to do, if you want to maximize profits.
2. We know Foundry switched to their blocks AFTER briefly mining on the AntPool & ViaBTC blocks for a second each: https://bnoc.xyz/t/two-block-reorg-at-height-941880/97/20?u=b10c
3. We know the Foundry blocks didn't propagate well. We had @matthias share a very valuable global network view on this in https://bnoc.xyz/t/two-block-reorg-at-height-941880/97/18?u=b10c, we have Json Huge from OCEAN who said `No DATUM miner on OCEAN ever built work on top of either Foundry block 941881 or 941882 (around a thousand globally diverse nodes)` (https://x.com/wk057/status/2036674054971703361), and we have a bunch of monitoring nodes that didn't see them either before we reorged.

This functional test mimics the event stratum job event order from 2), uses `preciousblock` 1), and checks that the header does not propagate further than one hop from the miner (and the block does not propagate at all) as seen in 3).


```python
#!/usr/bin/env python3
# Copyright (c) 2022-present The Bitcoin Core developers
# Distributed under the MIT software license, see the accompanying
# file COPYING or http://www.opensource.org/licenses/mit-license.php.
""" Shows what nodes consider the tip during a two block fork where miners use preciousblock.

This is meant to explain the network behavior seen in:
https://bnoc.xyz/t/two-block-reorg-at-height-941880/97

- The two Foundry blocks didn't propagate well as they weren't seen first (here F881 and F882)
- Only a few nodes announced the Foundry blocks F881 and F882, but the headers weren't realyed
- The AntPool and ViaBTC blocks did propagate well as they were seen first
"""

from test_framework.test_framework import BitcoinTestFramework
from test_framework.blocktools import create_block
from test_framework.util import assert_equal

class TwoBlockReorg(BitcoinTestFramework):

    def set_test_params(self):
        self.setup_clean_chain = True
        self.num_nodes = 4

    def setup_network(self):
        self.setup_nodes()
        # Construct a network:
        # minerA -> node1 <-> node2 <- minerF
        # node1 is connected to minerA and node2
        # node2 is connected to minerF and node1
        #
        # minerA to node1
        self.connect_nodes(0, 1)
        # node1 to node2 and node2 to node1
        self.connect_nodes(1, 2)
        self.connect_nodes(2, 1)
        # minerF to node2
        self.connect_nodes(3, 2)

    def run_test(self):
        minerA = self.nodes[0]
        node1 = self.nodes[1]
        node2 = self.nodes[2]
        minerF = self.nodes[3]

        self.log.info("Setup network: minerA -> node1 <-> node2 <- minerF")
        self.log.info("Mining one block on node1 and verify all nodes sync")

        # generate verify's that all nodes are in sync under the hood
        self.generate(node1, 880)
        # We start of at height 880. G is the Genesis block.
        #  G - ... -  880

        assert_equal(node1.getblockcount(), 880)
        assert_equal(node1.getblockcount(), node2.getblockcount())
        assert_equal(node1.getblockcount(), minerA.getblockcount())
        assert_equal(minerF.getblockcount(), minerA.getblockcount())

        self.log.info("minerF starts working on a block block F881")
        blockF881 = create_block(
            hashprev=int(node1.getbestblockhash(), 16),
            tmpl={"height": 881}
        )

        self.log.info("however, minerA beats it and publishes a block A881 and everybody sees it")
        self.generate(minerA, 1)

        #   G ... -- 880 -- A881
        #                     ^: minerA, minerF, node1, node2
        assert_equal(node1.getblockcount(), 881)
        assert_equal(node1.getblockcount(), node2.getblockcount())
        assert_equal(node1.getblockcount(), minerA.getblockcount())
        assert_equal(minerF.getblockcount(), minerA.getblockcount())

        self.log.info("minerF finds the block F881, publishes it, and switches to it")
        blockF881.solve()
        minerF.submitblock(blockF881.serialize().hex())
        # minerF is still on the minerA block, as it heard about this one first
        assert_equal(minerF.getbestblockhash(), minerA.getbestblockhash())
        minerF.preciousblock(blockF881.hash_hex)
        assert_equal(minerF.getbestblockhash(), blockF881.hash_hex)

        # We now have a fork.
        #                   v: minerF
        #             /- F881
        #  G .. -- 880
        #             \- A881
        #                   ^: minerA, node1, node2

        self.log.info("Only node2, who is directly connected to minerF, has seen F881. It did not relay the header/block to node1")
        chaintips_node1 = node1.getchaintips()
        chaintips_node2 = node2.getchaintips()
        assert_equal(len(chaintips_node2), 2)
        for tip in chaintips_node2:
            if tip["status"] == "active":
                assert_equal(tip["hash"], minerA.getbestblockhash())
            elif tip["status"] == "headers-only":
                assert_equal(tip["hash"], blockF881.hash_hex)

        assert_equal(len(chaintips_node1), 1)
        assert_equal(chaintips_node1[0]["hash"], minerA.getbestblockhash())


        self.log.info("Our node1 node is still on the A881 block, as it saw this one first")
        assert_equal(node1.getbestblockhash(), minerA.getbestblockhash())

        self.log.info("Again, minerF starts mining on a block F882")
        blockF882 = create_block(
            hashprev=int(minerF.getbestblockhash(), 16),
            tmpl={"height": 882}
        )

        self.log.info("minerA finds block A882. node1 and minerF switch to it")
        self.generate(minerA, 1)
        #
        #             /- F881
        #  G .. -- 880
        #             \- A881 - A882
        #                          ^: minerA, minerF, node1
        assert_equal(node1.getbestblockhash(), minerA.getbestblockhash())
        assert_equal(minerF.getbestblockhash(), minerA.getbestblockhash())

        self.log.info("minerF finds block F882, publishes it, and switches to it")
        blockF882.solve()
        minerF.submitblock(blockF882.serialize().hex())
        # minerF is still on the minerA block, as it heard about this one first
        assert_equal(minerF.getbestblockhash(), minerA.getbestblockhash())
        minerF.preciousblock(blockF882.hash_hex)
        assert_equal(minerF.getbestblockhash(), blockF882.hash_hex)

        # We now have a two block fork.
        #                          v: minerF
        #             /- F881 - F882
        #  G .. -- 880
        #             \- A881 - A882
        #                          ^: minerA, node1

        self.log.info("Only node2, who is directly connected to minerF, has seen F882. It did not relay the header/block to node1")
        chaintips_node1 = node1.getchaintips()
        chaintips_node2 = node2.getchaintips()
        assert_equal(len(chaintips_node2), 2)
        for tip in chaintips_node2:
            if tip["status"] == "active":
                assert_equal(tip["hash"], minerA.getbestblockhash())
            elif tip["status"] == "headers-only":
                assert_equal(tip["hash"], blockF882.hash_hex)

        assert_equal(len(chaintips_node1), 1)
        assert_equal(chaintips_node1[0]["hash"], minerA.getbestblockhash())

        self.log.info("minerF finds block F883, causing a two block reorg")
        self.generate(minerF, 1)

        #                                 v: minerF, minerA, node1
        #             /- F881 - F882 - F883
        #  G .. -- 880
        #             \- A881 - A882
        #
        assert_equal(node1.getbestblockhash(), minerA.getbestblockhash())
        assert_equal(minerF.getbestblockhash(), minerA.getbestblockhash())

        self.log.info("minerF wins the fork race")


if __name__ == '__main__':
    TwoBlockReorg(__file__).main()
```

Can also be found [here](https://github.com/0xB10C/bitcoin/commit/d1e69f6feb72cf2bf58c49d95e09c8ece8bf3698).

The test outputs the following:

```
TestFramework (INFO): PRNG seed is: 1283534758446118571
TestFramework (INFO): Initializing test directory bitcoin_func_test_k7vv6x4w
TestFramework (INFO): Setup network: minerA -> node1 <-> node2 <- minerF
TestFramework (INFO): Mining one block on node1 and verify all nodes sync
TestFramework (INFO): minerF starts working on a block block F881
TestFramework (INFO): however, minerA beats it and publishes a block A881 and everybody sees it
TestFramework (INFO): minerF finds the block F881, publishes it, and switches to it
TestFramework (INFO): Only node2, who is directly connected to minerF, has seen F881. It did not relay the header/block to node1
TestFramework (INFO): Our node1 node is still on the A881 block, as it saw this one first
TestFramework (INFO): Again, minerF starts mining on a block F882
TestFramework (INFO): minerA finds block A882. node1 and minerF switch to it
TestFramework (INFO): minerF finds block F882, publishes it, and switches to it
TestFramework (INFO): Only node2, who is directly connected to minerF, has seen F882. It did not relay the header/block to node1
TestFramework (INFO): minerF finds block F883, causing a two block reorg
TestFramework (INFO): minerF wins the fork race
TestFramework (INFO): Stopping nodes
TestFramework (INFO): Cleaning up bitcoin_func_test_k7vv6x4w on exit
TestFramework (INFO): Tests successful
```


In https://stacker.news/items/1460166, @murchandamus comes to a similar conclusion: expected network behavior.

-------------------------

zawy12 | 2026-03-27 15:07:57 UTC | #29

[quote="b10c, post:28, topic:97"]
why briefly mine on AntPools and ViaBTC’s blocks?

[/quote]

The question for me is “Why did they stop mining on them?” Maybe they received a “late header” from their miner but had not yet validated the block for the “foreign” header, so they go with the first block they can validate. Maybe the reason Foundry’s blocks 1 and 2 were so late in being seen is because most nodes had validated the other blocks before seeing them.

If this is the case, then the rules aren’t strictly following proof of work which means “the partition with the highest hashrate”.  We’re following “proof of fastest block validation”.  To strictly follow proof of work, both headers should be relayed and mined equally by each miner who receives them immediately from the same peer, or within half a typical network propagation delay from different peers, until both blocks have had “sufficient” time to be transmitted and validated. If that estimated time has not passed, other miners continue working on the header that came first even if the other header’s block can be validated. In this way, the partition that had the highest hashrate wins.

The timestamp differences are less than 1/2 the standard deviation of their accuracy, so they can’t be used to make a determination.

The link didn’t seem to indicate @murchandamus concludes it was normal network behavior.

With only 33% hashrate and apparently not getting much help from other miners, Foundry can’t expect to profit from it being a selfish mining attack (at 33% it would be break even for “gamma=0”).

-------------------------

b10c | 2026-03-27 15:22:31 UTC | #30

[quote="zawy12, post:29, topic:97"]
The question for me is “Why did they stop mining on them?”
[/quote]

In the case where your pool is competing with another pool in a block-race, you want to be mining on your own block. Let's play the scenario through with an example:

Imagine you're a pool with 1% of the hashrate and you just found a valid block, but know that the other 99% of hashrate just switched to another block found by a competing pool.

Case A: You mine on the competing block and give up on your own block. The chance of you finding the next block are 1%. You can gain the block reward of that next block, if you find it.

Case B: You mine on your own block (e.g. by switching to it via `preciousblock`) and ignore the competing one. Your chance of finding the next block is still 1%, however if you do, you get the reward from your previous block and the next one.

Case B is strictly better for a pool. No matter the odds.

-------------------------

b10c | 2026-03-27 15:28:14 UTC | #31

[quote="zawy12, post:29, topic:97"]
The link didn’t seem to indicate @murchandamus concludes it was normal network behavior.
[/quote]

I guess @murchandamus might chime in at some point, but to quote him a bit from that link:

> However, if the timestamps are accurate, it is possible that Foundry found both of those blocks *just after* the competing blocks were found, before they had learned about the competing blocks, but after their block would have propagated widely on the network.

> It could perhaps even be the case that the block was found by a pool participant even after Foundry saw the Antpool block, but before they had updated all the jobs. It would still make sense and not be malicious for a pool to mine on their own block when they have one.

> As I [mentioned above](https://stacker.news/items/1460166), Bitcoin Core nodes will request and store blocks in competing chaintips with the same PoW as their best chaintip, but they will not announce those blocks to their own peers. Even if Foundry had announced it after having found it, the block could have not made it beyond the Foundry nodes’ peers if they all had seen the competing block before it, or it would have possible made it another hope from a few peers before getting blackholed.

>> Thanks for these details. So, it's not a huge leap to say that it was mostly a coincidence that some nodes didn't see Foundry's blocks until after the reorganization?
>
> I think that it is plausible, yeah. And if we’re honest, Bitcoiners tend to entertain conspiracy theories perhaps a little to enthusiastically.

-------------------------

zawy12 | 2026-03-27 16:25:57 UTC | #32

[quote="b10c, post:30, topic:97"]
Imagine you’re a pool with 1% of the hashrate …

[/quote]

I completely missed that, but it works the same as a selfish mining attack. It’s not following proof of work, i.e. mining on the partitition with the highest hashrate. The pool knows which block came first and it knows the majority hashrate isn’t working on his “private” block.

Murch doesn’t seem to “conclude it was” an accident, but shows it could have been. But an accidental delay in getting new jobs out to workers works the same as a selfish mining attack. We can’t know if a pool does it on purpose or not.  The pool only has to “accidentally” delay getting new jobs out to workers for it to be a purposeful attack. Another tactic is to “accidentally” delay releasing a block, or for the 2 largest pools to make sure they have a faster connection to each other than to the rest of the network. For example if they are 50 ms apart instead of the median of 500 ms, they gain 0.45/600 = 0.075% excess rewards.

To reiterate what I said before, selfish mining is possible only because timestamps aren’t enforced more accurately than MTP and FTL. It’s not a clever attack as much as it’s the result of not following strict proof of work rules, i.e. staying on the chain that has the highest hashrate since the last block, which requires checking to see if the timestamps are reasonable compared to typical network delays in the manner I described.

-------------------------

mzumsande | 2026-03-27 16:48:57 UTC | #33


[quote="Charterino, post:27, topic:97"]
What do you guys think is the best thing for me to do here? Other than respond to GETDATA requests.

[/quote]

I’d say it would be helpful to only INV blocks that you can actually provide. Ideally answering GETDATA requests, or if that is an issue for some reason, not sending INV for those blocks in the first place. That being said, the Bitcoin Core behavior should be improved too (e.g. by lowering timeouts or allowing to download from another peer if there is a staller), which is being discussed in https://github.com/bitcoin/bitcoin/issues/33687

-------------------------

jungly | 2026-04-01 04:05:01 UTC | #34

[quote="b10c, post:28, topic:97"]
We know the Foundry blocks didn’t propagate well.

[/quote]

Nice analysis. Thanks for continuing to dig into this. About foundary blocks not propagating well, is it possible to see stats on time it takes for blocks from different pools to propagate? You probably have this already somewhere :slight_smile:

-------------------------

murchandamus | 2026-04-15 21:11:31 UTC | #35

I’m not sure whether that was the question, but yes, it seemed to me that there were innocuous explanations why we saw that two-block reorg, but I didn’t have enough data to make any confident determination. Per the data that b10c has provided since, it seems to me that Foundry indeed found their blocks slightly after the competing blocks, but decided to mine on their own blocks while the chaintips were tied which seems completely reasonable.

-------------------------

