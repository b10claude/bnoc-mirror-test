# Increased b-msghand thread utilization due to many 352 byte runestone inscriptions on 2025-11-17

b10c | 2025-11-21 15:37:36 UTC | #1

While looking at a peer-observer dashboard for time spent in the b-msghand (P2P message handling thread) of Bitcoin Core, I noticed that some of the nodes (especially dave with many connections) were active in that thread for more than 500-700ms per second (i.e 50% - 70%) on e.g. 2025-11-17.

![image|690x431](upload://iIibiaEERiw8L6Z6BI9f8QbFzpj.png)

The host frank doesn't have a mempool. Since he's not affected, this indicates this could be related to transaction relay and processing.


Looking deeper into this, it revealed many transactions getting added to the mempool at that time (>2000 on some nodes per minute) 
![image|690x429](upload://jftyHZ2BO5SZSkGQK07ywG4WjdX.png)

as well as a lot of tx/wtx INVs per minute sent to peers

![image|690x433](upload://1ZvyS3GhnLAI7llJPo7V3KBRhiS.png)

and a lot (>200k per minute) of transactions getting sent via `tx` messages.

![image|690x425](upload://kxTjKSlKeSIgdoCUnE0jU5JReS3.png)


Many of these transactions had 352 bytes. One of them is: https://mempool.space/tx/8dbb01c978ae4126339f7fb538068afbda194b65f3b1f71fca1f5833b7fbdc91

![image|690x151](upload://cuLAcuAymB2hLvq3lJPLPu003fY.png)

-------------------------

b10c | 2025-11-21 15:39:24 UTC | #2

These mass-broadcasts (probably by someone inscribing something and directly broadcasting it) are interesting as there previously was a problem with not being able to handle them well in the network. See https://bitcoincore.org/en/2024/10/08/disclose-large-inv-to-send/ and https://b10c.me/observations/15-inv-to-send-queue/

-------------------------

b10c | 2025-11-21 15:48:27 UTC | #3

In my debug.logs I noticed a lot of `sending tx (352 bytes) peer=X` and was confused at first. I interpreted this as us responding to a getdata requesting 22 transactions with sending the same 352 byte transaction 22 times. Looking at `received getdata for: wtx` shows that we only log the first wtxid being requested. These were probably all different transactions being sent, they just all happened to be 352 byte.

 https://github.com/bitcoin/bitcoin/blob/17072f70051dc086ef57880cd14e102ed346c350/src/net_processing.cpp#L4038-L4040


```
2025-11-17T13:26:17.756734Z [msghand] [net] received: getdata (793 bytes) peer=75021
2025-11-17T13:26:17.756759Z [msghand] [net] received getdata (22 invsz) peer=75021
2025-11-17T13:26:17.756780Z [msghand] [net] received getdata for: wtx 88e410c0f72f10fdfaf4f8623eee071079ccd2a12088b0a1f8ebe89c7a167b19 peer=75021
2025-11-17T13:26:17.756818Z [msghand] [net] sending tx (352 bytes) peer=75021
2025-11-17T13:26:17.756935Z [msghand] [net] sending tx (352 bytes) peer=75021
2025-11-17T13:26:17.757053Z [msghand] [net] sending tx (352 bytes) peer=75021
2025-11-17T13:26:17.757128Z [msghand] [net] sending tx (352 bytes) peer=75021
2025-11-17T13:26:17.757214Z [msghand] [net] sending tx (352 bytes) peer=75021
2025-11-17T13:26:17.757321Z [msghand] [net] sending tx (352 bytes) peer=75021
2025-11-17T13:26:17.757412Z [msghand] [net] sending tx (352 bytes) peer=75021
2025-11-17T13:26:17.757486Z [msghand] [net] sending tx (352 bytes) peer=75021
2025-11-17T13:26:17.757560Z [msghand] [net] sending tx (352 bytes) peer=75021
2025-11-17T13:26:17.757637Z [msghand] [net] sending tx (352 bytes) peer=75021
2025-11-17T13:26:17.757710Z [msghand] [net] sending tx (352 bytes) peer=75021
2025-11-17T13:26:17.757766Z [msghand] [net] sending tx (352 bytes) peer=75021
2025-11-17T13:26:17.757820Z [msghand] [net] sending tx (352 bytes) peer=75021
2025-11-17T13:26:17.757885Z [msghand] [net] sending tx (352 bytes) peer=75021
2025-11-17T13:26:17.757942Z [msghand] [net] sending tx (352 bytes) peer=75021
2025-11-17T13:26:17.758017Z [msghand] [net] sending tx (352 bytes) peer=75021
2025-11-17T13:26:17.758094Z [msghand] [net] sending tx (352 bytes) peer=75021
2025-11-17T13:26:17.758157Z [msghand] [net] sending tx (352 bytes) peer=75021
2025-11-17T13:26:17.758211Z [msghand] [net] sending tx (352 bytes) peer=75021
2025-11-17T13:26:17.758264Z [msghand] [net] sending tx (352 bytes) peer=75021
2025-11-17T13:26:17.758371Z [msghand] [net] sending tx (352 bytes) peer=75021
2025-11-17T13:26:17.758424Z [msghand] [net] sending tx (352 bytes) peer=75021
2025-11-17T13:26:17.769052Z [msghand] [net] received: getdata (469 bytes) peer=44438
```

-------------------------

Antoine | 2025-11-21 15:53:35 UTC | #4

Do you run v30? https://github.com/bitcoin/bitcoin/pull/28592 seems related.

-------------------------

ajtowns | 2025-11-22 03:15:27 UTC | #5

If you backport #33448, then tracking the value of `bitcoin-cli getpeerinfo | jq '[.[].inv_to_send] | max'` might be informative. (Normal behaviour should be less than 5k, values below 10k or 20k should still result in acceptable performance though)

-------------------------

b10c | 2025-11-26 16:15:40 UTC | #6

I did run v30, but upgraded to a recent master which includes #33448. I also [added support](https://github.com/peer-observer/peer-observer/pull/299) for the `inv_to_send` getpeerinfo field in peer-observer. 

[quote="ajtowns, post:5, topic:58"]
tracking the value of `bitcoin-cli getpeerinfo | jq '[.[].inv_to_send] | max'` might be informative
[/quote]

I've set up data collection for the max inv_to_send value and also the sum of all inv_to_send values of my peers:

![image|690x350](upload://p8yBfedJt3hGizKwKV5djltRvuL.png)

The max tells you what is in queue to e.g. a spy-peer. The sum tells you a bit more about the total load that (sorting and) sending invs has on the node across all peers.

--- 

Additionally, I've set up data collection for inv rate, size and WTx annoucement rate by having a custom measurement client the Bitcoin Core node connects to with `-addnode` (i.e. manual outbound).

The rate of WTx inventory items I receive per second is around 5tx/s or just below most of the time, but I've seen spikes to 20-22/WTx invs per second. My understanding is that this could go up to 35/txs per second since #33448 (as these are outbound connections). The purple node not sending out WTx invs at the same rate as the others during the 16:15 spike is `nico`, which is a Knots node. Likely, the spike was a inscription (or similar) broadcast, which the node rejected and didn't announce.
 
![image|690x210](upload://2SvcMll4HYFfEAVHHW7pjMP1gv9.png)

During the spikes, the inv size to my measuring client reaches 70 WTx per INV. That's also expected, as `INVENTORY_BROADCAST_TARGET` = `INVENTORY_BROADCAST_PER_SECOND * INBOUND_INVENTORY_BROADCAST_INTERVAL` = `14 * 5` = 70. I have one peer running an older (pre 33488) version, and it sends only 35 INVs per second (that's not really visible in the graph below). I haven't seen this go over 70 (i.e. be dynamic) yet on my measurement client, but since it's an outbound peer and we sent it INVs faster. I suspect it's inv-to-send queue is a lot smaller than the inv-to-send queue of an inbound spy-peer. 

https://github.com/bitcoin/bitcoin/blob/edb871cba22a658714ce97e843ff84cfe1ba9ac4/src/net_processing.cpp#L171-L172

![image|690x210](upload://zzzPvtcWlMdaZYndW3V8V8tMVIe.png)

The rate at which the measurement client receives INVs is somewhere around 0.4 to 0.45 INVs/second. `OUTBOUND_INVENTORY_BROADCAST_INTERVAL` is 2 seconds which would indicate a 0.5 INVs/second rate, but since we don't send INVs if our inv-to-send queue is empty, 0.45 INVs/second seems reasonable. 

![image|690x190](upload://cG4kJZG2vk3gKcqbYJuPSUKviK7.jpeg)

-------------------------

