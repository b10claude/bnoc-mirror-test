# Observability tooling for P2Poolv2

jungly | 2026-04-01 09:32:50 UTC | #1

# Question

Given your experience of observing bitcoin p2p and stale rates, what tooling or extra data in p2p messages you wish bitcoin had that will give you better insights into latency, stale rates, compact block miss rates, etc?

At p2poolv2 we want to make it easier to observe the network by providing the tooling or change data included in p2p messages to make observability better without leaking information about nodes.

# Background

We are working on compact block relays for P2Poolv2 to send shares for our first version. In contrast, the original p2pool used a custom protocol that eliminated the round trips required with compact blocks to hydrate blocks with missing txs.

The original p2pool protocol maintained state on each peer connection. The state tracked which transactions the peer on the other end has definitely seen. When sending a share to a peer, the sending node checks which txs the peer has not seen, and precede the share message with `remember_tx` messages. Thus each node sends missing txs before the share.

The protocol has the downside of maintaining state, but the plus side of eliminating round trip times to fetch missing compact block transactions.

We are not sure we want to build a stateful protocol first. So we are building compact blocks for our mvp and later depending on miss rates and other observed data, debate changing the protocol.

# Rough Estimates

We are aiming for 10s share interval. Largely cause bandwidths have improved since original p2pool, we are using uncles to reward stales, plus hopefully our Rust implementation is faster than the original p2pool in python.

```
uncle_rate_increase = miss_rate × RTT / share_interval
```

Assuming median RTT of 300ms, and say 3% of transactions missing from compact blocks, we get to `uncle_rate_increase = 0.03 * 300ms / 10000ms = 0.09%`

This is a small increase, but every increase adds up. If we see miss rate more than 3%, we might have to think of something else.

---

So what can we add to p2p messages or headers to improve observability? :folded_hands:

Also, is there a compact block miss rate observation tool somewhere? I see this: https://github.com/0xB10C/fork-observer/issues/94

-------------------------

b10c | 2026-03-27 08:34:20 UTC | #2

> what tooling or extra data in p2p messages you wish bitcoin had

I'm not sure if you're asking about adding more P2P messages to the Bitcoin protocol intended for all nodes, or something specifically for p2poolv2? From reading your post, I'm unsure if p2poolv2 uses the same P2P message format as Bitcoin, but extends the implementation with more features. 

> So what can we add to p2p messages or headers to improve observability? 

There are the the proposals for a [`staleheader` messages](https://delvingbitcoin.org/t/propagation-delay-and-mining-centralization-modeling-stale-rates/2110/2?u=0xb10c) by @gmaxwell or the [`staletip` message](https://github.com/ajtowns/bips/blob/f25fa67b03fc0ebbf994aca62d96c1990da8fd9d/bip-staletip.md) proposal and [implementation](https://github.com/ajtowns/bitcoin/tree/202601-staletips-vibes) by @ajtowns that come to mind here. These would allow observing stale headers/blocks on the network.

> Also, is there a compact block miss rate observation tool somewhere? I see this: [Calculate and expose the stale block rate per network · Issue #94 · 0xB10C/fork-observer · GitHub](https://github.com/0xB10C/fork-observer/issues/94)

This fork-observer issue is more a UI thing for the page showing the number of stale blocks per e.g. 1000. This is not related to compact blocks. There are some long-term stats on https://bitcoin-data.github.io/stale-blocks/ for the stale rates over time.

I do have https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/44 for numbers on stale blocks reconstructions not needing an extra round trip. This is done by grepping my Bitcoin Core node debug logs and generating a plot from the result. There isn't much tooling too it, but I'll post the scripts there the next time I make an update (I just noticed it has been a while, so probably good to make one soonish).

Does that answer some of your questions?

-------------------------

jungly | 2026-04-01 04:11:53 UTC | #3

Thanks for pointing me to the useful links.

I had lost the link to the “stats on compact block construction”, that is the one that gives me most food for thought for p2poolv2. Even if we still reward the uncle blocks p2poov2, we still want to reduce uncles. The catch is we need to pay RTT cost to get missing transactions from compact blocks. The stats data from delving shows a much higher number of misses than I expected.

My conclusion is we need to watch this like a hawk on p2poolv2. We’ll have to have good tracing and emit tracing data to prom/grafana to watch these misses - something like on FIBRE’s new dash https://stats.bitcoinfibre.org/public-dashboards/ad821364f8044d6991e4047d527bc01e


![image|690x238](upload://6SPLUGyKSefWuU8O7qeWdsfHuHt.png)

-------------------------

