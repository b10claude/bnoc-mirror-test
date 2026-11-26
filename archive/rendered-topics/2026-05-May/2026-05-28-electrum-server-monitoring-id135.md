# Electrum Server Monitoring

dutenrapha | 2026-11-23 19:07:20 UTC | #1

Recently, I started working on the following research idea proposed by b10c: [Research and exploration: Can we spot public spy-Electrum servers run by Chainalysis?](https://github.com/0xB10C/project-ideas/issues/11)

Based on the ideas from b10c, I started collecting data from public Electrum servers listed on:
[https://1209k.com/bitcoin-eye/ele.php?chain=btc](https://1209k.com/bitcoin-eye/ele.php?chain=btc)

Since this is still a first version, I did not include Tor servers yet.

For now, I am only collecting the mempool fee histogram using the `mempool.get_fee_histogram` Electrum protocol method:
[https://electrum-protocol.readthedocs.io/en/latest/protocol-methods.html#mempool-get-fee-histogram](https://electrum-protocol.readthedocs.io/en/latest/protocol-methods.html#mempool-get-fee-histogram)

My initial hypothesis is that a cheap way to structure spy Electrum servers would be to connect multiple Electrum servers to the same Bitcoin node. If that is the case, one possible suspicious behavior would be different servers exposing identical fee histograms, since they would share the same mempool source.

In this first version, out of 96 registered Electrum servers, 59 responded successfully. I implemented continuous collection every 5 minutes.

To compare histograms, I used Jensen-Shannon Divergence (JSD), which measures the similarity between probability distributions:
[https://en.wikipedia.org/wiki/Jensen%E2%80%93Shannon_divergence](https://en.wikipedia.org/wiki/Jensen%E2%80%93Shannon_divergence)

Lower values indicate more similar distributions:

* JSD = 0 means the distributions are identical

* Values closer to 1 indicate more distinct distributions

Figure below shows a matrix comparing all servers against each other at a specific moment in time.

![image|547x500](upload://igEihyAl0EplAMV1oFjGV9uXc21.png)

Initially, I expected to observe most pairs with high divergence values (closer to 1). However, the opposite happened. Most server pairs had JSD = 0, meaning their fee histograms were identical.

To better understand this behavior, I used JSD as a clustering metric. Using a simple rule where servers with JSD <= 0.5 are considered connected, I generated 5 clusters.

Cluster 1 is particularly interesting because it appears to group servers from apparently unrelated organizations and operators.

```
# Cluster 1

0    0xrpc.io:50002/ssl    0
1    167.235.9.82:50001/tcp    0
2    213.199.52.222:50001/tcp    0
3    78.46.102.70:40001/tcp    0
4    83.113.125.244:51001/tcp    0
5    87.63.200.138:60001/tcp    0
6    bitcoin.aranguren.org:50001/tcp    0
7    bitcoin.grey.pw:50002/ssl    0
8    bitcoin.stackwallet.com:50002/ssl    0
9    bolt.schulzemic.net:50001/tcp    0
10    btc.electroncash.dk:60001/tcp    0
11    clownshow.fiatfaucet.com:50002/ssl    0
12    d762li0k0g.d.firewalla.org:50001/tcp    0
13    e.keff.org:50002/ssl    0
14    e2.keff.org:50002/ssl    0
15    electrum.direwolfm14.com:50001/tcp    0
16    electrum.jhoenicke.de:50002/ssl    0
17    electrum.loyce.club:50001/tcp    0
18    electrum.tjader.xyz:50002/ssl    0
19    es.keff.org:50002/ssl    0
20    f.keff.org:50002/ssl    0
21    fakenews.fiatfaucet.com:50002/ssl    0
22    fulcrum.bullbitcoin.com:50002/ssl    0
23    fulcrum.cryptohouse.ddns.net:51001/tcp    0
24    fulcrum.grey.pw:51002/ssl    0
25    fulcrumserver.mywire.org:50001/tcp    0
26    kittyserver.ddnsfree.com:50001/tcp    0
27    mainnet-0.foundation.xyz:50001/tcp    0
28    mainnet-0.foundation.xyz:50002/ssl    0
29    mempool.8333.mobi:50001/tcp    0
30    mempool.8333.mobi:50002/ssl    0
31    smmalis37.ddns.net:50001/tcp    0
32    sornas.familyds.net:50001/tcp    0
33    unholy.fiatfaucet.com:50002/ssl    0
```
```
# Cluster 2

34    168.119.136.176:50001/tcp    1
35    18.195.224.155:50001/tcp    1
36    2ex.digitaleveryware.com:50001/tcp    1
37    blackie.c3-soft.com:57001/tcp    1
38    blackie.c3-soft.com:57002/ssl    1
39    blockitall.us:50001/tcp    1
40    blockitall.us:50002/ssl    1
41    det.electrum.blockitall.us:50001/tcp    1
42    det.electrum.blockitall.us:50002/ssl    1
43    electrum.legalise.it:50001/tcp    1
44    electrum.legalise.it:50002/ssl    1
45    electrum.petrkr.net:50002/ssl    1
46    mail.legalise.it:50001/tcp    1
47    mail.legalise.it:50002/ssl    1
48    molten.tranquille.cc:50001/tcp    1
49    molten.tranquille.cc:50002/ssl    1
50    tool.sh:50001/tcp    1
```
```
# Cluster 3

51    23.155.96.131:50001/tcp    2
52    blockstream.info:110/tcp    2
53    blockstream.info:700/ssl    2
54    electrum.blockstream.info:50001/tcp    2
55    electrum.blockstream.info:50002/ssl    2
```
```
# Cluster 4

56    btc.ocf.sh:50001/tcp    
```
```
# Cluster 5
57    electrum.bullbitcoin.com:50002/ssl    4
58    wes.bullbitcoin.com:50002/ssl    4
```

These clusters have remained stable since the beginning of the collection. Sampling different timestamps shows that many of these servers continue exposing identical histograms over time.

This is obviously not evidence of a Sybil or surveillance infrastructure by itself, but it is still a curious result.

Right now, I am investigating how different Electrum server implementations generate the `get_fee_histogram` response. The protocol documentation does not clearly specify how histogram bins should be constructed, so what I am observing may simply be an implementation artifact.

As the next step, I plan to incorporate additional metrics suggested by b10c in the original research idea and verify whether these clusters remain stable across multiple independent signals.

-------------------------

b10c | 2026-05-29 22:44:23 UTC | #2

Welcome and thanks for posting! I agree that looking at other metrics would be interesting. Also, if you find out, feel free to post here about the differences in `get_fee_histogram` responses.

-------------------------

edilmedeiros | 2026-05-30 16:46:26 UTC | #3

We talked about this in person, but checking the servers some wallets point to in recent releases would also be a nice add to the pool of data.

-------------------------

b10c | 2026-06-02 14:40:46 UTC | #4

Good idea. I know Sparrow Wallet maintains a hand-picked list of Electrum servers. I think the Electrum client does not.


https://github.com/sparrowwallet/sparrow/blob/d5b119e338151adc7942ba3aadaf733ea0576bc9/src/main/java/com/sparrowwallet/sparrow/net/PublicElectrumServer.java#L12-L25

-------------------------

b10c | 2026-08-25 21:44:42 UTC | #5

This is being continued in https://bnoc.xyz/t/electrum-server-monitoring-header-propagation-and-shared-infrastructure/167

-------------------------

b10c | 2026-11-23 19:43:19 UTC | #6

[quote="b10c, post:4, topic:135"]
I know Sparrow Wallet maintains a hand-picked list of Electrum servers. I think the Electrum client does not.

[/quote]

Electrum also has it's own protocol for sharing other servers. From [https://electrum.readthedocs.io/en/latest/protocol.html#server-peers-subscribe](https://electrumx.readthedocs.io/en/latest/protocol-methods.html#server-add-peer):

> server.add_peer
>
> A newly-started server uses this call to get itself into other servers’ peers lists. It should not be used by wallet clients.
> 
> server.peers.subscribe
>
> Return a list of peer servers. Despite the name this is not a subscription and the server must send no notifications.

I was able to learn about a lot of Electrum servers from this in my testing.

-------------------------

