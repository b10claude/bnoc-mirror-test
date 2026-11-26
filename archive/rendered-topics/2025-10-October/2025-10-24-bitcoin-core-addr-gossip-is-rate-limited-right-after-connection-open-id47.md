# Bitcoin Core addr gossip is rate-limited right after connection open

b10c | 2025-10-24 17:00:43 UTC | #1

On my peer-observer monitoring, I have a dashboard with the number of connected peers that have at least one address rate-limited. For each node (ignoring hazel and mike with different configurations), it shows a few peers that have been rate-limited.

![image|690x248](upload://h4Uf6ONdLLCJ0nsclcv9z7JZWPB.png)

(see also the [public demo dashboard](https://demo.peer.observer/monitoring/d/9ba67dc0-17e5-4333-9b18-10258f9cf7ba/addr-addr-rate-limited-peers?orgId=1&from=now-7d&to=now&timezone=utc))

Looking into this, I it seems like this mostly happens right after the connection is established as the peer doesn't have enough tokens. The following log snippet contains
an example:

```
04:12:02 [net] Added connection to [redacted] peer=1234
...
04:12:03 [net] Received addr: 1 addresses (1 processed, 0 rate-limited) from peer=1234
04:12:34 [net] Received addr: 4 addresses (3 processed, 1 rate-limited) from peer=1234
04:13:09 [net] Received addr: 2 addresses (2 processed, 0 rate-limited) from peer=1234
```

The peer starts with token=1 and uses one for its self-announcement at 04:12:03. Until the next addr message arrives at 04:12:34, it re-gains 3 tokens and uses them, however, the fourth address in this addr message is rate-limited. At 04:13:09, the peer has token=3 and uses 2.

-------------------------

b10c | 2025-10-24 17:04:32 UTC | #2

Analyzing logs by sampling from multiple nodes over a time-span of 3 days, it becomes visible that starting with 5 tokens (red step line) rather than 1 token (black step line) and keeping the same rate of 1 new token every 10 seconds would help to drastically reduce false-positives.
 
![image|690x493](upload://kJBcNISX0uvszFR8fer4WLoHJxe.jpeg)

-------------------------

b10c | 2025-10-24 17:11:19 UTC | #3

Opened https://github.com/bitcoin/bitcoin/pull/33699 to give peers 5 tokens at connection start.

-------------------------

b10c | 2025-10-27 14:10:45 UTC | #4

I also looked at the distribution of entry counts in addr messages for this PR:

![image|690x491](upload://9ldNEtGa5Wa1nwih6E6VgKBYxut.png)

-------------------------

b10c | 2025-10-27 15:11:20 UTC | #5

Also looked at the interval in which we receive addresses.



![image|690x490](upload://7HF7i5y5lSyugdAcgwcNRFJCSBB.png)

https://github.com/bitcoin/bitcoin/blob/9bd9ec00b2380367d81399f4825352f66dde8a14/src/net_processing.cpp#L157-L158

https://github.com/bitcoin/bitcoin/blob/9bd9ec00b2380367d81399f4825352f66dde8a14/src/net_processing.cpp#L5326

-------------------------

b10c | 2025-10-27 15:32:31 UTC | #6

based on my logs, I also looked at the size of the addr entries in the context of "the chance to receive one that has more than X entries"

```
chance >= 1 entries 	 100.00%
chance >= 2 entries 	 37.62%
chance >= 3 entries 	 19.14%
chance >= 4 entries 	 10.16%
chance >= 5 entries 	 5.66%
chance >= 6 entries 	 3.28%
chance >= 7 entries 	 1.98%
chance >= 8 entries 	 1.25%
chance >= 9 entries 	 0.81%
chance >= 10 entries 	 0.55%
chance >= 11 entries 	 0.39%
chance >= 12 entries 	 0.28%
chance >= 13 entries 	 0.21%
chance >= 14 entries 	 0.16%
chance >= 15 entries 	 0.13%
chance >= 16 entries 	 0.11%
chance >= 17 entries 	 0.09%
chance >= 18 entries 	 0.08%
chance >= 19 entries 	 0.07%
chance >= 20 entries 	 0.07%
chance >= 21 entries 	 0.06%
chance >= 22 entries 	 0.06%
chance >= 23 entries 	 0.06%
chance >= 24 entries 	 0.06%
chance >= 25 entries 	 0.05%
chance >= 26 entries 	 0.05%
chance >= 27 entries 	 0.05%
chance >= 28 entries 	 0.05%
chance >= 29 entries 	 0.05%
```


and similarly:

```
chance == 1 entries 	 62.38062%
chance == 2 entries 	 18.48427%
chance == 3 entries 	 8.97813%
chance == 4 entries 	 4.49738%
chance == 5 entries 	 2.37816%
chance == 6 entries 	 1.29906%
chance == 7 entries 	 0.73444%
chance == 8 entries 	 0.43619%
chance == 9 entries 	 0.25935%
chance == 10 entries 	 0.16564%
chance == 11 entries 	 0.10726%
chance == 12 entries 	 0.07217%
chance == 13 entries 	 0.04713%
chance == 14 entries 	 0.03085%
chance == 15 entries 	 0.02196%
chance == 16 entries 	 0.01573%
chance == 17 entries 	 0.01028%
chance == 18 entries 	 0.00920%
chance == 19 entries 	 0.00611%
chance == 20 entries 	 0.00381%
chance == 21 entries 	 0.00284%
chance == 22 entries 	 0.00175%
chance == 23 entries 	 0.00194%
chance == 24 entries 	 0.00085%
chance == 25 entries 	 0.00079%
chance == 26 entries 	 0.00054%
chance == 27 entries 	 0.00067%
chance == 28 entries 	 0.00042%
chance == 29 entries 	 0.00018%
```

-------------------------

Crypt-iQ | 2025-12-08 15:21:57 UTC | #7

I’m curious about two things in this graph:

* why would an entry get rate-limited with 999 entries? Buggy peer? Why would we be receiving 833, 995, 998, or 999 entries in a single message instead of just 1,000 every time?
* Also, I’d expect more than 497 instances of 1,000 entries in ADDR especially when you compare that with the \~1M instances of 1 entry. Especially since we should receive 1,000-entry ADDR message per outbound connection?

> Also looked at the interval in which we receive addresses.

I think this is because the exponential timer does not have a cap, so it is possible (but unlikely) for the timer to be way past the 30s mark. I’m wondering if there should be cap for this. There are other places where \`rand_exp_duration\` is used:

* feelers (avg: 2min)
* extra-block-relay peer (avg: 5min)
* extra-network peer (avg: 5min)
* local address broadcast (avg: 24h!)
* fee filter (avg: 10min)

The feefilter one could be an issue sometimes if fees are rising or falling and the next broadcast is like an hour (or more) into the future?

-------------------------

mzumsande | 2025-12-08 17:26:13 UTC | #8

[quote="Crypt-iQ, post:7, topic:47"]
Also, I’d expect more than 497 instances of 1,000 entries in ADDR especially when you compare that with the \~1M instances of 1 entry. Especially since we should receive 1,000-entry ADDR message per outbound connection?

[/quote]

This isn’t so unexpected to me. ADDR messages with 1 entry are typically gossip relay of someone’s self-announcement (not necessarily originating from the peer itself), and both inbound and outbound peers can send gossip ADDRs every 30s ( AVG_ADDRESS_BROADCAST_INTERVAL) - we receive a GETADDR answer only once in the lifetime of a connection, and that only with a full outbound peer.  Since we don’t make so many new full outbound connections once we have found a stable set of peers (some exceptions such as stale-tip extra outbound every now and then exist) a much higher number of gossip ADDRS makes sense to me.

-------------------------

