# Outbound connection success rates of a Bitcoin node

b10c | 2026-06-18 10:36:27 UTC | #1

To have data for a [simulation](https://github.com/bitcoin/bitcoin/issues/34019#issuecomment-4422039561), I've been looking at the rate of successful outbound connections my nodes are making. I'm parsing and using the following log messages for this:

- `trying TRANSPORT connection (CONN_TYPE) to ADDR`: tells us about a connection attempt - the connection type is only logged here since https://github.com/bitcoin/bitcoin/pull/34410/changes/67696b207f370e902c8d5fb765e4ff10f6c9e1b4 which was only merged on 2026-03-02, so I don't have too many logs with it yet.
- `New CONN_TYPE peer connected: transport: TRANSPORT, version: VERSION, peer=ID peeraddr=ADDR`: tells us about a successful `block-relay-only` or `outbound-full-relay` connection. This is also logged for `inbound` connections when net-logging is enabled, but we ignore this here.
- `feeler connection completed, disconnecting peer=ID, peeraddr=ADDR` tells us about a feeler connection finishing 

I'm only looking at these connection types for now:
- outbound-full-relay (normal outbounds)
- block-relay-only (outbound, but only relaying blocks)
- feeler (to check if an address is reachable)

I have data from multiple [peer.observer](https://public.peer.observer) nodes that run with different configurations.

I'll split this up into multiple posts so it's easier to link to a specific one or reply to a specific one.

-------------------------

b10c | 2026-10-01 14:21:54 UTC | #2

## Outbound connection attempts

Before looking at connection success rates, it makes sense to look at outbound connection attempts per time. All of the following plots show **attempts-per-hour** averaged over a day or a week.

![Outbound connection attempts per hour (per node)|690x374](upload://l9Kl9ybw239X6bhGidbDIEW4wwF.png)

Generally, my nodes all make \~57 outbound connections per hour. So close to one per minute. Node `jade` differs here, it makes \~43 per hour (likely because it can reach IPv6, see below). The number of outbound attempts per hour seems to be stable since the start of my data in 2024.

### By connection type

To drill down by connection type, we can look at the data captured while running with https://github.com/bitcoin/bitcoin/commit/67696b207f370e902c8d5fb765e4ff10f6c9e1b4 . This is limited to a shorter time frame and only three nodes for now:

![Outbound connection attempts per hour over time per connection type (outbound-full-relay, block-relay-only, feeler)|690x374](upload://36IQKQRs3Qodsv7kDZSjFa9Ou1B.png)

We can see that all three nodes make \~30 feeler connections per hour (one every two minutes). This exactly matches what we’d expect:

https://github.com/bitcoin/bitcoin/blob/341360964a6fef725825639edc507c275f8ad0b2/src/net.h#L60-L61

We also make roughly the same number of outbound-full-relay and block-relay-only connections at about 13 to 14 per hour. The timings for this aren’t as clear and well defined (see e.g. https://github.com/bitcoin/bitcoin/blob/341360964a6fef725825639edc507c275f8ad0b2/src/net.cpp#L2755-L2775 ) and I haven’t dug deeper into why we (happen to?) make these at the same rate.

### By network

We can also split these 57 connections per hour up by network we are connecting to. Note that the nodes can reach ( :white_check_mark: ) different networks. Some nodes might try to connect to e.g. IPv6, while they’ll never be able to make a connection ( :cross_mark: ).

| Node | IPv4 | IPv6 | Tor | I2P |
|----|----|----|----|----|
| alice | :white_check_mark: | :cross_mark: | \- | \- |
| bob | :white_check_mark: | :cross_mark: | \- | \- |
| charlie | :white_check_mark: | :cross_mark: | \- | \- |
| dave | :white_check_mark: | :cross_mark: | :white_check_mark: | :white_check_mark: |
| frank | :white_check_mark: | :cross_mark: | \- | \- |
| jade | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| ian | :white_check_mark: | :cross_mark: | \- | \- |

![Outbound connection attempts for network=IPv4 per hour|690x374](upload://rElprqMHwGWHDmGEV8UWMvx2V53.png)

For IPv4, alice, bob, charlie, frank, and ian make about 37 connection attempts per hour. Both dave and jade, who can reach more networks, make fewer connections (about 27) to IPv4 per hour.

![Outbound connection attempts for network=IPv6 per hour|690x374](upload://sMNBIqJNNyJ42SSuInefAdTUNs5.png)

For IPv6, alice, bob, charlie, frank, and ian make about 17 connection attempts per hour. The node dave, which can’t reach IPv6 (but can reach Tor and I2P), makes about 15 connections to IPv6. Since none of these nodes can reach IPv6, all these connections are going to fail. However, node jade can actually reach IPv6 and makes about 5 connection attempts per hour.

![Outbound connection attempts for network=Tor per hour|690x374](upload://s5LGGKe7ZR9kwoiH5MSm6qOHpGr.png)

Dave and jade make about 12.5 connections to Tor per hour. Both can reach Tor.

![image|690x374](upload://7QrdJnqQWWyVLROAKSWawbtWxU.png)

For I2P, which both dave and jade can reach, they make about 2 connections per hour.

To summarize, the nodes make the following number of connections per hour to:

|Node | IPv4 | IPv6 | Tor | I2P|
|--- | --- | --- | --- | ---|
|alice | 37 | 17 | \- | \-|
|bob | 37 | 17 | \- | \-|
|charlie | 37 | 17 | \- | \-|
|dave | 27 | 15 | 12.5 | 2|
|frank | 37 | 17 | \- | \-|
|jade | 27 | 5 | 12.5 | 2|
|ian | 37 | 17 | \- | \-|

This explains why jade is making fewer connections per hour (about 43 vs about 57): jade is the only one that can reach IPv6 nodes. Once it has IPv6 connections, it does not need to retry connecting to IPv6 too often.

Connection attempts are likely affected by outbound connection churn (how often the connection to our outbounds drop) and our address manager composition. These numbers might be different on nodes configured differently.

### By network and connection type

Looking at the number of attempts node alice makes by network and connection type shows that about 25 attempts per hour are IPv4 feeler while only 5 attempts are IPv6 feeler. About 12.5 attempts are IPv6 outbound-full-relay (which all fail), while it’s only 2-3 IPv4 outbound-full-relay attempts per hour (out of which some succeed). For block-relay-only connections, it’s the other way around: Alice only makes about 2 block-relay-only IPv6 connections per hour, while it makes 12.5 block-relay-only IPv4 connections per hour.

![image|690x374](upload://sIjytkhMBMy76AYOFUbgloxo4WQ.png)

-------------------------

b10c | 2026-10-01 14:25:57 UTC | #3

## Connection success rates

Knowing about the differences between the node configurations and the number of outbound connection attempts allows us to better understand the success rates of these attempts.

![Outbound connection success rate over time by node|690x369](upload://d8otRLtoG6KDj5aCmGKBUXe7kEZ.jpeg)

The nodes alice, bob, charlie, frank, and ian all have a similar success rate of 12% - 15%. Out of 57 attempts per hour, that’s about 8 new outbound connections (feeler included) per hour. Dave, which is also able to connect to Tor and I2P, has a higher success rate at 30% in median. Jade, which can also connect to IPv6, is closer to a median of 40% success. To better understand this, we can drill down by network and connection type.

### By network

All nodes can make connections via IPv4. Between 2025-01 and 2026-03-31, the nodes averaged at about a 20% (or slightly more) connection success rate. Since 2026-04, when bitprojects ( https://bnoc.xyz/t/many-connections-to-bitproject-io-nodes/40/24?u=b10c ) shut down their nodes, we’ve been seeing it dip below 20%. It’s closer to 15% now.

![Outbound connection success rate by network IPv4 over time by node|690x321](upload://arah9zF1hA0VY7KhojmXNwo7feX.png)

Only \`jade\` makes connections to IPv6. There, we have connection success rate just above 20%.

![Outbound connection success rate by network IPv6 over time by node|690x321](upload://gx3FUddRu2X7dq7DV4BIA7JU6Fw.png)

The rate for Tor on dave and jade dropped from just below 80% to about 65% since mid 2025 till mid 2026.

![Outbound connection success rate by network Tor over time by node|690x321](upload://giUnQ4k1BeIdSu93ylT6guDuUJa.png)

For I2P, the connection success rate averaged just above 60%. Both dave and jade had no success in connecting to I2P nodes during https://bnoc.xyz/t/attack-on-i2p-bitcoin-nodes-not-reachable-via-i2p/79 in February 2026.

![image|690x321](upload://ph3jwjTPq4Rtt6yONQM3vClb6dD.png)

### By connection type

For alice, dave, and frank, we have the success rate by connection type since April 2026 (due to https://github.com/bitcoin/bitcoin/commit/67696b207f370e902c8d5fb765e4ff10f6c9e1b4 ; see above).

For all three nodes, the outbound-full-relay connections have a success rate of about 5%. On alice and frank, who can both only connect to IPv4, this matches with the feeler connections. However, on dave, the feeler connections have a much higher success rate at above 30%. On explanation for this is the high Tor and I2P success rate we’ve seen on dave. However, block-relay-only connections have a much higher success rate than the outbound-full-relay we are making. For alice and frank, about 20%-30%, and for dave about 40%.

![Outbound connection type success rate over time|690x369](upload://oxsgEiHmbrPeJfLRe7AiF5iBgz0.png)

At first, this was confusing to me: block-relay-only connection success rates should not differ so much from outbound-full-relay success rates, as we select from the address manager tried table for both (as opposed to selecting from the new table for feelers).

https://github.com/bitcoin/bitcoin/blob/8598ec220450b05eff03fc1d1c81f51269cca247/src/net.cpp#L2866-L2874

### By network and connection type

Looking at, for example, the success rate of alice’s IPv4 connections, shows that both block-relay-only and outbound-full-relay connections share the same \~25% percent success rate. At the same time, feelers are only successful at less than 10% of the cases in early April 2026 and less than 5% successful in June 2026 (I suspect this is related to the ongoing address message spam covered in https://bnoc.xyz/t/python-bitcoinlib-0-12-2-client-getting-addr-ratelimited-since-2026-04-10/116/6 ).

![Success rate of alice's connections by connection type and network|690x369](upload://2rjEIG2iahIrZS81vCuw1eN2zVG.png)

All attempts of alice to connect to IPv6 fail (not shown here). This helps to explain why the success rate of block-only and full-relay connections differ:

As discussed in https://bnoc.xyz/t/outbound-connection-success-rates-of-a-bitcoin-node/142/2?u=b10c , Alice makes about 3 IPv4 full-relay attempts at a \~25% success rate. It also makes 12.5 IPv6 block-relay-only connections to IPv6 with a 0% success rate. This means, maybe 3/4 out of 15.5 (or about 5%) of outbound-full-relay attempts succeed. 

For block-relay-only, it’s 12.5 IPv4 attempts per hour with the same 25% success rate, and 3 IPv6 attempts per hour that always fail. That’s 3,125 connections per 15.5 block-relay-only attempts that succeed (or about 20%). 

Both of these match what we’ve seen before in the “By connection type” section during the last few months.

-------------------------

b10c | 2026-06-18 17:52:54 UTC | #4

For the [simulation](https://github.com/bitcoin/bitcoin/issues/34019#issuecomment-4422039561), we are primarily looking for a realistic success rate of IPv4 and IPv6 connections. This allows us to simulate a node picking an address, “attempting” a connection to it, and then either succeeding or failing. When we fail, we “attempt“ another connection. Additionally, we want a success rate that ignores feelers, as feelers are only made to connections from the addrman new table (addresses we’ve never tried before). These are expected to be worse than connections to the tried table (addresses we’ve tried before).

https://github.com/bitcoin/bitcoin/blob/8598ec220450b05eff03fc1d1c81f51269cca247/src/net.cpp#L2863-L2864

For IPv4, we have this data from node Alice, which generally seems to perform very similar to the other nodes:

[quote="b10c, post:3, topic:142"]
### By network and connection type

Looking at, for example, the success rate of alice’s IPv4 connections, shows that both block-relay-only and outbound-full-relay connections share the same \~25% percent success rate.

[/quote]

We can probably get close to reality assuming a 25% connection attempt success rate for IPv4.

However, we don’t have the same data for IPv6 yet. Node jade is not running with https://github.com/bitcoin/bitcoin/commit/67696b207f370e902c8d5fb765e4ff10f6c9e1b4 and I don’t have historical data on it yet. Given that:

[quote="b10c, post:3, topic:142"]
Only `jade` makes connections to IPv6. There, we have connection success rate just above 20%.

[/quote]

matches the numbers for IPv4:

[quote="b10c, post:3, topic:142"]
All nodes can make connections via IPv4. Between 2025-01 and 2025-03-31, the nodes averaged at about a 20% (or slightly more) connection success rate.

[/quote]

we could assume a 25% success rate for IPv6 non-feeler connections too.

-------------------------

b10c | 2026-10-01 14:36:26 UTC | #5

For the simulation, it’s also important to know how frequently connections to Bitprojects ( https://bnoc.xyz/t/many-connections-to-bitproject-io-nodes/40/19 ) were attempted and how often they succeeded. If, for example, all attempted connections to Bitprojects succeeded, then we can assume that once we picked a Bitprojects address from our address manager, we also made a connection to it.

In the final months before it was shut down, Bitprojects was using 12x /24 IPv4 ranges with each of these 3072 IPs having some kind of reachable Bitcoin node behind it. My nodes first started making connections to it in mid July 2024. This grew to about 0.75 outbound connections per hour per node in April 2025. In October 2025, this started to increase and by January 2026, some of my nodes were making 2 outbound connections per hour to Bitprojects IPs. But how many of these connections were successful?

![Outbound connection attempts to Bitporjects per hour (per node)|690x372](upload://o7rpC36MjrbnsARy9Hxe47qmwFb.png)

When Bitprojects initially started in mid 2024, connectivity to it wasn’t good. Until early 2025, usually less than half of the connections my nodes attempted to Bitprojects succeeded. This changed in early 2025. Then, nearly all connections succeeded. There still was some downtime here and there, but for many of my nodes, there were multiple weeks with high success rates. Around October 2025, connectivity dropped nearly completely, which is likely related to the clock misconfiguration Antoine discusses in https://antoinep.com/posts/misbehaving_nodes/ and the Bitprojects maintainer pausing and then re-enabling the nodes. From then on, connectivity remained very high until the nodes were stopped at the end of March 2026.

![Success rate of connections to Bitprojects IPs|690x276](upload://rmoF0RfoJ3Sifn1mBToT4shNOT2.png)

While Bitprojects used 12x /24 IPv4 subnets at the end, they started with the first /24 in mid July 2024. In October, November, and December 2024, they added three more /24’s. In October 2025, they added eight more /24’s.

![image|690x280](upload://aUQmDp3Sbx7UNPxgoXlEfRwRYjy.png)

-------------------------

b10c | 2026-06-20 14:02:00 UTC | #6

## connections with v2 transport

Bitcoin Core v26.0 (released November 2023) introduced experimental support for BIP324 v2 transport, but it was off by default and had to be enabled manually using the `-v2transport` option. It was enabled by default in Bitcoin Core v27.0, which was released in April 2024. In June 2026, more than 80% of the outbound connection attempts my nodes make are to v2 nodes.

![image|690x366](upload://rVOStryWe1lxJoqLUyuQT4z77XK.png)

It can happen, that we try to make a v2 connection to a node which does not support v2 transport. For example, when we store an address with the service flag \`NODE_P2P_V2\` set in our address manager, because we received it this way through address gossip. We’ll attempt a v2 connection, but downgrade to v1 if we can connect, but can not establish a v2 connection.

My nodes downgrade from v2 → v1 transport for about 30 to 40 connections per day. Depending on node, they have between 200 and 400 successful connection attempts per day. This means, we have a v2 → downgrade rate somewhere between 15% and 20%. Most of these seem to be feeler connections. This is expected, as we’re using information from the new table for feelers. In the tried table, we’ve updated potential service flag mismatches after a first connection.

![image|690x374](upload://7wnxUYZqZZ9OM6hVQkutfg1tENZ.jpeg)

-------------------------

sudocarlos | 2026-06-20 14:17:11 UTC | #7

Are you considering any analysis based on ASmap?

-------------------------

b10c | 2026-06-20 14:33:01 UTC | #8

I haven’t used any ASmap information yet for this. Anything you are curious about?

I’ve seen a lot of connection attempts to [AS56047](https://ipinfo.io/AS56047) (China Mobile Communications Corporation) on different IPv4 subnets. This might be interesting to look into further. Having AS information would allow to find other Bitprojects-like entities easier in this data.

-------------------------

sudocarlos | 2026-06-20 17:05:02 UTC | #9

I’m curious to know if ASmap is behaving as intended and whether certain AS are more likely to encounter connection issues. There are probably more interesting considerations, but I’m not very creative.

-------------------------

b10c | 2026-06-22 16:48:57 UTC | #10

## connections to Tor exit nodes

When Bitcoin nodes use a Tor proxy to connect to clearnet peers (`node → proxy/tor exit node → clearnet peer`), the node might self-announce the proxy/Tor exit node address, as that’s what the peer thinks the node has.

This is being changed in https://github.com/bitcoin/bitcoin/pull/35578 by @stratospher.  For this, it’s interesting to know how many connections my node attempted (and succeeded in making) to Tor exit nodes. For this, I’m using the Tor exit node IPs since 2024-01 as archived on https://collector.torproject.org/archive/exit-lists/ . 

In mid 2026, my nodes each make between 7.5 to 12.5 connection attempts per day to Tor exit node IPs.

![Outbound connection attempts to Tor exit nodes per day (per node)|690x369](upload://tHFnSeJU7kTi2eUrI3kL8C4GaiQ.jpeg)

-------------------------

Crypt-iQ | 2026-06-22 18:00:09 UTC | #11

Hi @b10c I see you posted data on churn in outbound connections, but wondering if you also have data on how long outbound connections are lasting as well?

-------------------------

mzumsande | 2026-06-22 22:35:27 UTC | #12

Many of the IPv6 connections are [network-specific connections](https://github.com/bitcoin/bitcoin/pull/27213) that are attempted on average every 5 minutes (EXTRA_NETWORK_PEER_INTERVAL): The node views IPv6 as reachable and therefore tries in vain every 5 minutes to diversify its networks  by adding an additional IPv6 full outbound. I don’t think this is a huge problem because these attempts fail immediately and shouldn’t take up meaningful resources, but it would be nice if we could detect automatically if IPv6 is reachable.

-------------------------

ajtowns | 2026-06-23 01:27:19 UTC | #13

Isn't this already a good way of detecting if IPv6 is reachable? It means that the node will quickly start working on IPv6 if it becomes available, doesn't rely on OS specific features or create additional code paths, and is fairly low cost.

-------------------------

mzumsande | 2026-06-24 09:06:55 UTC | #14

It is a slow and not very reliable heuristic - we need multiple samples since connections could also fail because our addrman is old/of low quality. it would be ideal if we could detect this immediately and with a high degree of certainty during init but that doesn’t seem to be all that easy given that something like pinging hard-coded popular IPv6 addresses is probably out of the question for privacy reasons.

-------------------------

stratospher | 2026-10-01 17:06:40 UTC | #15

just cross posting the last 2 graphs from https://bnoc.xyz/t/address-relay-under-stress-attack-characteristics-and-measuring-its-effects/164/9 (this post has more details about what the graphs mean) since I think it's also relevant here:

1.  successful outbound connections (outbound full relay + block relay + no feelers) which happen based on new and tried table.

![new_tried_outbound_success|690x271](upload://30cmmZojWPPSO4lwfDA1xCYX7sk.png)


2. successful feelers (already covered in https://bnoc.xyz/t/outbound-connection-success-rates-of-a-bitcoin-node/142/2#p-477-by-connection-type-2 but this is with only alice's 2.5 years data)

![feeler_success|690x271](upload://gxMLMfe5m9L9UivoFpLjjDsuANt.png)

-------------------------

