# ViaBTC bitpeers sending the same `block` message multiple times during forks

b10c | 2026-09-24 18:34:29 UTC | #1

Just a network observations I wanted to write down. Nothing problematic.

--- 

While looking into peers sending us the same block multiple times in a short time-frame, I came across this interaction with a peer:

```
2026-04-20T17:57:23.83Z [msghand] [net] SendMessages: sending header 000000000000000000009143bbce4fcf339db8f66a9d742989db608d3d24e40c to peer=1389928
2026-04-20T17:57:23.83Z [msghand] [net] sending headers (82 bytes) peer=1389928
2026-04-20T17:57:27.24Z [msghand] [net] received: block (1606307 bytes) peer=1389928
2026-04-20T17:57:27.30Z [msghand] [net] received block 000000000000000000009143bbce4fcf339db8f66a9d742989db608d3d24e40c peer=1389928
2026-04-20T17:57:27.69Z [msghand] [net] received: block (1606311 bytes) peer=1389928
2026-04-20T17:57:27.76Z [msghand] [net] received block 00000000000000000001d8438112e755297f50dff74b262a6da94c9d2337d422 peer=1389928
2026-04-20T17:57:27.92Z [msghand] [net] received: headers (82 bytes) peer=1389928
2026-04-20T17:57:27.92Z [msghand] [net] received: block (1606307 bytes) peer=1389928
2026-04-20T17:57:28.01Z [msghand] [net] received block 000000000000000000009143bbce4fcf339db8f66a9d742989db608d3d24e40c peer=1389928
2026-04-20T17:57:28.60Z [msghand] [net] received: block (1606311 bytes) peer=1389928
2026-04-20T17:57:28.66Z [msghand] [net] received block 00000000000000000001d8438112e755297f50dff74b262a6da94c9d2337d422 peer=1389928
2026-04-20T17:57:28.71Z [msghand] [net] received: headers (82 bytes) peer=1389928
2026-04-20T17:57:32.81Z [msghand] [net] received: block (1606307 bytes) peer=1389928
2026-04-20T17:57:32.87Z [msghand] [net] received block 000000000000000000009143bbce4fcf339db8f66a9d742989db608d3d24e40c peer=1389928
2026-04-20T17:57:33.72Z [msghand] [net] received: headers (82 bytes) peer=1389928
```

While [`000000000000000000009143bbce4fcf339db8f66a9d742989db608d3d24e40c`](https://mempool.space/block/000000000000000000009143bbce4fcf339db8f66a9d742989db608d3d24e40c) is the main-chain block 945952 mined by ViaBTC, block `00000000000000000001d8438112e755297f50dff74b262a6da94c9d2337d422` is a [stale block](https://github.com/bitcoin-data/stale-blocks/blob/705b1c915f9484367e93c811b7e3f9f040ca5a0c/stale-blocks.csv#L32) at the same height mined by ViaBTC too.

The interesting part here is that they sent the winning block first at `17:57:27.30`, then the loosing block at `17:57:27.76` (`+460ms`), then the winning block again at `17:57:28.01` (`+250ms`), then the loosing block at `17:57:28.01` (`+650ms`) and finally the winning block again at `17:57:28.66` (`+4310ms`). 

This peer connected to us with `/Satoshi:0.19.0.1/`, `blocks=0`, `txrelay=0` (they don't want to hear about transactions from us), `version=70015` from an AWS IP. We've seen these before and know they ViaBTC's bitpeer clients. These announce the ViaBTC blocks to the network and give new blocks they learn about to the mining pool.

We ran into them in https://bitcoincore.org/en/2024/11/05/cb-stall-hindering-propagation/ and https://b10c.me/blog/012-viabtc-spv-vulnerability-disclosure/ before.

-------------------------

b10c | 2026-09-24 18:33:56 UTC | #2

Interestingly, https://stratum.work/height/945952 never saw this fork and does not have data on anyone mining on the other block:

![image|690x437](upload://5CqLHrXDWQtO8P6YNutHHtXKmbe.png)

-------------------------

sudocarlos | 2026-09-27 00:49:36 UTC | #3

[quote="b10c, post:1, topic:178"]
and https://b10c.me/blog/012-viabtc-spv-vulnerability-disclosure/ before
[/quote]

I don't remember seeing anything about this. Pretty wild. Good work and nice write up

-------------------------

