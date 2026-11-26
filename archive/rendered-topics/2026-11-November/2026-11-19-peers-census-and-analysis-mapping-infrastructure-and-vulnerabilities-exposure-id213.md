# Peers Census and Analysis: Mapping, Infrastructure, and Vulnerabilities Exposure

ismaelsadeeq | 2026-11-19 15:25:38 UTC | #1

### Introduction

This post is a result of curiosity about the bitcoin p2p network. In the bitcoin p2p network addresses are gossiped to peers and there are various projects that aggregate this data and can use it for either good or harm.

This post spans a series of topics, basically during my detour to learn about the p2p network, and with the help of LLMs it has become easy to analyze this data for me even with little knowledge.

I analyzed what the network looks like to a naive observer, all based on public information.
Is it possible to use that data, for example, to find for e.g nodes in resource-constrained.

I analyzed the metadata available for free from nodes and then how an adversary can use
this metadata, then lastly I looked at the clients and their potential weak points based on disclosed vulnerabilities.

The methodology is simple: I used a single node with a single IP, I run the node for a while to gather ~47k addresses in its addrman, crawl the list of addresses from https://bitcoin-data.github.io/#p2p-network, and some lists of peers were provided to me by http://dsn.kastel.kit.edu/bitcoin/index.html.
Then attempt to be an inbound to them and run this research.
This is limited to nodes that receive inbound, nodes that don't are out of scope of this research. I think there is a potential way to catch them, which is to aggressively broadcast my address and hope for them to request an outbound to me.

#### Census of Addresses

