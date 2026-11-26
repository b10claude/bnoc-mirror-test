# LinkingLion: An entity linking Bitcoin transactions to IPs?

b10c | 2026-10-09 13:36:44 UTC | #1

In March 2023, I published https://b10c.me/observations/06-linkinglion/ about an entity which opens connections to many Bitcoin nodes using four IP address ranges and listens to transaction announcements. This might allow the entity to link newly broadcast transactions to node IP addresses. The entity has been active in some capacity since 2018 and is also active on the Monero network using the same IP address ranges. The entity might be a blockchain analysis company collecting data to improve its products.

### Before 2025-12:

The entity uses IP addresses from three IPv4 /24 ranges and one IPv6 /32 range to connect to listening nodes on the Bitcoin network. These IP address ranges are all [announced](https://archive.is/yMjSl) by AS54098, LionLink Networks. However, the ranges belong to different companies based on ARIN and RIPE registry information.

* `162.218.65.0/24`: Fork Networking, LLC (forked.net) - [ARIN Whois](https://search.arin.net/rdap/?query=162.218.65.0%2F24)
* `209.222.252.0/24`: Castle VPN, LLC (castlevpn.com) - [ARIN Whois](https://search.arin.net/rdap/?query=209.222.252.0%2F24)
* `91.198.115.0/24`: Linama UAB (?) - [RIPE Whois](https://apps.db.ripe.net/db-web-ui/query?searchtext=91.198.115.0%2F24)
* `2604:d500::/32`: Data Canopy (datacanopy.com) - [ARIN Whois](https://search.arin.net/rdap/?query=2604%3Ad500%3A%3A%2F32)


### After 2025-12:

In late 2025, LinkingLion switched to new IP address ranges announced by "Spruce Creek Networks LLC".

- 143.20.137.0/24
- 31.58.215.0/24
- 87.229.79.0/24
- 2602:f5c0:0:ace::/64

I've also seen connections from:

- 104.234.118.2/32
- 69.17.52.1/32

-------------------------

b10c | 2025-10-12 22:03:27 UTC | #2

A year later, I published an https://b10c.me/blog/013-one-year-update-on-linkinglion/.

-------------------------

b10c | 2025-10-12 22:18:03 UTC | #3

As of today (2025-10-13), LinkingLion is still active on the network and makes up about 1%-2% of inbound bandwidth and 3%-5% of outbound traffic (measured in bytes) of my nodes. Due to frequently being evicted and then reconnecting, they make up for about 5%-10% of inbound messages and 7%-13% of outbound messages (measured in count).

Since LinkingLion is a spy, it's expected that outbound traffic > inbound traffic. We send the Spy more than it sends us.

-------------------------

b10c | 2025-10-17 07:29:10 UTC | #4

LinkingLion connections are (and this has been happening for a while now) gossiping the address `10.1.1.71:8333`. The 10.0.0.0/8 network is a private network, so this might be unintentional?

-------------------------

b10c | 2025-10-28 16:14:37 UTC | #5

This shows connections from LIONLINK networks and from Digital Ocean (see also https://bnoc.xyz/t/digitalocean-satoshi-24-0-1-spy-nodes-connected-during-ibd/16) next to each other. I found it weird that these seem to rise and fall at the same time. Need to look into it further...

![image](upload://y7EBniM6jY3LMclqvy1xU6Mndcp.png)

-------------------------

b10c | 2025-11-07 02:49:08 UTC | #6

Re-posting the LinkingLion (fake) UserAgents here to enable finding this topic if someone searches for these:

from https://b10c.me/data/observations/06-linkinglion/linkinglion-user-agents.txt

```
/Satoshi:0.14.1/Knots:20170420/
/bitcoinj:0.14.4/Bitcoin Wallet:5.26/
/Satoshi:0.14.2(UASF-SegWit-BIP148)/
/bitcoinj:0.14.4/Bitcoin:1.074/
/bitcoinj:0.14.5/Bitcoin Wallet:5.40/
/Satoshi:0.15.99/
/bitcoinj:0.14.5/
/Satoshi:0.15.0/
/bitcoinj:0.13.3/Bitcoin Wallet:4.43-blackberry/
/bitcoinj:0.14.4/Bitcoin Wallet:5.30/
/Satoshi:0.11.1/
/Satoshi:0.15.0(NO2X)/
/breadwallet:1.4/
/Satoshi:0.14.99/
/Satoshi:0.13.0/
/bitcoinj:0.14.5/Bitcoin Wallet:5.41/
/bitcoinj:0.14.4/Bitcoin Wallet:5.21/
/bitcoinj:0.14.4/Bitcoin Wallet:5.28/
/bitcoinj:0.14.3/Bitcoin Wallet:4.72/
/bitcoinj:0.13.3/MultiBitHD:0.4.1/
/bitcoinj:0.14.3/Bitcoin Wallet:5.04/
/Satoshi:0.15.0.1/
/bitcoinj:0.14.3/Bitcoin Wallet:5.10/
/bitcoinj:0.14.4/Bitcoin Wallet:5.21-blackberry/
/Satoshi:0.14.2/UASF-Segwit:0.3(BIP148)/
/Satoshi:0.15.0.1(No2X)/
/Bitcoin ABC:0.14.5(EB8.0)/
/bitcoinj:0.14.5/Bitcoin Wallet:5.44/
/Classic:1.3.4(EB8)/
/Satoshi:0.14.1/
/breadwallet:0.6.8/
/bitcoinj:0.14.5/Bitcoin Wallet:5.45/
/Satoshi:0.15.0/Knots:20170914/
/Satoshi:0.10.0/
/bitcoinj:0.14.3/Bitcoin Wallet:4.58/
/breadwallet:0.6.9/
/bitcoinj:0.14.4/Bitcoin:1.075/
/Satoshi:0.15.1/Knots:20171111/
/bitcoinj:0.14.4/
/Satoshi:1.0.5/
/bitcoinj:0.13.3/MultiBitHD:0.5.1/
/Satoshi:0.11.0/
/Satoshi:0.14.1(UASF-SegWit-BIP148)/
/Satoshi:0.14.0/
/Satoshi:0.9.2/
/bitcoinj:0.14.4/Bitcoin Wallet:5.23/
/bitcoinj:0.14.5/Bitcoin Wallet:5.31/
/Satoshi:1.14.5(2x)/
/bitcoinj:0.13.4/Bitcoin Wallet:4.46/
/bitcoinj:0.14.5/Bitcoin Wallet:5.36/
/Satoshi:0.13.2/
/Satoshi:0.10.1/
/Satoshi:0.12.1/
/Satoshi:0.16.0/
/BitCoinJ:0.11.2/MultiBit:0.5.18/
/Satoshi:0.11.2/
/Satoshi:0.13.1/
/Satoshi:0.14.2(BIP148)/Knots:20170618/
/breadwallet:0.6.4/
/bitcoin-seeder:0.01/
/Satoshi:0.16.2/
/breadwallet:1.50/
/Satoshi:0.8.5/
/bitcoinj:0.13.5/
/Satoshi:0.10.2/
/BitCoinJ:0.11.2/MultiBit:0.5.19/
/Satoshi:0.7.0.3/
/Satoshi:0.8.2.2/
/bitcore:1.1.0/
/breadwallet:0.6.5/
/Satoshi:0.9.1/
/bitcoinj:0.14.5/Bitcoin Wallet:5.43/
/bitcoinj:0.14.4/Bitcoin Wallet:5.29/
/Satoshi:0.8.3/
/Satoshi:0.12.1(bitcore)/
/bitcoinj:0.14.3/Bitcoin Wallet:1.0.5/
/bitcoinj:0.14.4/Bitcoin Wallet:5.22/
/Bitcoin ABC:0.15.0(EB8.0)/
/bitcoinj:0.14.4/Bitcoin Wallet:5.20/
/Bitcoin ABC:0.16.1(EB8.0)/
/bitcoinj:0.14.1/Bitcoin:1.072/
/bitcoinj:0.15-SNAPSHOT/
/bitcoinj:0.14.5/Bitcoin Wallet:5.39/
/bitcoinj:0.14.5/Bitcoin Wallet:5.35/
/bcoin:v1.0.0-beta.14/
/bitcoinj:0.14.4/Bitcoin Wallet:5.24/
/Bitcoin ABC:0.14.6(EB8.0)/
/bitcoinj:0.14.4/Bitcoin Wallet:5.18/
/bitcoinj:0.14.5/Bitcoin Wallet:5.32/
/Satoshi:0.12.0/
/Satoshi:0.9.3/
/Classic:1.3.8(EB8)/
/Satoshi:0.8.0/
/Satoshi:0.7.2/
/breadwallet:0.6.7/
/bitcoinj:0.14.5/Bitcoin Wallet:5.33/
/bitcoinj:0.14.4/Bitcoin Wallet:5.19/
/bitcoinj:0.14.3/Bitcoin Wallet:5.12/
/bitcoinj:0.14.5/Bitcoin Wallet:5.42/
/Satoshi:0.15.1/
/Satoshi:0.8.1/
/BitCoinJ:0.11.1/MultiBit:0.5.17/
/breadwallet:0.6.6/
/Satoshi:0.16.99/
/Satoshi:0.8.6/
/Satoshi:0.14.2/
/bitcoinj:0.14.4/Bitcoin Wallet:5.17/
/breadwallet:1.3.5/
/Satoshi:0.15.0(UASF-SegWit-BIP148)/
/Satoshi:0.16.1/
/bitcoinj:0.14.4/Bitcoin Wallet:5.14/
/bitcoinj:0.14.3/Bitcoin Wallet:4.58.1-btcx/
/breadwallet:0.6.2/
/bitcoinj:0.14.5/Bitcoin Wallet:5.37/
/bitcoinj:0.14.4/Bitcoin Wallet:5.25/
/Satoshi:0.14.2/UASF-Segwit:1.0(BIP148)/
/breadwallet:1.51/
/bitcoinj:0.14.5/Bitcoin Wallet:5.38/
```

-------------------------

b10c | 2025-12-08 10:29:07 UTC | #7

While looking at IP address self-announcements that are rate-limited by Bitcoin Core nodes in https://github.com/bitcoin/bitcoin/pull/33699#issuecomment-3613987461, I stumbled across another LinkingLion IP address range announced by the LionLink Networks AS I previously was unaware about:

- `199.116.84.0/24`: Riverblack, LLC (?) - [ARIN Whois](https://search.arin.net/rdap/?query=199.116.84.0)

I was running this commit [0xB10C@159b6fd](https://github.com/0xB10C/bitcoin/commit/159b6fd80d8a31c01f3b62d9194cf926c007dc37) and getting the following logs:

```
# LinkingLion seems to heavily self announce their node IPs and seems to be getting rate limited:
Rate-limited addr 199.116.84.88:8333 SELF-ANNOUNCEMENT!? from peer=7620 addr=199.116.84.88:17165 ua=/btcwire:0.5.0/Satoshi:25.0.0/ processed=0 rate-limited=550 age=798ms type=inbound
Rate-limited addr 199.116.84.173:8333 SELF-ANNOUNCEMENT!? from peer=7624 addr=199.116.84.173:15987 ua=/btcwire:0.5.0/Satoshi:25.0.0/ processed=0 rate-limited=689 age=1223ms type=inbound
Rate-limited addr 199.116.84.7:8333 SELF-ANNOUNCEMENT!? from peer=7854 addr=199.116.84.7:27880 ua=/btcwire:0.5.0/Satoshi:25.0.0/ processed=0 rate-limited=161 age=712ms type=inbound
Rate-limited addr 199.116.84.147:8333 SELF-ANNOUNCEMENT!? from peer=7873 addr=199.116.84.147:4150 ua=/btcwire:0.5.0/Satoshi:25.0.0/ processed=0 rate-limited=176 age=1090ms type=inbound
Rate-limited addr 199.116.84.185:8333 SELF-ANNOUNCEMENT!? from peer=7881 addr=199.116.84.185:20012 ua=/btcwire:0.5.0/Satoshi:25.0.0/ processed=0 rate-limited=674 age=1297ms type=inbound
Rate-limited addr 199.116.84.185:8333 SELF-ANNOUNCEMENT!? from peer=7890 addr=199.116.84.185:37238 ua=/btcwire:0.5.0/Satoshi:25.0.0/ processed=0 rate-limited=693 age=879ms type=inbound
Rate-limited addr 199.116.84.185:8333 SELF-ANNOUNCEMENT!? from peer=7958 addr=199.116.84.185:3673 ua=/btcwire:0.5.0/Satoshi:25.0.0/ processed=0 rate-limited=61 age=707ms type=inbound
Rate-limited addr 199.116.84.185:8333 SELF-ANNOUNCEMENT!? from peer=8159 addr=199.116.84.185:32178 ua=/btcwire:0.5.0/Satoshi:25.0.0/ processed=0 rate-limited=348 age=483ms type=inbound
Rate-limited addr 199.116.84.185:8333 SELF-ANNOUNCEMENT!? from peer=8396 addr=199.116.84.185:10842 ua=/btcwire:0.5.0/Satoshi:25.0.0/ processed=0 rate-limited=669 age=1342ms type=inbound
Rate-limited addr 199.116.84.185:8333 SELF-ANNOUNCEMENT!? from peer=8491 addr=199.116.84.185:34938 ua=/btcwire:0.5.0/Satoshi:25.0.0/ processed=0 rate-limited=331 age=20710ms type=inbound
Rate-limited addr 199.116.84.185:8333 SELF-ANNOUNCEMENT!? from peer=8910 addr=199.116.84.185:54696 ua=/btcwire:0.5.0/Satoshi:25.0.0/ processed=0 rate-limited=567 age=1098ms type=inbound
Rate-limited addr 199.116.84.185:8333 SELF-ANNOUNCEMENT!? from peer=8946 addr=199.116.84.185:6062 ua=/btcwire:0.5.0/Satoshi:25.0.0/ processed=0 rate-limited=605 age=1203ms type=inbound
Rate-limited addr 199.116.84.203:8333 SELF-ANNOUNCEMENT!? from peer=9049 addr=199.116.84.203:19824 ua=/btcwire:0.5.0/Satoshi:25.0.0/ processed=0 rate-limited=517 age=1240ms type=inbound
```


A custom client with the user agent `/btcwire:0.5.0/Satoshi:25.0.0/` seems to be making connections to Bitcoin nodes from the IP range 199.116.84.0/24, and seems to be sending along the IP addresses of reachable nodes such as e.g. `199.116.84.185:8333`. According to [Bitnodes](https://bitnodes.io/nodes/199.116.84.185-8333/), this node is reachable and returning a user agent of `/Satoshi:30.0.0/`.

It might be interesting to keep an eye on them here: https://bitnodes.io/nodes/?q=LIONLINK-NETWORKS%20(AS54098)

Additionally, it might be good to investigate when these came first online.

-------------------------

Crypt-iQ | 2025-12-08 15:25:32 UTC | #8

[quote="b10c, post:7, topic:12"]
A custom client with the user agent `/btcwire:0.5.0/Satoshi:25.0.0/`

[/quote]

I guess the user agent is just fake since it makes no sense. btcwire is a Go package that btcd uses, so it’s a bit weird that Satoshi appears in the user agent also.

-------------------------

b10c | 2025-12-10 15:49:34 UTC | #9

Note that all connections from the original LinkingLion IPs stopped across all of my 18 monitoring nodes on 2025-12-05 at around 11:25 UTC.

-------------------------

b10c | 2025-12-15 13:13:26 UTC | #10

I'm seeing similar connections now from IPs announced by "AS401476 - Spruce Creek Networks LLC". Will publish a full list of IPs after further investigation.

-------------------------

matthias | 2025-12-16 08:44:09 UTC | #11

I just did a quick search on one of our nodes for networks with many peers who announce a user agent that includes “breadwallet” which is a very simple heuristic for the LinkingLion behavior. The following networks were found:

143.20.137.0/24
31.58.215.0/24
87.229.79.0/24
2602:f5c0:0:ace::72:0/124

-------------------------

deadmanoz | 2025-12-18 07:46:23 UTC | #12

I don’t understand why these entities use custom user agents.

It’s pretty much inviting investigation is it not? 

What do we suppose is the motivation?

-------------------------

b10c | 2025-12-18 10:26:27 UTC | #13

I assume the user agents they use were common when they started but were never updated. They don't seem to care too much about being obvious, otherwise they wouldn't open connections again and again after they were evicted.

-------------------------

b10c | 2026-01-14 13:56:29 UTC | #14

On 2026-01-08, I observed on multiple nodes a sustained rate of address announcements to my nodes where the addresses are either a self-announcement or a subnet-announcement (the IP being announced is from the same subnet as the sender is on). I had recently implemented a metric for this in https://github.com/peer-observer/peer-observer/pull/306.


Looking at the my debug.logs show connections from LinkingLion IP addresses, all with a similar pattern:

```
[net] [net] Added connection to LINKINGLION_IP:PORT peer=12345
[msghand] [net] received: version (116 bytes) peer=12345
[msghand] [net] sending version (103 bytes) peer=12345
[msghand] [net] send version message: version 70016, blocks=MY_HEIGHT, them=LINKINGLION_IP:PORT, txrelay=1, peer=12345
[msghand] [net] sending wtxidrelay (0 bytes) peer=12345
[msghand] [net] sending sendaddrv2 (0 bytes) peer=12345
[msghand] [net] sending verack (0 bytes) peer=12345
[msghand] [net] receive version message: /btcwire:0.5.0/Satoshi:25.0.0/: version 70016, blocks=[height older than 1 month], us=127.0.0.1:8333, txrelay=1, peer=12345 peeraddr=LINKINGLION_IP:PORT
[msghand] [net] received: version (116 bytes) peer=12345
[msghand] [net] redundant version message from peer=12345
[msghand] [net] received: verack (0 bytes) peer=12345
[msghand] New inbound v1 peer connected: version: 70016, blocks=[height older than 1 month], peer=12345 peeraddr=LINKINGLION_IP:PORT
[msghand] [net] sending sendcmpct (9 bytes) peer=12345
[msghand] [net] sending ping (8 bytes) peer=12345
[msghand] [net] sending getheaders (1029 bytes) peer=12345
[msghand] [net] initial getheaders (931409) to peer=12345 (startheight:[height older than 1 month])
[msghand] [net] sending feefilter (8 bytes) peer=12345
[msghand] [net] received: addr (24003 bytes) peer=12345
[msghand] [net] Received addr: 800 addresses (0 processed, 799 rate-limited) from peer=12345
[msghand] [net] Advertising address MY_IP:MY_PORT to peer=12345
[msghand] [net] sending addr (31 bytes) peer=12345
[msghand] [net] received: pong (8 bytes) peer=12345
[net] [net] selected inbound connection for eviction, disconnecting peer=12345 peeraddr=LINKINGLION_IP:PORT
[net] [net] Resetting socket for peer=12345 peeraddr=LINKINGLION_IP:PORT
[net] [net] Cleared nodestate for peer=12345
```

All addresses were rate-limited. This is the same fake user agent as before `/btcwire:0.5.0/Satoshi:25.0.0/`.

-------------------------

stratospher | 2026-09-18 19:52:07 UTC | #15

while testing the `-v2onlyclearnet` option which doesn't allow v1 inbounds - I saw a flood of inbound connection attempt from similar looking IPs. they were all linking lion IPs. obviously banlist is better for dealing with these IPs since it won't reach net_processing. this was just for measurement purpose.
- each of these IPs waits at most ~1 second before trying again.
- claude plotted this diagram for me from 1 hour of logs. it is interesting to see how these IPs in each host rotate and still keep trying to connect to me at this ~1 second frequency.
![every_attempt_whole_window|276x500](upload://zo1d5VJXqiMK4XcmdnUtfGlnAgC.png)

-------------------------

Razor | 2026-10-08 12:30:27 UTC | #16

[quote="stratospher, post:15, topic:12"]
* each of these IPs waits at most \~1 second before trying again.

[/quote]

I also observed this behavior to one of my nodes. I did not enable \`-v2onlyclearnet\`, but I had a manual filter for the v1 connections.

https://bnoc.xyz/t/linkinglion-an-entity-linking-bitcoin-transactions-to-ips/12?u=razor

The IP doesn't match any of the subnets in this post. Additionally, I observed that the same IP was announcing different user agents across different connections to the same destination.

Here's also a plot generated by Claude. The first IP is the suspicious one:

![syn_timeline|513x500](upload://rSxCcbFwa7wLsfWQ5PhOwCfYDeB.png)

-------------------------

b10c | 2026-10-09 13:39:28 UTC | #17


[quote="Razor, post:16, topic:12"]
The IP doesn’t match any of the subnets in this post. Additionally, I observed that the same IP was announcing different user agents across different connections to the same destination.
[/quote]


The OP in this post contained only the old IPs. I've added the new IPs there too:

[quote="b10c, post:1, topic:12"]
### After 2025-12:

In late 2025, LinkingLion switched to new IP address ranges announced by “Spruce Creek Networks LLC”.

* 143.20.137.0/24
* 31.58.215.0/24
* 87.229.79.0/24
* 2602:f5c0:0:ace::/64

I’ve also seen connections from:

* 104.234.118.2
* 69.17.52.1
[/quote]

-------------------------

Razor | 2026-10-10 18:14:59 UTC | #18

[quote="b10c, post:1, topic:12"]
* 104.234.118.2

[/quote]

The spammy behaviour mentioned in my previous post came from 104.234.118.2.

-------------------------

