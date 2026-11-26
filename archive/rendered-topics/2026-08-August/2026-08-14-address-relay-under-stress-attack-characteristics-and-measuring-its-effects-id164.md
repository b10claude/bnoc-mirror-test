# Address Relay under stress: Attack Characteristics and Measuring Its Effects

stratospher | 2026-08-14 17:33:25 UTC | #1

This is joint work with @mzumsande. It's a companion piece to [this post](https://bnoc.xyz/t/address-relay-under-stress/163), digging into the data from the address spam attack. Below is a summary of our analysis.

The address spam propagated through normal address gossip. You can see it in [KIT's "unique addresses per day" graph](https://bnoc.xyz/t/python-bitcoinlib-0-12-2-client-getting-addr-ratelimited-since-2026-04-10/116/7), which drops sharply in mid-July the moment the spammer stops. Sustaining that much volume takes active, continuous injection of addresses into the P2P network. In order for a node to [relay](https://github.com/bitcoin/bitcoin/blob/128456b62d5e38abea031f97f823d5b28aef9357/src/net_processing.cpp#L6021) an address onward: the ADDR message must carry 10 addresses or fewer, and the address timestamp must be less than 10 minutes old. This makes the spammer hard to identify (unless it connects directly to your node). It only has to reach a handful of peers; those peers relay to their peers, and the flood spreads across the network on its own.

* We can watch that spread indirectly through the rising number of peers getting rate-limited. See discussion in [this post](https://bnoc.xyz/t/python-bitcoinlib-0-12-2-client-getting-addr-ratelimited-since-2026-04-10/116/6?u=stratospher).
* We see the average number of addresses per ADDR message climb over the same window.
![addr_avg_all|690x276](upload://hbqR4dzEzs3VZh3JFyTi8xrxDT4.png)

* We also received far more multi-address ADDR messages per day during the spam period.
![size_hist_1_10|690x313](upload://cqp86fiGpaxahr80aaQ3lDADtBo.png)


Once the attack stopped, the spam addresses became identifiable easier, because the spammer was no longer refreshing their timestamps. A fabricated address has no real node behind it to re-announce itself - only the spammer's continuous gossip kept its timestamp current. When that stopped, the timestamps froze in place.

To measure this, we took 15 addrman snapshots from June 28 to August 12 across the 14 nodes (peer.observer) and, for every address, found the last snapshot in which its timestamp still advanced. Binning those "freeze times" by hour and applying some more strict checks (like counting an address only if it appears in at least 2 snapshots etc..) produced the following histogram.

The freeze shows up as a sharp cliff. Across the addrman of 14 nodes, the rate at which addresses' timestamps stopped advancing collapsed ~60× in a single hour - from ~3,900/hour to ~65/hour at ~Jul-14 12:00 UTC.

![freeze_dip|690x282](upload://xaiMXB3t8H2auAwBB1Xn7fBa7qJ.png)

## Addr spam effects

Now coming to the effects of the addr spam.

During the attack, the number of new addresses added to addrman per day dropped sharply. Alice held near its ~1,100–1,800/day baseline through late April, then fell to about ~200/day by early-to-mid May and stayed there for the rest of the spam window before creeping back toward ~400–500/day once the attack stopped. The graph misses data between April 15 and May 1, which would show us how many addresses were actually being inserted into addrman when the spam just started.

The drop is probably because the new table had already been filled with spam, so an incoming address usually hashed to a slot already held by a spam IP address entry the node couldn't evict.

![proc_added|690x258](upload://e4uTwF0C0gR0qEU8MVdt0SXPzK8.png)

We had to wait about ~1 week after the spam stopped for the self-announcement of a newly started node to be accepted into the 14 addrmans we were watching on peer.observer - partly because the congested gossip meant a legitimate address relayed alongside spam could get rate-limited before a peer processed it, but mostly because peers' new tables were full of fresh spam that addrman won't evict until 30 days after the attack ends. Either way, legitimate addresses had a low chance of being accepted.

If we compare the outbound connection attempts (full relay and block relay but not feeler) and whether the outbound peer was chosen from the new table or tried table.

We see that the % of successful connection in the new table:

* before addr spam: ~1.4–3.7%
* during addr spam: ~0.6–1.9%

We see that the % of successful connection in the tried table:

* before addr spam: ~40–76%
* during addr spam: ~38–49%

![new_tried_outbound_success|690x345](upload://erCYxeE2NvgVLmDiYNkk0jjl5w.png)

On a clearnet-only node, the New table's success rate at producing a usable peer only dips slightly during the spam in absolute terms but it was already low to begin with. The New table was probably full of unreachable addresses before the attack even started.

Feelers tell the story more clearly. A feeler dials a New-table entry to test whether it's actually reachable, so feeler success is an indicator about the New-table quality. Feeler success was already sliding before the spam (12.6% in January down to ~8% by April - maybe because bitprojects left), then fell further through the spam window:

- before the spam: ~7.7–12.6%
- during the spam: ~2.8–8.5%

![feeler_success|690x345](upload://zBvdlmQAPqrBRPKMkIBAsEjsD2H.png)

A healthy addrman needs ways for good addresses to stay and ways for bad ones to be evicted. Eviction is governed by `IsTerrible`, which marks an entry as removable mostly based on `nTime` (when the address was last seen), `nAttempts` (how many times we've tried to connect and failed) and `m_last_success` (when we last connected successfully).

* `nAttempts` : it doesn’t change that much. There’s a sharp drop from `nAttempts = 2` to `nAttempts = 3` and that’s because of `isTerrible` rules.

![nAttempts|414x148](upload://f77DWjzgehTtcQLoZg9MGprivik.jpeg)

* `nTime`: at the spam peak, almost every new-table entry is fresh and was last seen within the past 7 days. That constant refreshing is consistent with the spammer actively re-circulating the same addresses.
* `m_last_success`: only ~1.7k are IP addresses we ever successfully connected to and that number didn’t change much.

|July 13 (at peak addr spam just before it stopped)|Aug 3 (2 weeks after addr spam stopped)|
| --- | --- |
| ![new_table_dist_peers-20260713-alice|450x500](upload://3Z4r84OW1KG691FwuSMfk4smsmY.png) | ![new_table_dist_peers-20260803-alice|450x500](upload://hr5yRGuF1mOvUJXBzQDMb6bf5Fw.png) |

## Acknowledgements

Special thanks to @b10c for maintaining peer.observer so well - the long-running, accessible data is what made this analysis possible! And thanks to @naiyoma for reviewing this post.

-------------------------

b10c | 2026-08-15 09:57:59 UTC | #2

I wonder if it's possible to identify the origin of this spam through the data we have. Have you thought about this or looked into it?

The [connectivity-check](https://bnoc.xyz/t/unreachable-addresses-in-bitcoin-getaddr-responses/155/3?u=b10c) data might show which source IPs often sent addresses with the newest timestamp?

-------------------------

b10c | 2026-08-15 10:01:09 UTC | #3

There's also the idea of having an addr-relay recording mode for the archiver: https://github.com/peer-observer/peer-observer/issues/439#issuecomment-5268281438

This should allow us to record and analyze these in much more detail going forward. Good to be learning about data blind-spots - this allows us to improve our data collection.

-------------------------

jorisstrakeljahn | 2026-08-15 12:25:23 UTC | #4

Great analysis! 
You also mentioned that addrman will not evict the spam until 30 days after the attack ends. Since your data stops on 12 August, I checked the public demo.peer.observer addrmans (hal / len) and posted an update in [#155](https://bnoc.xyz/t/unreachable-addresses-in-bitcoin-getaddr-responses/155). You can see the turnover spike there. If you have later snapshots, you could check whether "new addresses added per day" jumps the same way. I'd expect this to settle back toward the old range over the next few days.

-------------------------

stratospher | 2026-08-31 20:47:16 UTC | #5

> I wonder if it’s possible to identify the origin of this spam through the data we have. Have you thought about this or looked into it?

I think it's possible to identify the spammer only if they connected to your node. the pattern which gives them away would be lots of exactly 1 address per ADDR message at an inflated rate.

the rest of the network which relays the addresses from the spammer would end up relaying x addresses per ADDR message (x can be 1-10 and would be variable based on the receiving token buckets the normal nodes in the network have). we can see this effect in [this graph](https://bnoc.xyz/uploads/default/original/1X/5716367ac99237decf64eb556771b1bf22b9056a.png) which shows a sharp increase in all possible number of addresses per ADDR messages.

-------------------------

Crypt-iQ | 2026-09-01 14:16:31 UTC | #6

Nice graphs!

[quote="stratospher, post:1, topic:164"]
We see that the % of successful connection in the tried table:

* before addr spam: \~40–76%
* during addr spam: \~38–49%

[/quote]

Any idea why the % goes down in the tried table? I would expect this for the new table, but not the tried...

-------------------------

stratospher | 2026-09-01 14:38:04 UTC | #7

I think it's because of this timeline of events:

1. The bitprojects eclipser was running, providing decent listening capacity in the network.
2. The eclipser switched off at the end of March, and the network [lost a lot of listening capacity](https://bnoc.xyz/t/many-connections-to-bitproject-io-nodes/40/29?u=stratospher).
3. The addr spam attack started in mid-April.

So my guess is that the tried table percentage dropped because the eclipser turned off its node, not because of the addr spam itself.

Side note: I think it's reasonable to expect the tried table to be only \~50% reachable, since the unreachable addresses in the tried table were nodes with much older timestamps.

-------------------------

naiyoma | 2026-09-02 13:05:03 UTC | #8

[quote="stratospher, post:1, topic:164"]
Once the attack stopped, the spam addresses became identifiable easier, because the spammer was no longer refreshing their timestamps.

[/quote]

After spam, I observed a sharp increase in the number of terrible addresses, followed by a sharp decrease. I think most addresses that made it into addrman during that period have since been evicted.

![terrible_rate|690x425](upload://vWNwvIP2l634ofbjsautwEZ1GNF.png)

-------------------------

stratospher | 2026-09-30 22:05:22 UTC | #9

here's a comparison of these trends in the past 2.5 years (Feb 2024 - July 2026). h/t to @b10c for the data! 

1. this is the number of addresses added to the addrman per day from the `AddrMan::Add` logs. timestamp refreshes are not counted here. you can ignore the spike which happened when Alice restarted.

![proc_added|690x221](upload://oxpKs1d8lRLRF8FtEOIDIfrk3gh.png)
 

It's interesting how it's kind of steady at 1500-2000 addresses/day for 2.5 years but then dropped to 200-400 addresses/day during the spam window.

It's because this graph is an indicator of the `isTerrible` trend. we can only add something into our addrman if the existing address is `isTerrible` and the major component is nTime > 30 days. the drop during the spam window means someone was purposefully refreshing timestamps so that the addresses in the new table do not get `isTerrible`.

2. just for comparison, this is the number of addresses Alice was receiving during this time period from the `ProcessAddrs` logs.

![proc_processed|690x221](upload://mNqBHc5KMBIZmIa2mpFeEbKxoFe.png)

- it's ~90k addresses received /day through 2024
- ~150-300k addresses received/day in 2025
- ~400-580k addresses received/day during the spam window

not all addresses which Alice receives enters her addrman. It's a very tiny fraction which enters the addrman - most addresses end up as `collision-no-eviction` and don't enter the addrman. 

3. this is the successful outbound connections which happened from new and tried table. 
![new_tried_outbound_success|690x271](upload://30cmmZojWPPSO4lwfDA1xCYX7sk.png)

- new table is only 1-2% success for outbound full relay + block relay (no feelers)
- tried table used to be 60-80% success for 2 years and then dropped to ~43% during the spam window

this means the clearnet new table has always been very unreachable even without spam attacks. I guess it's because we promote the reachable ones to tried table, clearnet IPs could be dynamic and rotate, node might still run default listen=1 even when it is not able to accept inbounds and end up self advertising anyways.

4. this shows successful feelers.

![feeler_success|690x271](upload://gxMLMfe5m9L9UivoFpLjjDsuANt.png)

- ~5% successful feelers in 2024
- climbing steadily to ~10-16% by early 2026
- falling to 2-4% during the spam window

 the downward trajectory during spam window shows addrman new table quality degrading. Alice attempts feelers to new table addresses but the new table addresses are fake/dead and the feelers become more unsuccessful.

-------------------------

ajtowns | 2026-10-02 05:22:26 UTC | #10

[quote="stratospher, post:9, topic:164"]
It’s because this graph is an indicator of the `isTerrible` trend. we can only add something into our addrman if the existing address is `isTerrible` and the major component is nTime > 30 days. the drop during the spam window means someone was purposefully refreshing timestamps so that the addresses in the new table do not get `isTerrible`.
[/quote]

Huh, is refreshing timestamps on the new table even sensible? Could perhaps make the logic be "if this addr is in the new table and has had any tries/failures, don't bump the ntime".

At 3 failed tries to evict an entry, and, say 50k fake entries in the new table, then picking a random entry to try every two minutes, means you expect it to take about 104 days to evict the average entry after first seeing it? Long term you might expect to cycle through as few as 240 entries per day (24h*60min/2min/3tries) if the 30 day timeout isn't biting; though that only rises to at most 720 entries per day (dropping the 3 tries) if you aim to try an address at least once before dropping it.

-------------------------

mzumsande | 2026-10-02 09:25:29 UTC | #11

[quote="ajtowns, post:10, topic:164"]
Could perhaps make the logic be “if this addr is in the new table and has had any tries/failures, don’t bump the ntime”.

[/quote]

The simpler option would be to just decrease the number of tries from 3 to 1, so that it becomes terrible immediately after a failed try. I don't see what a delay to making it terrible through expiry in this situation would achieve compared to that.

-------------------------

b10c | 2026-10-09 14:26:32 UTC | #12

[quote="ajtowns, post:10, topic:164"]
Huh, is refreshing timestamps on the new table even sensible? Could perhaps make the logic be “if this addr is in the new table and has had any tries/failures, don’t bump the ntime”.
[/quote]

Or even more strict: Set the timestamp of the entry to the time you added it to the `new` table and don't bother updating it. If this address is still relevant in 30 days, it will re-announce itself then. 

One step further could be to introduce `addrv3` that does not carry a timestamp at all, which is related to @danielabrozzoni's https://delvingbitcoin.org/t/fingerprinting-nodes-via-addr-requests/1786/13. However, this does not solve what timestamps we set in repose to  `addrv1`/`addrv2`  `getaddr` requests that we still need to support.



[quote="naiyoma, post:8, topic:164"]
After spam, I observed a sharp increase in the number of terrible addresses, followed by a sharp decrease. I think most addresses that made it into addrman during that period have since been evicted.

![terrible_rate|690x425](upload://vWNwvIP2l634ofbjsautwEZ1GNF.png)
[/quote]


It might also make sense to not have an expiry fixed to exactly 30 days going forward. An attacker willing to wait 30 days can set an exact timer to 30-days-after-addr-refresh-spam to make a bunch of addresses terrible. A deterministic isTerrible time per-address based on `address + addrman random key` on an exponential distribution with an average of 30 days might smooth things out a bit more...

-------------------------

b10c | 2026-11-13 03:59:10 UTC | #13

[quote="b10c, post:12, topic:164"]
One step further could be to introduce `addrv3` that does not carry a timestamp at all, which is related to @danielabrozzoni’s https://delvingbitcoin.org/t/fingerprinting-nodes-via-addr-requests/1786/13 . However, this does not solve what timestamps we set in repose to `addrv1`/`addrv2` `getaddr` requests that we still need to support.
[/quote]

As got pointed out: The timestamps in addr messages currently limit the spread of self-annoucements. Without it, we wouldn't stop relaying an self-annoucement early. We still stop relaying them once everybody has already forwarded them once.

-------------------------