![reachable_by_network|690x156](upload://5DFeEvge2934k7kRpqdCNpE982Z.svg)

The clearnet side came from 73,345 unique addresses aggregated from five sources (addrman, KIT, achownodes, fishfoo, Bitnodes), of which 11.6% answered; the rest were stale. Onion (11,586 addresses via 4 Tor SOCKS5 instances) and I2P (5,967 addresses via i2pd) were probed separately (CJDNS net addresses is not included here, its pretty much dead and not interesting data point see https://github.com/bitcoin/bitcoin/issues/36041). A node counts as reachable here only if it completed a version handshake with me, so these are nodes I actually connected to, not just addresses I had.

Note also I reach what I target, so it may or may not be the network's true composition. Because It is interesting to see that for example bitnodes samples differently and sees far less IPv6 than other samplers for some reason.

![implementation|690x235](upload://iztvV5Ze2asmvvJQfxYJBiKmeyR.svg)

Bitcoin Core is almost the whole network, btcd is the second largest alternative (Older knots  clients are still Bitcoin Core with Knobs). The client is read straight from the user agent string each node sends in its version message.

![network_type|690x216](upload://uOt4iJKPwwbWwH1bhsKeQ6y4vIN.svg)


By AS type, most reachable nodes sit in hosting, not on residential lines. The type comes from mapping each node's AS, via Core's embedded asmap, onto PeeringDB's network category.

![onion_vs_clearnet|690x236](upload://1gSMmbUGOyCpT3qCiTAbMVLQy9i.svg)


Probing shows that onion addresses are barely pruned (7% vs 23% clearnet), almost never below v25 (0.4% vs 5%). Onion addresses also have higher `P2P_V2` adoption (95% vs 80%), and Knots has slightly more onion addresses. These onion numbers come from probing the onion addresses directly over Tor, not from a crawler.

![census_pruned_by_net|690x156](upload://q0eIZiw9mBWxR9rrKViFZCaXvAU.svg)


![census_vuln_by_net|690x156](upload://jpDcMhztFOr9kJoJMc9WDhZpmj8.svg)

Across networks, pruned and vulnerable node shares split the same way: IPv6 is the most pruned and a bit more vulnerable, onion and I2P the least.

### Demography of Addresses

This is limited to clearnet nodes, onion and I2P addresses are not geolocatable and their latency is not comparable to clearnet. Country here comes from a GeoIP lookup on each reachable address.

The network lives in a handful of countries. The US (3,433) and Germany (1,614) alone are 59% of the reachable clearnet nodes.

![continent_distribution|690x216](upload://fu7wOZIUxZDficmyRkwJKxWPLK5.svg)

95 countries host at least one node, but after the top two the tail falls off fast: France (686), Canada (227) and the UK (224) are the next three. Here it is broken down per continent.


![country_europe|690x302](upload://bOdM9MZFkhV0vFA4ZkdjgS3awg2.svg)


![country_n_america|690x286](upload://eE83Imdz2K0OSnDL22biPjAMVG0.svg)


![country_asia|690x218](upload://vrGOIAbQYMMz2RM02SRnRnPQemr.svg)

![country_s_america|690x201](upload://oNM3U4jHIsHKyB1aiViGqunub19.svg)

![country_oceania|690x100](upload://9G6DDyq4Ui6PhSG4gIwNlkT3LXR.svg)

![country_africa|690x117](upload://8Pn5qmgocWXm6Vc80vfE8yimVO6.svg)


Africa is almost absent: 13 nodes in total, split across South Africa (10), Seychelles (2) and Angola (1).

Of the 8,535 reachable nodes, geolocation places 8,531, and 4 are real IPs that no source could resolve to a country.

### Who hosts the network

I also recorded each node's autonomous system (AS) using Core's embedded asmap. 

asmap collapses each AS to a single network group, so a big cloud or ISP that spans many address ranges counts as one group.

![asmap_collapse|690x236](upload://ydhhluUYOfIidJDY8kjYa5MEXg5.svg)

Serving capacity is more concentrated than node count. Weighting each node by its measured block-serving throughput (I timed a real block download from each node), the single largest AS holds about 10% of reachable nodes but serves roughly 31% of the observed block bandwidth, and the top ten ASes hold about 39% of nodes. 

![as_concentration|690x345](upload://4B4Kco09kXOPmLwYT0o7GY34KJp.svg)

Hosting networks serve blocks about 3.2x faster than residential.

![throughput_cdf|690x345](upload://aoun2duQMa9UNJP0nvtP63cDoCM.svg)

### Vulnerable clients

I wanted to know if hiding the user agent helps a node. So I mapped each node's real version to the behavioural group I can observe by probing, using the set of protocol features it supports. The 82 distinct full versions collapse into 8 bands. With the features my probe checks, only 5 nodes were uniquely version-identifiable from behaviour, and the largest band (v26 and up) groups 38 versions into one.

![version_bands|690x236](upload://cVF7AGVu3C2J03MPSvI3EZOZtAA.svg)

Hiding the user agent cuts both ways. For the old high-severity remote crashes the exposed nodes are behaviourally ancient, so I can flag them without the user agent at all: a node without `wtxidrelay`/`sendaddrv2` is pre-0.21, without segwit it is older still. But for the recent advisories the exposed nodes sit inside the v26+ band, which my probe cannot split and also can't know whether its a old version with a backported fix, so there the user agent is the only thing that reveals the exact info for targetting. Removing it would hide that.

Then I mapped versions to published advisories. Since I can see each node's full version, I compared it to the advisory's exact fix line and its backport releases, so these are the observed exposed set. Nodes already patched by a backport are excluded, which is why the v30 advisories backported to 28.3/29.1/29.2 sit near 40% instead of counting every node below v30.

![cve_exposure|690x307](upload://rfd3EkCMoOqAHzKMwh2rIWZOpag.svg)

The "Flaggable w/o UA" column is whether behavioural probing alone, ignoring the self-reported user agent, can tell a node is in the vulnerable range. It is "yes" when the exposed nodes fall below a behavioural boundary (pre-0.21 lacks `wtxidrelay`/`sendaddrv2`, older nodes lack segwit), "no" when the fix sits inside the v26+ band that probing cannot split so you would need the user agent, and "partial" for CVE-2024-35202, whose v25.0 fix falls inside the v0.21-25 band, so probing flags the band but cannot separate the exposed v21-24 nodes from the patched v25. The "no" rows are where removing the user agent would actually conceal the exposure.

| CVE | Type | Fixed in | Backport / caveat | Trigger | Exposed | Flaggable w/o UA |
|---|---|---|---|---|---|---|
| CVE-2018-17144 | inflation / assert DoS (Critical) | 0.16.3 | — | block | 0.3% | yes |
| CVE-2024-52912 | timestamp-overflow net-split (Med) | 0.21.0 | — | p2p msg | 1.8% | yes |
| CVE-2024-35202 | blocktxn assert crash (High) | 25.0 | — | p2p msg | 5.1% | partial |
| CVE-2024-52911 | script interpreter crash (Critical) | 29.0 | — | crafted block | 37.4% | no |
| CVE-2024-52919 | addrman 32-bit id overflow (Low) | 29.0 | rate-limited from 22 | p2p msg | 2.5% | no |
| CVE-2025-46598 | CPU DoS via unconfirmed txs (Med) | 30.0 | — | p2p msg | 53.4% | no |
| CVE-2025-54604 | disk fill via spoofed self-conn (Med) | 30.0 | bp 29.1 | p2p msg | 39.7% | no |
| CVE-2025-54605 | disk fill via invalid blocks (Med) | 30.0 | bp 29.1 | block | 39.7% | no |
| CVE-2025-62861 | TRUC eviction corrupts mempool (Med) | 30.0 | bp 28.3 / 29.2 | reorg | 40.3% | no |
| CVE-2025-62860 | Tor whitelist bypass (High) | 30.0 | bp 28.3 / 29.2 | p2p msg | 40.3% | no |
| CVE-2025-62859 | compact block witness stall (Med) | 30.0 | bp 29.2 | p2p msg | 40.6% | no |
| CVE-2026-117349 | OOM via paused peer queues (Med) | 32.1 | bp 29.5 / 30.4 / 31.2 | p2p msg | 81.9% | no |
| CVE-2026-117350 | OOM via TCP urgent data (Med) | 32.1 | bp 29.5 / 30.4 / 31.2, non-Linux | p2p msg | 6.4% | no |
| CVE-2026-117346 | undo file overflow crash (Low) | 32.1 | bp 29.5 / 30.4 / 31.2 | miner reorg | 81.9% | no |

Exposure is not the same as exploitability, which is why I added the trigger column.

So does hiding the user agent help? It depends on the node's era. The dangerous cheap crashes are old: the blocktxn crash (below v25) and the addrman overflow (below v22, 2.5% after rate-limiting). Those nodes are old enough that probing spots them anyway, user agent or not. The one cheap High bug that reaches modern nodes, the Tor whitelist bypass, sits inside the v26+ band where probing goes blind. There the user agent is the only tell, so hiding it would help the node.



![vuln_profile|690x196](upload://ht1YyJrHbmGSRwB0na7QsoQeR7H.svg)

The 430 nodes below v25 are, if anything, better resourced than average: 28 Mbps median, less residential, more often pruned.

![vuln_by_version|690x355](upload://4NLlh8720NpDgR8sqCE5MhosA1y.svg)

### Targeting Resource Constrained Nodes

I assume resource-constrained are the nodes that are cheap to overwhelm. I scored two separate axes, a bandwidth axis and a disk axis (the pruned flag).
Datacenter nodes answer in 83 ms and serve 35 Mbps, residential nodes 265 ms and 11 Mbps.

Bandwidth was measured by downloading a block from the node and timing the throughput to get the transfer in Mbps. Latency was tracked by recording the TCP round-trip speed recorded when the connection opens in ms.

Datacenter nodes answer in 83 ms and serve 35 Mbps; home nodes answer in 265 ms and serve 11 Mbps.

![latency_by_asclass|690x266](upload://umZY9yjUr0od9Vaxd8mnI8d6GqZ.svg)


In this data pruned nodes are faster (170 ms vs 207 ms overall), maybe because people prune to save disk on cheap well-connected VPS hosts, not on constrained home machines. Pruning is a disk constraint, orthogonal to bandwidth.


![axis_split|690x156](upload://laSESR99TEtiBfQqUKnbKZtIOSI.svg)


![targeting_bw_gradient|690x176](upload://fDu6LBt230rZeyPyK9cKt5mx6fV.svg)



Thanks to @b10c, Mathias from KIT, @davidgumberg and a few others for answering my questions.

Mistakes here are entirely my own, artifact is available publicly https://github.com/ismaelsadeeq/peers-probe/tree/census-post.

-------------------------

edilmedeiros | 2026-11-19 16:59:22 UTC | #2

[quote="ismaelsadeeq, post:1, topic:213"]
I think there is a potential way to catch them, which is to aggressively broadcast my address and hope for them to request an outbound to me.

[/quote]

I would guess this is extremely limited, even if super aggressive address announcing because most unreachable nodes (those that won't accept inbound connections) are probably keeping the default 8 outbound limit. There's some investigation on them, like \[1\], but unreachable peers are pretty much something we don't understand that well (pretty obvious given they are not reachable by an active researcher trying to talk to them).

[quote="ismaelsadeeq, post:1, topic:213"]
The clearnet side came from 73,345 unique addresses aggregated from five sources (addrman, KIT, achownodes, fishfoo, Bitnodes)

[/quote]

@dutenrapha recently ran a crawler he's developing and found around 200k ipv4 addresses to try, but the actual reachable ones are similar to your numbers. I'll let him explain better the methodology, but feels to me that even understanding how effective is the address relay mechanism (I guess it's extremely good for an address to reach various parts of the network), but I'm still trying to see what the literature found in the past.

[quote="ismaelsadeeq, post:1, topic:213"]
Onion addresses also have higher `P2P_V2` adoption (95% vs 80%)

[/quote]

I'll just drop \[2\] here to remember myself to get back to this argument.

\[1\] [Franzoni, F., & Daza, V. (2020). Improving Bitcoin Transaction Propagation by Leveraging Unreachable Nodes. *2020 IEEE International Conference on Blockchain (Blockchain)*, 196–203. https://doi.org/10.1109/Blockchain50366.2020.00031](https://doi.org/10.1109/Blockchain50366.2020.00031)

\[2\] [Bitcoin over Tor isn't a good idea; Alex Biryukov, Ivan Pustogarov](https://ieeexplore.ieee.org/document/11172744)

-------------------------

edilmedeiros | 2026-11-19 18:59:24 UTC | #3

[quote="ismaelsadeeq, post:1, topic:213"]
behavioural group I can observe by probing
[/quote]

The fingerprinting methodology is described somewhere?

-------------------------

b10c | 2026-11-19 20:53:54 UTC | #4

[quote="ismaelsadeeq, post:1, topic:213"]
![reachable_by_network|690x156](upload://5DFeEvge2934k7kRpqdCNpE982Z.svg)

[/quote]

I think your timeouts for Onion and I2P might be off. I have about 11.5k reachable Tor nodes and 5.6k reachable I2P nodes in my data from earlier this week. In https://hacknodes.com/en/blog/bitcoin-node-count-infrastructure-en/ @ifuensan made the observation that measuring Tor nodes is really dependent on how well your crawler is setup. 

My numbers for IPv4 and IPv6 roughly match yours.

[quote="ismaelsadeeq, post:1, topic:213"]
![network_type|690x216](upload://uOt4iJKPwwbWwH1bhsKeQ6y4vIN.svg)
[/quote]

This roughly matches what I observed in:

[quote="b10c, post:7, topic:122"]
In total, there a more reachable nodes in ASNs classified as “residential” than “hosting”:

![Total node count across 'hosting' and 'residential' ASNs (Bitnodes data)|690x355](upload://cifuzGEOLqS51iY9fyyR9KwG39B.png)
[/quote]

[quote="ismaelsadeeq, post:1, topic:213"]
Probing shows that onion addresses are barely pruned (7% vs 23% clearnet), almost never below v25 (0.4% vs 5%).
[/quote]

I think onion nodes are often hosted on node-in-a-box setups which come with a 1TB or 2TB drive to store the chain. So this makes sense to me.

[quote="ismaelsadeeq, post:1, topic:213"]
### Who hosts the network

I also recorded each node’s autonomous system (AS) using Core’s embedded asmap.

asmap collapses each AS to a single network group, so a big cloud or ISP that spans many address ranges counts as one group.

![asmap_collapse|690x236](upload://ydhhluUYOfIidJDY8kjYa5MEXg5.svg)
[/quote]

I think this is looking at **unrechable IPs** in your addrman. Many nodes on e.g. AS3320 Deutsche Telekom are IPv4 home nodes that  announce their IP, then after 24h rotate their IP, and announce a new one (I've been working on a writeup of this). I think you should be explicit about this in your post.

[quote="ismaelsadeeq, post:1, topic:213"]
### Targeting Resource Constrained Nodes

I assume resource-constrained are the nodes that are cheap to overwhelm. I scored two separate axes, a bandwidth axis and a disk axis (the pruned flag).
Datacenter nodes answer in 83 ms and serve 35 Mbps, residential nodes 265 ms and 11 Mbps.

Bandwidth was measured by downloading a block from the node and timing the throughput to get the transfer in Mbps. Latency was tracked by recording the TCP round-trip speed recorded when the connection opens in ms.

Datacenter nodes answer in 83 ms and serve 35 Mbps; home nodes answer in 265 ms and serve 11 Mbps.
[/quote]

I'm not sure if that's a very scientific way of measuring it. Bandwidth and especially latency depends a lot of your location and connection to the counter party. Maybe you measured from the EU where many Datacenter nodes are hosted in Hetzner, which is physically closer to the host and thus has lower latency and higher bandwidth, and many Residential nodes are in US homes (which is physically further away from you). For example, [Amsterdam <-> NewYork](https://wondernetwork.com/pings/New%20York/Amsterdam) ping times seem to be 76ms and you are limited at the speed of light in fiber (+routing etc) there.

-------------------------

b10c | 2026-11-19 20:59:04 UTC | #5

[quote="edilmedeiros, post:2, topic:213"]
@dutenrapha recently ran a crawler he’s developing and found around 200k ipv4 addresses to try, but the actual reachable ones are similar to your numbers. I’ll let him explain better the methodology, but feels to me that even understanding how effective is the address relay mechanism (I guess it’s extremely good for an address to reach various parts of the network), but I’m still trying to see what the literature found in the past.
[/quote]

Note that there's been a bit of spam. See https://bnoc.xyz/t/address-relay-under-stress/163#p-581-the-spam-1 and similar.

-------------------------

ismaelsadeeq | 2026-11-23 16:37:15 UTC | #6

[quote="edilmedeiros, post:2, topic:213"]
I would guess this is extremely limited, even if super aggressive address announcing because most unreachable nodes (those that won’t accept inbound connections) are probably keeping the default 8 outbound limit. There’s some investigation on them, like \[1\], but unreachable peers are pretty much something we don’t understand that well (pretty obvious given they are not reachable by an active researcher trying to talk to them).
[/quote]

yeah it's limited if you're just spamming single address from one place, addrman caps how much a single source can fill.

But I think it's doable but that's more infra than I'm using and out of scope for this census, so I can't say much here @b10c? could chime in here, but I am afraid its sensitive info as I can potentially use it at scale to eclipse?

-------------------------

ismaelsadeeq | 2026-11-23 16:39:08 UTC | #7

[quote="b10c, post:4, topic:213"]
I think your timeouts for Onion and I2P might be off. I have about 11.5k reachable Tor nodes and 5.6k reachable I2P nodes in my data from earlier this week. In https://hacknodes.com/en/blog/bitcoin-node-count-infrastructure-en/ @ifuensan made the observation that measuring Tor nodes is really dependent on how well your crawler is setup.
[/quote]

my crawler gave the whole handshake an 8 s budget including the Tor circuit build which was cutting off reachable onions mid-connect. I run a quick re-crawling the timed-out addresses with a longer connect timeout, a random sample recovered ~87% as genuine.

I will run it again on full sample and report.

-------------------------

ismaelsadeeq | 2026-11-23 17:04:48 UTC | #8

[quote="b10c, post:4, topic:213"]
I think this is looking at **unrechable IPs** in your addrman. Many nodes on e.g. AS3320 Deutsche Telekom are IPv4 home nodes that announce their IP, then after 24h rotate their IP, and announce a new one (I’ve been working on a writeup of this). I think you should be explicit about this in your post.
[/quote]

Thanks, yeah, this is misleading this is the new plot with reachable peers only.
![asmap_collapse|690x236](upload://c19DUizFgZZGbvw50GS8sirZ0mz.png)

-------------------------

ismaelsadeeq | 2026-11-24 12:07:13 UTC | #9

[quote="edilmedeiros, post:3, topic:213"]
The fingerprinting methodology is described somewhere?
[/quote]

I think its naive, so just used it here, but may be documented I did not check.

[quote="b10c, post:4, topic:213"]
I’m not sure if that’s a very scientific way of measuring it.
[/quote]
:sad_but_relieved_face: 

[quote="b10c, post:4, topic:213"]
Bandwidth and especially latency depends a lot of your location and connection to the counter party. Maybe you measured from the EU where many Datacenter nodes are hosted in Hetzner, which is physically closer to the host and thus has lower latency and higher bandwidth, and many Residential nodes are in US homes (which is physically further away from you). For example, [Amsterdam ↔ NewYork](https://wondernetwork.com/pings/New%20York/Amsterdam) ping times seem to be 76ms and you are limited at the speed of light in fiber (+routing etc) there.
[/quote]

Yeah, It's measured from a single vantage, I was wrong here. But the hypothesis can be tested accurately but only for the sample size at my location. So just doing it network wide was the mistake here.

-------------------------

ismaelsadeeq | 2026-11-24 12:10:18 UTC | #10

[quote="ismaelsadeeq, post:7, topic:213"]
I will run it again on full sample and report.
[/quote]
With the improved crawler
![reachable_by_network|690x156](upload://wSYNwNsbhN1oP5BG5J2CiPJXSLb.png)

- Tor: previously 2,266, now 10,024 reachable (7,758 of 9,220 timeouts recovered, 84%)
- I2P: previously 2,588, now 5,210 reachable (2,622 of 3,293 recovered, 80%)

-------------------------

dutenrapha | 2026-11-25 16:19:23 UTC | #11

 Thanks for the mention, @edilmedeiros. Here's how that number came about.

  The crawler follows the procedure in Donet Donet et al. (2014). It's a breadth-first
  search over getaddr. It starts from 600 public IPv4 seeds resolved from the Bitcoin Core
  v29.0 DNS seeds and frozen to a file, so every round starts from the same seeds. Each
  worker opens TCP, completes version/verack, sends getaddr, and puts every new public
  IPv4:8333 address back in the queue. A round only counts if it ends with the queue empty.
  The time and query caps are safety limits.

  The round Edil mentioned ran on 2026-10-28 from Brazil (AWS sa-east-1, one vantage point,
  256 workers, 20 s timeout). It emptied the queue after 229,979 queries in under 6 hours.
  Of [A] announced IPv4 addresses, [N] completed the handshake. That's in the same range as
  your clearnet numbers. Our scope is narrower than yours, though: IPv4 on port 8333 only,
  with no IPv6, Tor or I2P. In a short test round, about 18% of IPv4 announcements used a
  port other than 8333. We store those but never query them.

  A few caveats on that round:

  • It marked a handshake as complete when the peer's version arrived, so it slightly
    overcounts reachable nodes. Rounds now require verack and record the TCP, version and
    verack stages separately.
  • The seed list was unbalanced: 349 of the 600 seeds came from one seeder. It's balanced
    across the nine domains now. Since rounds run until the queue is empty, the seeds
    should mostly change the order of the queries, not which nodes get queried. We still
    plan to check that by comparing rounds from both seed lists.

  On the ~10:1 gap between announced and reachable: getaddr returns a sample of the peer's
  addrman, not its connections, so the gap measures how much stale or unreachable data
  circulates. It doesn't say much about how effective relay is. @b10c's two points probably
  explain a lot of it: home nodes that rotate their IP every 24h, and the address spam he
  linked. We log every "A announced B" event, so a next step is to split the unreachable
  addresses by how many distinct peers announced them. If most are announced by only a few
  peers, that points to spam. If many peers announce them, that points to rotation or stale
  entries. I'll post the result here.

  Code: https://github.com/dutenrapha/bitcoin-topology-discovery

-------------------------

