# Steep increase in inbound connections on 2026-03-31 at 00:12 UTC

b10c | 2026-04-02 11:06:43 UTC | #1

I noticed that on my monitoring nodes, nearly across the board (ignoring ones that already had full connection slots), the inbound connections steeply increased on 2026-03-31 at around 00:12 UTC ([date=2026-03-31 time=00:12:00 timezone=Etc/UTC]).

![image|565x500](upload://tNe8BZd3h8rqyojKaM9GGDGvPOQ.png)

Node `dave` has a high limit of inbound connection slots. The number of inbound connections increased from 116 at 00:12 UTC by 32 to 148 at 00:15 UTC.

As of [date=2026-04-02 time=13:00:00 timezone=Europe/Amsterdam], the connection levels are still elevated.

-------------------------

b10c | 2026-04-02 11:20:16 UTC | #2

This exactly matches the time when my 22 outbound connections across multiple nodes to bitprojects (https://bnoc.xyz/t/many-connections-to-bitproject-io-nodes/40) dropped.

![image|690x415](upload://vGOKMjGZFGREbrDaH5Pmhul34rQ.png)

Likely, all nodes on the network connected to bitprojects lost their outbound connections to bitprojects at the same time and all of them started looking for new outbounds at the same time. 

This matches with the post from @bitprojects in https://bnoc.xyz/t/many-connections-to-bitproject-io-nodes/40/24.

I guess this solves it.

-------------------------

b10c | 2026-04-02 11:31:58 UTC | #3

In total, my nodes seem to have gained around 220 IPv4 peers.

![image|567x314](upload://lTNGSOIp5GdRqIdWpoH4QTeG6EY.png)

However, I've also noticed a small increase of 15 in onion peers. I don't think bitprojects had any nodes on Tor, but some of the nodes looking for new outbounds might have picked onions to connect to.

![image|563x309](upload://7kokk7Q66fwdocR05PJYsMn8WX3.png)

Don't really notice something on the other networks. Possibly 10 new I2P peers, but there seems to be a lot of churn anyways.

-------------------------

Emzy | 2026-04-02 12:25:10 UTC | #4

Both my Mainnet nodes with "unlimited" incoming connections allowed, show an increase at the same time: (times are in CEST UTC+2)
![bitcoind_connections-pinpoint=1774745357,1775133293|690x384](upload://bdAaXXEwc9ODDIqfPXaDh5wco2z.png)
![bitcoind_connections-pinpoint=1774722593,1775122625|690x384](upload://xf7nxVxBf3T7CKNpZxNMi1mKVuc.png)

-------------------------

bitprojects | 2026-04-02 18:22:57 UTC | #5

sorry if this is a repost of the info, but I was handling 80k inbound connections right before shutdown.  There were also several times over the last few months that I needed have some traditional maintenance windows where all of my nodes were unreachable for 15-45 minutes – should all correlate.

![Screenshot_2026-03-30_15-08-41|602x500](upload://vd3zGYPp3eJHxq1asvN9XGUWTY3.png)

-------------------------

bitprojects | 2026-04-02 18:25:12 UTC | #6

[quote="b10c, post:3, topic:108"]
However, I’ve also noticed a small increase of 15 in onion peers. I don’t think bitprojects had any nodes on Tor,

[/quote]

Correct I was 100% IPv4

-------------------------

