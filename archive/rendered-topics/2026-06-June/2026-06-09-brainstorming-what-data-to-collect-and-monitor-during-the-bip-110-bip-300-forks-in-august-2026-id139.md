# Brainstorming: What data to collect and monitor during the BIP-110 & BIP-300 forks in August 2026?

b10c | 2026-06-09 10:00:18 UTC | #1

For August 2026, there are currently two forks scheduled:

- BIP-110 at height 961632 (early August; around 2026-08-07)
- BIP-300 on 2026-08-21 (ecash.com). I think there's no fixed activation height set yet?

It would be good to discuss what monitoring and data collection would be worthwhile for this. I invite everyone interested in this to participate in the discussion here.

-------------------------

b10c | 2026-06-09 09:59:23 UTC | #2

I'll probably run a fork-observer instance with a Bitcoin Core node and a BIP-110/300 node side by side. I'll likely also live-stream this in some capacity.

Monitoring for transaction replay across the forks, assuming there are blocks for them, should be interesting as well. Not sure if I'll get to this.

For the BIP-110 fork, someone might attempt to publish data-embedding transactions into the chain around the fork height or shortly after. Especially on the BIP-110 side. It would be good to have coverage of this, even if it's not given that this will happen.

-------------------------

b10c | 2026-06-09 10:27:14 UTC | #3

Additionally: observe on which side of these forks pools are mining. This can be done with stratum data. On top of that: What side is currently more profitable to mine on given the current fees and price?

-------------------------

deadmanoz | 2026-06-09 11:11:37 UTC | #4

> At block \~964,000, the Bitcoin blockchain is read. Every address holding BTC at that moment is credited an equal amount of eCash — automatically, with no action required from you.

https://ecash.com/what-to-expect/

-------------------------

murchandamus | 2026-06-13 02:26:08 UTC | #5

It might be helpful to some to create a data set that shows whether UTXOs are unique to Bitcoin, i.e., immune to replay on RDTS. Same for eCash, if they don’t have replay protection.

-------------------------

b10c | 2026-07-01 09:09:04 UTC | #6

I’ve been thinking about adding a visualization of what-is-being-mined-on to fork-observer using stratum data: https://github.com/0xB10C/fork-observer/pull/137 

