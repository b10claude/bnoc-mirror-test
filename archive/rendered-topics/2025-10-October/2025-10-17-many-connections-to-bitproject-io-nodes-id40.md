# Many connections to bitproject.io nodes?

instagibbs | 2025-12-04 17:06:34 UTC | #1

edit (@b10c): the title was originally "/Satoshi:29.1.0(dont-spam-me-bro)/ nodes?".

Noticed these connections on both my outbound and inbound direction on various nodes: "/Satoshi:29.1.0(dont-spam-me-bro)/"

They appear to behave fairly normally, relaying 0-fee TRUC transactions in a package (precluding stock Knots 29.1), but I don't know anything else about them.

https://blockchair.com/bitcoin/nodes reports 1200 of these

I couldn't find any results with google-fu on github.

Let me know if there's any information I can gather. Would like to know who's propping these up.

-------------------------

instagibbs | 2025-10-18 07:39:44 UTC | #2

https://who.is/whois-ip/ip-address/203.11.72.185

oh. 3 for 3 looking these up


edit for clarity (@b10c): whois mentions bitprojects.io (which is known from http://antoinep.com/posts/misbehaving_nodes/). Seems like they are back, now with a custom user agent. Marking this as solved.

-------------------------

b10c | 2025-10-18 07:39:15 UTC | #3

I noticed I have two of my outbound slots of `len` (demo.peer.observer) connected to them. instagibbs mentioned to me he has 3 of his outbound slots connected to them on one of his nodes. This is worrying, as filling outbound slots should be hard to avoid eclipse attacks.

ASMap would help for this.

-------------------------

b10c | 2025-10-30 16:09:23 UTC | #4

The last time I saw dont-spam-me-bro connecting to me was on 2024-10-24. They now appear as `/Satoshi:29.2.0(not-your-file-server)/Knots:20251010/`.

-------------------------

instagibbs | 2025-10-30 16:18:41 UTC | #5

![image|259x194](upload://m2WgUom6wZry86FkG0WgIp9jmWJ.jpeg)
back, in knots form

-------------------------

b10c | 2025-11-12 13:05:17 UTC | #6

Doing IBD on a fresh node, I see 4 connections to `/Satoshi:29.2.0(not-your-file-server)/Knots:20251010/` nodes. Let’s see if they remain after IBD..

```bash

$ bitcoin-cli -netinfo 3
Bitcoin Core client v30.0.0 - server 70016/Satoshi:30.0.0/ - services nwcl2

↔   type   net   serv  v  mping   ping send recv  txn  blk  hb addrp addrl  age id version
out  block  ipv4   nwl2  1     19   7465    1    1    *    0         .         24  8 70016/Satoshi:29.2.0(not-your-file-server)/Knots:20251010/
out   full  ipv4   nwl2  2     22     50    1    1         0      1027         24  3 70016/Satoshi:29.1.0/
out   full  ipv4   nwl2  2     27    511    1    0         0      1008         24  0 70016/Satoshi:29.2.0(not-your-file-server)/Knots:20251010/
out   full  ipv4   nwl2  2     59   2039    0    0         0      1006         24  6 70016/Satoshi:29.2.0(not-your-file-server)/Knots:20251010/
out   full  ipv4    nwl  1     78     90    0    0         0      1028         24  4 70016/Satoshi:25.0.0/
out   full  ipv4   nwl2  2     81   7772    0    1         0      1006         24  7 70016/Satoshi:29.2.0(not-your-file-server)/Knots:20251010/
out   full  ipv4   nwl2  2    105   1195    0    0         0      1027         24  2 70016/Satoshi:27.1.0/
out   full  ipv4   nwl2  2    109   2033    1    0         0      1038         24  1 70016/Satoshi:28.0.0/
out  block  ipv4   nwl2  1    128    948    0    0    *    0         .         23  9 70016/Satoshi:29.0.0/
out   full  ipv4    nwl  1    156    156    1    0         0      1023         24  5 70015/Satoshi:0.20.0/
ms     ms  sec  sec  min  min                  min

ipv4    ipv6   total   block

in          0       0       0
out        10       0      10       2
total      10       0      10
```

edit: that node is not running with ASMap enabled.

-------------------------

Antoine | 2025-11-17 15:09:17 UTC | #7

[quote="b10c, post:6, topic:40"]
edit: that node is not running with ASMap enabled.

[/quote]

I’m not sure ASMap would be a substantial improvement over the current /16 mechanism. There is 10 peers to choose from 10k /16’s available. That’s roughly a $(n / 10_000)^10$ probability to connect to an attacker controlling $n$ /16’s.

That said, it seems that it’s not what happens in practice. The Bitprojects guy controls only 12 /16’s. That a node would pick any of those 12 for 4 of its slots **if it has heard about all /16’s available** is essentially null. Could it be that somehow he found a way to bias DNS seeds towards his nodes, such as a node joining the network does not hear about many more /16’s than his?

-------------------------

instagibbs | 2025-11-20 18:35:13 UTC | #8

[quote="Antoine, post:7, topic:40"]
Could it be that somehow he found a way to bias DNS seeds towards his nodes, such as a node joining the network does not hear about many more /16’s than his?

[/quote]

Should we expect this effect to dissipate as a node has longer running time?

-------------------------

b10c | 2025-11-26 13:21:00 UTC | #9

I've set up some data collection on the number of outbound connections I have to the bitproject IPs (also inbound, but don't seem to have gotten any inbounds from them).

Currently, three of my nodes have two of their outbounds to bitprojects:

![image|690x208](upload://70mgJjKdZI4joPm0fzLijyZD0HZ.png)

-------------------------

b10c | 2025-12-01 10:35:31 UTC | #10

Seeing three out-bounds from `alice` to bitprojects and four from `paul` (which is a new newly set up node). 

![image|690x429](upload://uqUtPHHcM4738kPM3gtpIl0tSCS.png)

-------------------------

Antoine | 2025-12-01 18:10:55 UTC | #11

[quote="Antoine, post:7, topic:40"]
Could it be that somehow he found a way to bias DNS seeds towards his nodes, such as a node joining the network does not hear about many more /16’s than his?

[/quote]

Or maybe his addresses get rumoured a lot more? If the addresses a node will return to a `GETADDR` are randomly sampled among all known addresses, instead of first sampling by /16, then it seems that his nodes would be overly represented.

-------------------------

mzumsande | 2025-12-01 18:29:38 UTC | #12

[quote="Antoine, post:7, topic:40"]
That said, it seems that it’s not what happens in practice. The Bitprojects guy controls only 12 /16’s. That a node would pick any of those 12 for 4 of its slots **if it has heard about all /16’s available** is essentially null.

[/quote]

We don’t sample based on /16 - we sample based on address (and abort/get another sample if another outbound is from the same range). For example, if we have an addrman with 99 addresses from /16 range A and 1 address from /16 range B, we’ll pick an addr from A for our first peer with 99% probability.

So controlling a large number of addresses from a given /16 range does increase chances of being picked even if other nodes will only make one connection to that range.

-------------------------

instagibbs | 2025-12-01 19:39:51 UTC | #13

FWIW they don’t seem to be advertising with the custom subver anymore. Also they’re having major latency issues.

-------------------------

Antoine | 2025-12-02 15:07:11 UTC | #14

I discussed this with a few people out of band, but just to share here this explains why we are seeing so many peers connect to the Bitprojects guy. My previous assumption on how this logic works:

[quote="Antoine, post:7, topic:40"]
There is 10 peers to choose from 10k /16’s available. That’s roughly a  probability to connect to an attacker controlling  /16’s.

[/quote]

Was incorrect, as Martin explained above. So it seems that if he was controlling just a few more /16’s, as well as a few thousands more “node” IPs then he would have a decent chance of eclipsing a node.

I find it surprising that AddrMan doesn’t work the way i expected it to, because it would make the probability of controlling all of a node’s outbound connections decrease exponentially in the number of connection slots. As far as i understand (and what i got from a quick discussion at the office) this is due to architectural limitations in AddrMan’s implementation. I’ve started looking into what it would take to implement what i suggest.

-------------------------

instagibbs | 2025-12-03 19:36:13 UTC | #15

This seems quite problematic and defeats almost any gains asmap affords?

-------------------------

fjahr | 2025-12-04 15:13:17 UTC | #16

> So it seems that if he was controlling just a few more /16’s, as well as a few thousands more “node” IPs

FWIW, getting control of a /16 and all its IPs costs millions of USD. But using IPv6 should make this much easier to scale.

> This seems quite problematic and defeats almost any gains asmap affords?

Why would it defeat all the gains? You can easily get hundreds of IPs across 13 different /16 on AWS or any other larger hoster. Getting many ASNs and making hundreds of IPs available through them is a much higher bar. Also, there are less than 100k ASNs in use in global routing and getting a large number of them without a legitimate use-case would a considerable bureaucratic hurdle.

-------------------------

Antoine | 2025-12-04 15:22:11 UTC | #17

[quote="fjahr, post:16, topic:40"]
and getting a large number of them

[/quote]

The issue is that with the current peer selection algorithm you don’t need a large number of them, just as many as we make outbound connections by default, or slightly more. The bitprojects guy already controls 12 /24’s spread across /16 boundaries and 3 or 4 AS’s. It does not seem completely unrealistic to me that he would be able to spin up a large number of (maybe fake) nodes in more than 10 net groups (either /16’s or AS’s).

-------------------------

fjahr | 2025-12-04 15:44:30 UTC | #18

> you don’t need a large number of them
>
> more than 10 net groups

And I am saying that 10 is a large number for ASNs at least relatively speaking. There are 2^96 /32s in IPV6 almost all available to use if you just put down a little bit of money.

-------------------------

b10c | 2025-12-04 16:31:13 UTC | #19

An updated screenshot of my dashboard:

![image|690x285](upload://vhNIvzIR6tt4bTcgqhRjg4wvA9z.png)

-------------------------

b10c | 2026-02-02 15:05:17 UTC | #20

A lot less outbound connections to bitprojects at the moment but they seem to be still active.

![image|673x500](upload://1qnNubeQnHT8Ed9cqWrmKkFXrpv.png)

-------------------------

Antoine | 2026-03-19 18:43:11 UTC | #21

Looks like they have now switched to “signal” for BIP 110 in their subver. :man_facepalming:

-------------------------

willcl-ark | 2026-03-25 12:15:51 UTC | #22

> Looks like they have now switched to “signal” for BIP 110 in their subver. :man_facepalming:

These (sybil) nodes make up 92% of the “good” BIP110 nodes my bitcoin seed/crawler knows about: https://willcl-ark.github.io/dnsseedrs/

-------------------------

b10c | 2026-03-26 11:49:19 UTC | #23

On 2026-03-24 at around 9:20 UTC one of my nodes made five outbound connections to bitprojects nodes. It didn't have any before. These connections are still active. 

I have logs for this, so I can investigate a bit (when I find the time to do so) why exactly this happened.

edit: I had a brief look at the logs. It turns out the node had a brief network disconnect due to datacenter maintaince, lost all it's peers, and when it came back, it choose to open 5 outbound connection to bitprojects...

-------------------------

bitprojects | 2026-04-01 06:24:21 UTC | #24

greetings all, i’m the guy that was running this

update:  all of these nodes are now shut down and will not return – intended outcome has been reached, proved the point, and it seems like everyone who needs to understand the severity/risk does see it now.

lmk any questions.

btw this entire infra I stood up cost about $2k/mo

-------------------------

bitprojects | 2026-04-01 06:34:32 UTC | #25

Last stats before everything was shut down:

=== Inbound TCP/8333 (bitcoin) Connection and Network Stats ===
Total unique destination IPs: 3042
Total unique destination /24 subnets: 12
Total destination subnets sharing /16 boundary: 0
Total ASNs: 3   <<< BTW this defeats asmap in current state
Total subnets advertised per ASN: 4
Total inbound connections: 80526
Total unique source IPs: 35127
=== Source IP Connection Thresholds ===
Source IPs with    8+ connections: 653
Source IPs with   10+ connections: 433
Source IPs with   12+ connections: 307
Source IPs with   16+ connections: 178
Source IPs with   32+ connections: 38
Source IPs with   64+ connections: 14
Source IPs with  512+ connections: 0
Source IPs with 2048+ connections: 0

![Screenshot_2026-03-30_15-08-41|602x500](upload://vd3zGYPp3eJHxq1asvN9XGUWTY3.png)

-------------------------

b10c | 2026-04-01 07:09:32 UTC | #26

[quote="bitprojects, post:24, topic:40"]
intended outcome has been reached, proved the point, and it seems like everyone who needs to understand the severity/risk does see it now.
[/quote]

I tend to agree. Thanks.

[quote="bitprojects, post:25, topic:40"]
Source IPs with 8+ connections: 653
Source IPs with 10+ connections: 433
Source IPs with 12+ connections: 307
Source IPs with 16+ connections: 178
Source IPs with 32+ connections: 38
Source IPs with 64+ connections: 14
Source IPs with 512+ connections: 0
Source IPs with 2048+ connections: 0
[/quote]

Since Bitcoin Core nodes make by default 8 outbound-full-relay and 2 block-relay-only connections, I'm assuming every source with more than 10 connections is either a custom client trying to mass-connect to all IPs or multiple Bitcoin Core nodes making connections from the same host / IP.

This still leaves us with 220 nodes potentially making 8+ connections to you. The highest I've seen personally is 6 connections to bitprojects for a short while, which is still worrying.

-------------------------

bitprojects | 2026-04-01 07:13:28 UTC | #27

[quote="b10c, post:26, topic:40"]
Since Bitcoin Core nodes make by default 8 outbound-full-relay and 2 block-relay-only connections, I’m assuming every source with more than 10 connections is either a custom client trying to mass-connect to all IPs or multiple Bitcoin Core nodes making connections from the same host / IP.

This still leaves us with 220 nodes potentially making 8+ connections to you. The highest I’ve seen personally is 6 connections, which is still worrying.

[/quote]

Yeah this is why I split out these connection counts in this way.  There were dozens of subnets and single IPs that spun up hundreds or thousands of connections, so I automated null routing those sources once crossing the 1024 threshold.  

so at any point in time I believe there were hundreds of nodes that -only- connected to me, and that doesn’t sound good.

when the infra ran uninterrupted for 60+ days these single source counts were double or higher.

I should not be able to do something like this for $2k/mo.

-------------------------

bitprojects | 2026-04-01 18:12:26 UTC | #28

[quote="fjahr, post:18, topic:40"]
And I am saying that 10 is a large number for ASNs at least relatively speaking. There are 2^96 /32s in IPV6 almost all available to use if you just put down a little bit of money.

[/quote]

@fjahr ASNs are incredibly easy to justify approval for from the RIRs, and cost about $500 each for the higher numbers if buying, less if the RIR is assigning them.  Getting dozens of them is easy.  Even easier if an attacker is willing to spin up multiple legal entities and set up org accounts w/ the RIRs.

Separately on the IP side, renting/leasing IP space in /24 blocks costs about $0.30-0.40/mo per IP when rented from a third party/non carrier.  Even less cost when you’re willing to rent poor reputation IPs, which bitcoin does not care about.

I intend to spin up some ways to pull down the full BGP routing table via API (will also put the code on github, pulls from FRR, can be spun up on cloud providers that support BGP), I think it would be useful to query the full AS path of a given node and use that for warnings.  In the case of what I stood up, all of the ASNs and subnets shared common AS path ASNs.

-------------------------

b10c | 2026-04-02 11:33:20 UTC | #29

Linking to https://bnoc.xyz/t/steep-increase-in-inbound-connections-on-2026-03-31-at-00-12-utc/108 here. Seems like @bitprojects shutting down the nodes caused a lot of nodes to look for new outbound peers at the same time.

-------------------------

Antoine | 2026-04-02 17:36:03 UTC | #30

Related to this topic, I opened [an issue on the Bitcoin Core repository](https://github.com/bitcoin/bitcoin/issues/34019) back in December about updating our peer selection algorithm to be more robust against an attacker “simply” spinning up a high number of nodes across a small number of net groups.

If there is renewed interest in addressing these concerns, i would welcome some feedback there.

-------------------------

