# Spike in peers that consider us to be high-bandwidth BIP152 peers (2026-11-03 16 UTC)

b10c | 2026-11-06 23:03:07 UTC | #1

On the peer-observer dashboards, I observed this:

The number of nodes that tell us that they consider us to be one of their high-bandwidth BIP152 compact block relay peers spiked on two nodes (`dave` and `frank`). Both in share and count. This happened on 2026-11-03 at 16 UTC. 

![image|690x359](upload://qmkodn5KXlQ9rR8u0q2D4VKyGTs.png)

![image|690x363](upload://cLIGrHDxWp4bD5P7k6lHUbgOU5n.png)

Possibly one of these options:
- We heard about a block early and forwarded it to our other peers quite fast. This could have caused them to switch one of their three (assuming Bitcoin Core) high-bandwidth connections to us for a while.
- Or, someone is running a custom client that requests high-bandwidth compact blocks from us all the time and made a lot of connections to us.


I haven't checked my logs.

-------------------------

stratospher | 2026-11-06 23:47:12 UTC | #2

there was a fork on 11-03 at height 974400 and only dave+frank knew about it.

![fork 974400|690x357](upload://a9fpnpR47ts4f1qUBRm76a90h4f.png)

-------------------------

b10c | 2026-11-07 00:13:06 UTC | #3

Good catch! Nodes `dave` and `frank` are `valid-headers`, which means they did NOT have the stale block (Foundry) but had the winning block (F2Pool). All other nodes are `valid-fork` on the Foundry block, which means they had the losing-block (Foundry) first. They then all switched to the winning block once AntPool found 974401. `dave` and `frank` were the few nodes that could give it to the network and were then selected as high-bandwidth peers by their peers (their peers send them a `sendcmpct(1)` message.

-------------------------

