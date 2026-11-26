# 82.66.103.79 (v28.99) repeatedly connecting and getting discouraged for invalid POW

b10c | 2025-10-14 06:51:46 UTC | #1

In August 2025, someone reached out with the following message:

> Have you noticed 82.66.103.79 which (claims to be) 0.28.99 repeatedly connecting and getting banned for invalid POW?


I hadn't, but dug into it:


- I first saw `82.66.103.79:9333` being added to my addrman new tables around 2024-10-14
- The first connection and version message from it was received on 2024-10-16 with "blocks=9925" in the version message log
- It got disconnected after 5 minutes for "Misbehaving: peer=X: header with invalid proof of work"
- Otherwise traffic looks very similar to a real "v28.99" peer
- The number of blocks the node claims to know about in the version message has been increasing. It's now at blocks=52714, but it might have been higher in the meantime.

I wonder if it's trying to find outbound peers and is getting its connections closed due to misbehavior by everyone. Also interesting that it stayed online for this long without syncing to the tip.

This nodes block height over time:

![image|589x432](upload://lku78iTDh4n4Yzzp5ZXscd7Vh37.png)

-------------------------

b10c | 2025-10-14 06:34:08 UTC | #2

At some point later, I dug a bit more more and noticed [82.66.103.79:8332](http://82.66.103.79:8332/) exposes a Bitcoin Core like REST API. Fetching the block this node considers as genesis it reveals the following coinbase script:

```
�ÿÿ���LRAs of today, August 21th, 2024, the NewBitcoin blockchain has been launched, VFCMH
```

This is an altcoin but reusing the mainnet network magic..

-------------------------

