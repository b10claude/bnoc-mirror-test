# Address Relay under stress

mzumsande | 2026-08-14 17:29:20 UTC | #1

This is joint work with @stratospher.

From April 2026 to July 2026, there was a [period of increased address relay](https://bnoc.xyz/t/waves-of-bad-addresses-being-gossiped/61) caused by some entity spamming the network. In this post, we will discuss what consequences it had on the network, together with some ideas to improve the resilience of address relay against such periods of spam. See [this post](https://bnoc.xyz/t/address-relay-under-stress-attack-characteristics-and-measuring-its-effects/164) for a more detailed analysis of the data.

## **The spam**

As can be seen from [the KIT monitoring website](https://www.dsn.kastel.kit.edu/bitcoin/) (“Observed Addresses”), the number of addresses being relayed increased by a factor of 10, until it got back to its previous level. Most of these addresses were random IPv4, not belonging to any real bitcoin node. A similar period of spam already happened in [2021](https://publikationen.bibliothek.kit.edu/1000146768). The rate limiting of addresses that was implemented as a response in 2021 reduces the amount of spam that is possible, but it cannot prevent the spam entirely.

## **Consequences for the network**

On a high level, we believe that the following happened during the spam period:

* Nothing broke immediately
  There were no major disturbances. Most node operators didn’t notice that anything was different than usual. However, there were still various unwanted effects.

* Most connections are made to peers from the Tried table
  The Address Manager of Bitcoin Core (AddrMan) consists of two tables, the New table for unverified addresses, and the Tried table for addresses we have successfully connected to in the past. When the New table is congested with spam, almost all successful outgoing connections (that are made with a 50% chance per selection attempt from new or tried) will be made from the Tried table, which is unaffected by the spam.

* Address relay becomes ineffective
  When spam addresses fill up large parts of the New table, legitimate addresses (i.e., self-announcements from actual nodes) have only a low chance of being accepted because their potential spot in AddrMan is already taken. So while addresses are still being relayed to other peers as usual via gossip relay, most of the nodes will not accept them but only send them further along, which defeats the point of the relay mechanism.

* Feelers become ineffective
  Feelers are a mechanism to move addresses from New to Tried by verifying they belong to real bitcoin nodes. Since most addresses from New do not belong to real nodes, feelers have a very low success rate. Therefore, it is hard for nodes (especially new ones) to build up a Tried table with good candidates.

* New nodes will get inbound peers more slowly
  Since address relay has become ineffective, fewer nodes will learn about actual new nodes and connect to them. A new node that we started up had only \~20 real inbound peers (discounting spy nodes) after 2 weeks, which is much slower than under normal network conditions.

In summary, even though there are no immediate major disturbances, the spam has a negative long-term impact on various important p2p mechanisms, especially if it is sustained for an extended period.

## **Mitigation ideas**

Since address relay, unlike transaction or block relay, does not come with a significant intrinsic cost, it is hard to prevent the spam itself. So the goal should be to improve things so that even in periods of spam, address relay and acceptance of legitimate addresses is effective.

#### 1. Relax IsTerrible rules

A candidate for the new table only replaces an existing entry in its slot if that entry is deemed *Terrible*. Whether an address is Terrible is decided by various criteria, among them that we failed 3 times to connect to an address that we never connected to before.

We suggest reducing this number from 3 to 1. With a full new table, a count of 3 retries is effectively unreachable, since there are \~65k other candidates.

With that change, non-reachable addresses would be replaceable faster. Since Terrible also excludes nodes from being part of GETADDR answers, we would also send less low-quality addres that way.
This mitigation measure would be simple to implement, but on its own it likely won’t have a big impact since we don’t make enough new connections that bad addresses would become terrible fast.

#### 2. Increase the feeler rate

We currently make a feeler connection every 2 minutes. This results in 720 attempts per day, compared to a maximum of 65536 possible entries in the New table, so that it would take >90 days to probe every address. Raising the rate, to e.g. once every 30s could be helpful, and comes at a negligible cost, at least for clearnet addresses. Moreover, it could make sense to couple the rate to the network of the address since I2P/Tor connections are more expensive.

#### 3. Relay some quality addresses with priority

We could consider filling the first N slots of a GetAddr response with addresses from Tried. The receiving node could then treat these addresses with a higher priority, i.e. always accept them to AddrMan in case of a collision, and possibly schedule them for a feeler connection with a higher priority.

Because we only send GetAddr to peers we connect to, a spammer cannot easily influence these preferred addresses. However, this idea still has to be evaluated very carefully because it has a downside: While it helps against spam attacks, it could also help an eclipse attacker (i.e. someone running a number of nodes with the goal of making the victim pick all of their outbound connections to them): Especially with a larger N, there could be an amplifying effect in which a new node would quickly fill a large percentage of its Tried table with attacker-controlled nodes. However, choosing a small N, maybe just N=1, could be beneficial.

Revealing addresses to belong to the Tried table also has privacy implications, which are reduced by the fact that GetAddr answers are cached for 24h.

-------------------------

ajtowns | 2026-08-14 21:34:36 UTC | #2

[quote="mzumsande, post:1, topic:163"]
We suggest reducing this number from 3 to 1. With a full new table, a count of 3 retries is effectively unreachable, since there are ~65k other candidates.
[/quote]

What about something like "expire an entry from the new table if it's older than a week, and the new table is at greater than 50% capacity" ? Or would that just encourage more address spam and ultimately reach the same state?

> We could consider filling the first N slots of a GetAddr response with addresses from Tried.

Perhaps select a random subset (20%?) of the tried table to draw these addresses from, with the subset preserved across restarts?

-------------------------

b10c | 2026-08-15 08:52:34 UTC | #3


[quote="mzumsande, post:1, topic:163"]
#### 2. Increase the feeler rate

We currently make a feeler connection every 2 minutes. This results in 720 attempts per day, compared to a maximum of 65536 possible entries in the New table, so that it would take >90 days to probe every address. Raising the rate, to e.g. once every 30s could be helpful, and comes at a negligible cost, at least for clearnet addresses. Moreover, it could make sense to couple the rate to the network of the address since I2P/Tor connections are more expensive.
[/quote]

The cost might be negligible on the side that's establishing these connections, but I fear that a 4x inbound rate to listening nodes (from a diverse set of inbound netgroups) will evict far more connections that might become long-lived connections than currently are evicted. Each eviction will in-turn cause another outbound connection being made, which might again evict a connection...

Would a separate handling of feeler/crawler/bitnodes-uptime-check connections, that specifically opt-in to being short-lived and only for checking if there's a node behind this IP, make sense? For these connections, the mutual agreement would be to close the connection immediately after the version handshake, so the receiving node wouldn't need to evict a connection for a crawler/feeler. I guess the implementation of this is tricky, as you need to tell the node to not-evict someone very early on in the crawler/feeler-connection-lifecyle.

-------------------------

mzumsande | 2026-08-17 16:28:19 UTC | #4

[quote="ajtowns, post:2, topic:163"]
What about something like “expire an entry from the new table if it’s older than a week, and the new table is at greater than 50% capacity” ? Or would that just encourage more address spam and ultimately reach the same state?

[/quote]

Assuming that with “expire”, you mean making Terrible, not outright delete. I think that tying it to the current capacity is an interesting idea - although 50%! The downside of relaxing the IsTerrible too much is that we might not have enough addresses to include in a GetAddr message (or we would need to have two different notions of Terrible for that).

[quote="ajtowns, post:2, topic:163"]
Perhaps select a random subset (20%?) of the tried table to draw these addresses from, with the subset preserved across restarts?

[/quote]

Yes, that’s an interesting idea that could work! I think it that even a low number (e.g. N<5, and take only from 1 tried bucket), together with a preferred feeler scheduling, would have the effect that new nodes would be much less affected by spam.

[quote="b10c, post:3, topic:163"]
The cost might be negligible on the side that’s establishing these connections, but I fear that a 4x inbound rate to listening nodes (from a diverse set of inbound netgroups) will evict far more connections that might become long-lived connections than currently are evicted. Each eviction will in-turn cause another outbound connection being made, which might again evict a connection…

[/quote]

I think it makes sense to view it such that already now 1 or maybe even 2 of our inbound slots are basically reserved for short-term connections such as feelers (or other software that does regular connection pings such as DNS seed crawlers etc.) and cannot host a long-term inbound peer anyway.

Given that a feeler connection will only be connected for a very short time period (we only  send a VERSION, receive a VERSION and disconnect), I would not expect a higher feeler rate will have much of an effect. 
In addition, because #28463 was merged, many nodes will get a lot of additional capacity for non-tx relaying connections which can also be used by feelers.

-------------------------

Crypt-iQ | 2026-09-01 13:23:53 UTC | #5

> While it helps against spam attacks, it could also help an eclipse attacker (i.e. someone running a number of nodes with the goal of making the victim pick all of their outbound connections to them): Especially with a larger N, there could be an amplifying effect in which a new node would quickly fill a large percentage of its Tried table with attacker-controlled nodes. However, choosing a small N, maybe just N=1, could be beneficial.

I think with N=1 there could still be some (minor?) amplification since an attacking node can respond with another of their addresses. If we then prioritize a feeler to that one and end up later connecting to it as a regular outbound connection, they could advertise another of their addresses in GETADDR and so on. Maybe the feeler priority logic could take into account the AS of the address so that even with higher N, an attacker would need multiple AS to have all of them prioritized? But maybe this doesn't matter too much if feelers are every 30s and we'd hopefully have some honest priority feelers in the mix?

> The cost might be negligible on the side that’s establishing these connections, but I fear that a 4x inbound rate to listening nodes (from a diverse set of inbound netgroups) will evict far more connections that might become long-lived connections than currently are evicted. Each eviction will in-turn cause another outbound connection being made, which might again evict a connection…

I agree, this might increase the connection churn in the network. Maybe a simulation could help here to see if it's an acceptable amount?

-------------------------

naiyoma | 2026-09-02 14:06:28 UTC | #6

[quote="mzumsande, post:1, topic:163"]
We suggest reducing this number from 3 to 1. With a full new table, a count of 3 retries is effectively unreachable, since there are \~65k other candidates.

[/quote]

About 98% of all my terrible addresses have always been terrible because of aging out (`nTime > ADDRMAN_HORIZON`). The other conditions are almost never true.

From my own node calculation, changing ADDRMAN_RETRIES
to 1 would increase my isTerrible rate to 25%.

I wonder if the initial idea was that we need at least three unsuccessful attempts because some nodes might be offline temporarily but could come back online. If we changed this, an address comes back online, but we don’t make another attempt? In that case, the address would be at a disadvantage; maybe 2 might be a better middle ground

-------------------------

naiyoma | 2026-09-02 14:13:00 UTC | #7

[quote="mzumsande, post:4, topic:163"]
The downside of relaxing the IsTerrible too much

[/quote]

Maybe 14days is also an option , a bit relaxed and  not too strict and would still make a difference.

-------------------------

mzumsande | 2026-09-15 16:36:35 UTC | #8

I have implemented my suggestion 1 and 2 in [this branch](https://github.com/mzumsande/bitcoin/tree/202609_addr_relay_improvements). 

We will let this branch run for a while on our node and check how addrman quality evolves. Suggestion 3 is not implemented yet, it will only be effective if many nodes implement it, so cannot really be tested on a local node - and I definitely would want to do some simulations for that before actually PRing it.

[quote="Crypt-iQ, post:5, topic:163"]
I agree, this might increase the connection churn in the network. Maybe a simulation could help here to see if it’s an acceptable amount?

[/quote]

I think that a simulation wouldn't achieve much realism because the current state of the network is not very natural:

Any possible increase in incoming connections is going to be dwarfed  by [LinkinLion](https://b10c.me/observations/06-linkinglion/) or similar spammers, which make up to 10 connections each second to reachable nodes, resulting in the NodeId counter increasing by almost a Million each day on my nodes. 

Given that these "attacks" have not had much of a negative impact on the network (or were even noticed by most), I don't worry too much about one more feeler originating from a node every 30s.

[quote="naiyoma, post:6, topic:163"]
From my own node calculation, changing ADDRMAN_RETRIES
to 1 would increase my isTerrible rate to 25%.

[/quote]

Interesting -I will report back if I see similar.

-------------------------

