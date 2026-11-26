# Addrman age distribution

stratospher | 2026-05-21 10:23:35 UTC | #1

was curious about the age distribution of different addresses in the addrman new and tried tables of different peers in [peer.observer](https://peer.observer/)

![age_stacked_bars|690x274, 100%](upload://wfIIymBz7QXh0wOCt9Y67D3Azbu.png)
 *image plotted by claude

kane is the tor/i2p only node. kane's plot is interesting - all nodes except kane have fresher new table (more recent timestamps) and staler/older tried table. ~~so maybe kane hasn't been receiving fresh ADDR gossip but is still actively connecting to peers which keeps tried table fresh?~~

also compared alice's current addrman with a few older snapshots I had (last week, nov 2025, aug and sep 2024). it's interesting that the older snapshots had lots more 2 week - 1 month old addresses in the new table compared to the recent snapshots.

I did cross-check claude's script that it was computing the buckets (<1h, 1-6h, 6-24h, .. etc..) correctly from each snapshot's own reference time - basically the newest entry in the addrman is chosen as the reference. 

![age_alice_over_time|690x225](upload://tcqYzNX25PP2F6Oxxt2y3cB7yuj.png)
 *this also plotted by claude

-------------------------

stratospher | 2026-05-21 04:31:11 UTC | #2

[quote="stratospher, post:1, topic:130"]
so maybe kane hasn’t been receiving fresh ADDR gossip but is still actively connecting to peers which keeps tried table fresh?
[/quote]

sorry, this was incorrect. it's expected behaviour in tor/i2p-only node's addrman that tor addresses can at max occupy 1/4th new table and i2p addresses another 1/4th. so that's why we're seeing only 1/2 the new table being fresh.

if we do the netgroup calculation - tor/i2p addresses have only 16 possible netgroups and only 256 buckets possible in new table (256/1024 = 1/4 new table occupied). see [this writeup](https://github.com/stratospher/blogosphere/blob/main/netgroups.md#bucketing-algorithm-in-addrman) in case anyone's interested.

-------------------------

b10c | 2026-05-21 09:46:40 UTC | #3

[quote="stratospher, post:1, topic:130"]
also compared alice’s current addrman with a few older snapshots I had (last week, nov 2025, aug and sep 2024). it’s interesting that the older snapshots had lots more 2 week - 1 month old addresses in the new table compared to the recent snapshots.
[/quote]

I think this might be related to the current address flooding happening on the network.

https://bnoc.xyz/t/python-bitcoinlib-0-12-2-client-getting-addr-ratelimited-since-2026-04-10/116

 My observation there was:

[quote="b10c, post:3, topic:116"]
At [date=2026-04-13 time=13:47:00 timezone=Etc/Universal] I received a `addr` message with exactly 10 entries. All timestamps were recent (not older than 10min). The IPs seemed reasonable from locations where real nodes could be hosted / run from, the ports were mostly 8333, and the services seemed to be reasonable ones too.
[/quote]

This is likely updating the timestamps in our tables.

-------------------------

