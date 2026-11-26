# Monitoring the Bitcoin Network for Malicious Behavior (2017)

b10c | 2025-10-17 07:03:23 UTC | #1

I was recently made aware of this master thesis from 2017 which is very similar to the peer-observer idea.

https://cosicdatabase.esat.kuleuven.be/backend/publications/files/these/371

## Abstract

The decentralised peer-to-peer network architecture that caused the popularity of Bitcoin has been the subject of various studies. Several network-level attacks have either been conducted by hackers or described by academia. Although Bitcoin developers address certain of these security vulnerabilities by releasing new versions of the software, some nodes on the Bitcoin did not incorporate these updates. As a result, there are still nodes on the network running bitcoind version 0.8, while the current release of bitcoind is 0.14 as of May 2017.

This paper presents a monitoring service for Bitcoin to detect misbehaving activity and network-level attacks in an early stage. The underlying logic of our system is in line with intrusion detection systems, which monitor ongoing attacks with a twofold approach: first, we search for patterns corresponding to known network-level attacks, second, we maintain a profile based on network statistics to detect abnormal activity that deviates from the profile. In total 21 observed events were classified as abnormal for an observation period of three months. We demonstrate through deeper analysis that among the observed events, 6 of them were launched intentionally.

To the best of our knowledge, this is the first monitoring system focusing on the security of the Bitcoin network. We hope that by detecting ongoing attacks at an early stage and by publishing the findings on a public dashboard, our system can reduce the response time of attacks and discourage attackers by increasing their risk of being exposed.

-------------------------

b10c | 2025-10-14 12:37:44 UTC | #2

I have some notes in https://github.com/0xB10C/peer-observer/issues/204 that I can move here.

-------------------------

deadmanoz | 2025-10-17 06:59:21 UTC | #3

[quote="b10c, post:1, topic:28"]
https://cosicdatabase.esat.kuleuven.be/backend/publications/files/these/371
[/quote]

This research is criminally underrated - Google Scholar shows only a single citation for it!!

-------------------------

b10c | 2025-10-17 07:09:55 UTC | #4

After reading section 3.1.3 on INVBLOCK delay:

* peer-observer could track transaction and block stalling by looking at requested (GETDATA) transactions or blocks that we either don't get or that take a while to get. In general, inv-getdata and getdata-tx/block timings seem interesting to track.

![image|690x149](upload://bRFEBGT3G4I340gGqnhtGN2iWB4.png)

Tracking inv-getdata rate and getdata-tx / getdata-block rate could be interesting, too.

-------------------------

b10c | 2025-10-17 07:11:17 UTC | #5

I wasn't aware of this discussion about Chainanalysis in 2013. Might be interesting to revisit:

![image|617x500](upload://bhIGznnQiwICGPnf2rS4DaaSQ2K.png)


```
- [47] K. Torpey. Someone may be deanonymizing your bitcoin transactions. URL: http://insidebitcoins.com/news/someone-may-be-deanonymizing-your-bitcoin-transactions/30759, last checked on 13-03-2015. (archive: https://web.archive.org/web/20150711073038/http://insidebitcoins.com/news/someone-may-be-deanonymizing-your-bitcoin-transactions/30759)

- [9] G. Caffyn. Chainalysis ceo denies ’sybil attack’ on bitcoin’s network. URL: http://www.coindesk.com/chainalysis-ceo-denies-launching-sybil-attack-on-bitcoin-network/, last checked on 14-03-2015. (archive https://web.archive.org/web/20160611220409/http://www.coindesk.com/chainalysis-ceo-denies-launching-sybil-attack-on-bitcoin-network/)
```

In the same context, the paper referenced above could be interesting to revisit: 

```
A. Biryukov, D. Khovratovich, and I. Pustogarov. Deanonymisation of clients
in bitcoin p2p network. In Proceedings of the 2014 ACM SIGSAC Conference
on Computer and Communications Security, CCS ’14, pages 15–29, New York,
NY, USA, 2014. ACM.
```
https://arxiv.org/abs/1405.7418

-------------------------

b10c | 2025-10-17 07:11:39 UTC | #6

The Honeynode set up described in 4.1 is very similar to the peer-observer idea shared in https://b10c.me/projects/024-peer-observer/.

![image|690x227](upload://ebdBuADfW1uWyWuyYr1leveXBZ5.png)

-------------------------

b10c | 2025-10-17 07:12:32 UTC | #7

Section 6.1.2. shows monitoring via the Bitnodes data. We could do something similar by integrating DSN and Bitnodes data into peer-observer somehow. I found looking at number of nodes per ASN interesting, because you see quickly if one entity spins up a bunch of nodes.


![image|474x500](upload://tEEZHlTWuRfMiWCf7DgAa9noWJK.png)

-------------------------