![image|517x500](upload://HVslQUrnx628Cs2uuWqoTGrXUA.png)

An idea for an activation live stream would be to show a Core and Knots+BIP110 node on fork-observer and have them both connected to a ckpool instance each, which are then connected to a stratum-observer instance. This would show which blocks the nodes consider active and which block they are mining on. Could also mix in some of the bigger pools like AntPool, F2Pool, ViaBTC, … Maybe Foundry if we can get pool details too.

The same works for the eCash activation.

-------------------------

b10c | 2026-07-03 15:40:26 UTC | #7

Seeing this makes me think we are going to see a bunch of inscriptions being broadcast for a potential BIP-110 compliant block right before around/activation: https://github.com/ordinals/ord/pull/4545 . Well, there also seems to be https://github.com/bitcoinknots/bitcoin/pull/319 now…

-------------------------

b10c | 2026-07-07 11:01:14 UTC | #8

![image|690x429](upload://sLA9F68P411uMDXCzBbQUwmcUo8.png)

added a height based countdown feature for halving/soft-forks/special heights to fork-observer: https://github.com/0xB10C/fork-observer/pull/142

-------------------------

deadmanoz | 2026-07-14 02:23:30 UTC | #9

Relevant for tracking Ocean, a variety of stratum endpoints:

https://x.com/ocean_mining/status/2074825828731342880

-------------------------

GuiSchet | 2026-07-16 13:23:23 UTC | #10

They updated the activation date to block **963,648**, instead of **964,000**. Aprox 22/08/2026

Found the node’s repo too: 
https://github.com/LayerTwo-Labs/bitcoin-patched
https://github.com/drivechain-forknet/drivechain-forknet

-------------------------

deadmanoz | 2026-07-22 03:23:09 UTC | #11

A bit of an update on the infrastructure I'm going to be putting together for the August forks. The initial focus is BIP-110 but I'm also aiming to cover off the BIP-300 eCash fork too. I feel that it's necessary for comprehensive and objective monitoring/data capture for both ongoing discourse and future research (and, well, historical preservation generally). As such, the aim is live monitoring and dissemination while the events are underway, plus archive for analysis and research afterwards. 

I've spun up 3 nodes that exist at different points in the policy spectrum: Bitcoin Knots (with RDTS enforcement enabled), Bitcoin Core and Libre Relay. This diversity gives good coverage of the policy differences (and in the likely event of a split this gives a position on each side). As these are VPS nodes, in the interest of VPS cost, they are pruned (full archival nodes running elsewhere).

Each node runs the same stack: peer-observer capturing all that it does, a `getblocktemplate` sampler, and a mempool sampler component too. Everything is captured locally (on VPS) and regularly pulled to archive. I will openly publish the archive datasets, probably on the BNOC data share, as soon possible (and as close to original form as possible).

I'm treating a persistent chain split with minority hashrate as the most likely outcome. Everything keeps running through mandatory signalling and activation at 961,632. With Knots on one side and Core and Libre Relay on the other, both sides of the split will get followed and all data collected and archived.

The aforementioned mempool sampler will feed a live visualiser to show mempool diffs. I'm also building a transaction classifier that checks everything the mempools see against the RDTS rules to show in how much of the transaction flow would be rejected under BIP-110, and how that changes around activation, including any last-minute rush of inscriptions as anticipated, etc. Also, what BIP-110 compliant yet likely "spam" is making it onto the BIP-110 side.

Also relevant to the stratum mentions above, I've started on stratum job capture against a range of pool endpoints, including OCEAN (and their new BIP-110 signalling endpoints), AntPool, F2Pool, etc. Trial collectors are running now, with the aim of having this solid before the mandatory signalling window. It should show which chain each pool is actually building on through signalling and activation (live visualised), a nice complement to the fork-observer stratum view mentioned earlier.

I'll be throwing up a public site in the next week or so to consolidate and display all this (live) information and more through the fork events. If there's any specific additional data you think should be collected or specific visualisations to show, please let me know!

Edit: probably a way to show transaction "splitting" (protection/replay) as @murchandamus suggests too

-------------------------

GuiSchet | 2026-07-27 18:52:28 UTC | #12

I started to work on a pilot extractor for the bip300301_enforcer ( https://github.com/LayerTwo-Labs/bip300301_enforcer ).

The goal is to collect the enforcer’s validated view of the chain.

-------------------------

b10c | 2026-08-07 23:44:51 UTC | #13

For Ecash/BIP 300: https://x.com/Truthcoin/status/2085825694697746745

-------------------------

deadmanoz | 2026-08-08 13:23:01 UTC | #14

I've quickly vibed together a bit of page to show some of the fork data. Had planned for much more, but focus has been COLDCARD stuff most of the week :slight_smile: 

Will add to this for the eCash fork, and then generally use the domain to organise and present the collected data after-the-fact(s).

https://bitcoin-forks.org

-------------------------

ajtowns | 2026-08-09 18:33:29 UTC | #15

No bip110 blocks in the stale-blocks repo yet?

-------------------------

b10c | 2026-08-12 07:47:41 UTC | #16

As of [date=2026-08-12 time=09:00:00 timezone=Europe/Amsterdam], the BIP-110 side of the fork as mined three blocks. The first two were added by @ajtowns in https://github.com/bitcoin-data/stale-blocks/pull/119 and the third is added in https://github.com/bitcoin-data/stale-blocks/pull/122.

![image|690x294](upload://5s4nBVPxQ2Wnn0n7xJRnZ9FCmSL.jpeg)

I guess there's the question as to what point do we continue to add them. If there's a clear hardfork, then that's probably a exclusion reason. Let's see how many more are mined before that happens.

-------------------------

b10c | 2026-08-15 09:43:04 UTC | #17

Here's more information and recordings of the monitoring livestream I did: https://b10c.me/projects/028-bip110-monitoring-livestream/. I include the following timeline:

The blocks leading up to block 961632 came in fast and the fork happened earlier than anticipated.

    19:33 UTC: the last shared block, 961631, was found.
    19:36 UTC: the non-BIP-110-signaling block 961632 was found.
    20:12 UTC: to the surprise of many, BIP-110 miners found a signaling block 961632. This forked the chain.
    20:19 UTC: F2Pool found 961633 on the non-signaling chain.
    20:30 UTC: a non-BIP-110-signaling Ocean miner found 961634. The non-signaling chain was two blocks in the lead.
    21:49 UTC: the signaling chain found its block 961633. By then, the non-signaling tip had extended to 961638.

---

Regarding transaction replay: I didn't look into this, but I aware of others how did. In this [post](https://x.com/mononautical/status/2087479928040329488), mononaut shows that most transactions in the two BIP-110 (he writes BIP-100, but I think that's a mistake) blocks, were first confirmed on the Bitcoin block chain, and then on the chain enforcing the BIP-110 signaling rule (blue). Only a handful of transactions (pink) were first mined on the BIP-110 signaling chain, and then replayed on Bitcoin. There are also a few (green) transactions that were split. 

![961634|353x500](upload://wvQAhEPGVbWRT8FP7iJgEKDO1g7.png)

![961635|353x500](upload://aNCQiYv28CwBtkFiGaCjAQ5BFwg.png)

-------------------------

b10c | 2026-08-15 09:41:56 UTC | #18

There have also been reports of the BIP-110-signaling-enforcing nodes dropping connections (I'm not sure if inbound or outbound) around mandatory signaling start. I had a brief look at the logs, but didn't find anything immediately (and then choose to spent time on other things). 

However, it seems that there was a slight drop in connections around the time the first BIP-110 signaling block was mined and then a slow, but steady drop in connections starting on [date=2026-08-10 time=03:40:00 timezone=Etc/UTC] until the next block was found.

![image|690x354](upload://nEfyvWG74NaPYw2equpCv4w1Y5p.png)

-------------------------

b10c | 2026-08-15 09:45:59 UTC | #19

Regarding BIP-300 / ecash: It seems they've changed their start heights / activation schedule a bit. It's small and legible on their website:

![image|689x191](upload://7Hsx04xibR9JEMjj4bxAmBQVKB3.png)

-------------------------

polespinasa | 2026-08-15 10:10:36 UTC | #20

Some interesting data to check is how the network was slowing splitting during the mandatory signaling; this is because non-bip110 nodes disconnected from bip110 nodes as they saw their peers in an old chain.

I cannot recover logs from the day, but if anyone has logs they should check for something like:

`[ConsiderEviction] Outbound peer has old chain, best known block = ... disconnecting peer=`

Another way to check this node drop was checking every N seconds your peers tip:

```bash
sliv3r@bitcoin:~ $ bitcoin-cli getpeerinfo | grep 961633
    "synced_headers": 961633,
    "synced_blocks": 961633,
    "synced_headers": 961633,
    "synced_blocks": 961633,
    "synced_headers": 961633,
    "synced_blocks": 961633,
    "synced_headers": 961633,
    "synced_blocks": 961633,
    "synced_headers": 961633,
    "synced_blocks": 961633,
    "synced_headers": 961633,
    "synced_blocks": 961633,
    "synced_headers": 961633,
    "synced_blocks": 961633,
    "synced_headers": 961633,
    "synced_blocks": 961633,
sliv3r@bitcoin:~ $ bitcoin-cli getpeerinfo | grep 961632
    "synced_headers": 961632,
    "synced_blocks": 961632,
sliv3r@bitcoin:/mnt/ssd/bitcoin $ bitcoin-cli getpeerinfo | grep 961632
    "synced_headers": 961632,
    "synced_blocks": 961632,
sliv3r@bitcoin:/mnt/ssd/bitcoin $ bitcoin-cli getpeerinfo | grep 961632
sliv3r@bitcoin:/mnt/ssd/bitcoin $
```

At the time of executing the first \`getpeerinfo\` non-bip110 nodes were one block ahead.

Again I fail to recover more logs, but I was able to find this from a message I shared during the signaling day. If I recall correctly the two last commands were executed with a \~5min difference. And there was another execution before the logs I still have which showed I had more than 2 stale peers (4 IIRC).

-------------------------

GuiSchet | 2026-08-22 13:14:52 UTC | #21

Quick update on my side for BIP300/301 monitoring: I built pilot bip300-monitor ( https://github.com/GuiSchet/bip300-monitor ), a pipeline that collects the enforcer’s validated chain state, normalizes snapshots and live block events, and publishes them through NATS. It also includes an event logger, container images, automated checks, and a reproducible eCash Drynet deployment.

I currently have the stack running on a dedicated VM. Over the next weeks, I plan to complete the enforcer synchronization and end-to-end verification, test live event delivery, and adapt the deployment to the latest eCash test-network stage.

-------------------------

b10c | 2026-08-24 11:45:17 UTC | #22

Cool! Did you manage to use it this weekend during the alpha hard-fork?

-------------------------

b10c | 2026-08-24 21:47:59 UTC | #23

posted the following to [IRC](https://bitcoin-irc.chaincode.com/bitcoin-core-dev/2026-08-24):
> I've been seeing a higher stale block rate over the past two weeks since 961632. 6 stale blocks where I would have expected about 2. Wondering if this is variance or if propagation is hindered a bit by BIP-110 nodes

-------------------------

ajtowns | 2026-08-25 12:36:24 UTC | #24

I don't see how bip110 nodes would have any impact? They should disconnect fairly fast, shouldn't attempt to announce new blocks to interfere with queue slots, and shouldn't be triggering much resource usage?

If there's a real higher stale rate, main cause should be that it takes longer for new work to get to mining devices; if there had been significant uptake of datum or stratumv2 job negotiation, I could see that having an effect, but I don't think that's plausible.

Oh, I think I have seen a bunch of tx spikes recently; so if any have been particularly severe, lack of [PR#34628](https://github.com/bitcoin/bitcoin/pull/34628) could trigger it if pools' nodes are overloaded enough to see delays in receiving blocks or generating updated templates. I have no idea if the spikes were severe enough to cause this, or if any were correlated with the observed stale blocks.

-------------------------

b10c | 2026-10-01 18:27:13 UTC | #25

Oh, you're right. I should have checked the BIP-110 node I run. For some reason I assumed the connections it has to Bitcoin Core nodes are longer-lived. It currently has only BIP-110 and spy-node connections, so it's unlikely to hinder propagation in this case.

-------------------------

GuiSchet | 2026-08-26 19:09:57 UTC | #26

Yeah, I’m a bit behind on it. I only updated the monitor to Alphanet this week, so I wasn’t able to properly use it during the alpha hard-fork weekend.

-------------------------

GuiSchet | 2026-09-16 22:11:06 UTC | #27

I’ve uploaded a first snapshot from my eCash Alphanet BIP300301 enforcer monitor:

https://drive.google.com/drive/folders/1DOkpoXGuoNpnGr9M1sfrzqA-mFp4DfMP?usp=sharing

It contains BIP300/301 events and block-level data from height 963,648 through 997,202.
I plan to keep tracking protocol changes from now through the October 30 mainnet launch.

I’m also working on a web app to explore and visualize the data. Feedback and ideas for useful visualizations or additional data are very welcome!

-------------------------

