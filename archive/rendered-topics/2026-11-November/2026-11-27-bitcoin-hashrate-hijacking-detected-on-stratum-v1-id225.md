# Bitcoin Hashrate Hijacking Detected on Stratum V1

b10c | 2026-11-27 15:43:04 UTC | #1

I found this to be a good observation from Braiins:

> In November, an attacker rerouted internet traffic to redirect bitcoin miners on unencrypted Stratum V1 connections to an imposter pool. In November, an attacker rerouted internet traffic to redirect bitcoin miners on unencrypted Stratum V1 connections to an imposter pool. 

https://braiins.com/blog/bitcoin-hashrate-hijacking-unencrypted-stratum-v1

-------------------------

b10c | 2026-11-27 15:50:09 UTC | #2

This made me think about ways to detect something like this happening with a monitoring tool. Two rough approaches that came to mind (but I haven't thought about this in detail): 

- run tools like https://stratum.work or [https://github.com/0xB10C/stratum-observer](https://github.com/0xB10C/stratum-observer) from different ISPs/locations and try to detect disconnects and reconnects where something switches
- monitor BGP attacks more closely and try to find the ones that are relevant for Bitcoin and Bitcoin mining. I think @CedArctic has been thinking about this more.

-------------------------

