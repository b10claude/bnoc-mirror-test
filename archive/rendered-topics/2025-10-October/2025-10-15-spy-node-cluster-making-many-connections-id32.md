# Spy node cluster making many connections

mzumsande | 2025-10-15 15:54:39 UTC | #1

During a recent IBD in August, I noticed a sudden drop from ~120 to ~100 peers.

This was due to these IPs:
```
142.93.63.225
172.233.57.109
198.244.232.117
78.47.52.58
```
I had 5 inbound connections from each of these addresses (each using a different port), and they all disconnected at the same time, so I assume they belong to the same entity.

-------------------------

b10c | 2025-10-15 15:52:11 UTC | #2

I noticed these too! I have a screenshot showing my freshly restarted nodes (they don't have full inbound peers again yet) and these nodes connecting and disconnecting at the same time to my nodes.

![image|690x171](upload://6ee6njOelOQ9O3P7a6qvTs3LFvy.png)

Also have this log line:

```
receive version message: /Satoshi:27.0.0/: version 70016, blocks=754565, us=*:8333, txrelay=0, peer=55068 peeraddr=78.47.52.58:36232, mapped_as=24940
```

And probably more data to analyze in archived debug.logs. I'll post an update here once I get to analyzing them.

-------------------------

Emzy | 2025-10-15 16:39:22 UTC | #3

My basic monitoring shows the same pattern on all of my public fullnodes.
[grid]
![bitcoind_connections-pinpoint=1754190329,1754298329|690x384](upload://tFqu8aOIROe8XPevqJvfLJFoeaK.png)
![bitcoind_connections-pinpoint=1754190629,1754298629|690x384](upload://5Bhz66hrhNtj9vWlcpEXMhSYH2X.png)
![bitcoind_connections-pinpoint=1754190629,17542986292|690x384](upload://es4DRyPCiv16uxVFFQgT5aFhM6e.png)
[/grid]

-------------------------

