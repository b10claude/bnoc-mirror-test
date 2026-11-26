# What Bitcoin research papers to reimplement and validate?

b10c | 2026-10-21 13:48:31 UTC | #1

The Chaincode Labs [Bitcoin Open Source Software (BOSS) challenge](https://bosschallenge.xyz/) is considering to have participants revisit, re-implement, and validate existing research papers (using LLMs) as part of their exercises. If you know about a paper or written one yourself that you want people to consider, feel free to post it below.

-------------------------

b10c | 2026-10-21 13:54:24 UTC | #2

[CoinScope: Discovering Bitcoin’s Public Topology and Influential Nodes](https://www.cs.umd.edu/projects/coinscope/coinscope.pdf) by Andrew Miller et al.

> The Bitcoin network relies on peer-to-peer broadcast to distribute pending transactions and confirmed blocks. The topology over which this broadcast is distributed affects which nodes have advantages and whether some attacks are feasible. As such, it is particularly important to understand not just which nodes participate in the Bitcoin network, but how they are connected. In this paper, we introduce AddressProbe, a technique that discovers peer-to-peer links in Bitcoin, and apply this to the live topology. To support AddressProbe and other tools, we develop CoinScope, an infrastructure to manage short, but large-scale experiments in Bitcoin. We analyze the measured topology to discover both high-degree nodes and a well connected giant component. Yet, efficient propagation over the Bitcoin backbone does not necessarily result in a transaction being accepted into the block chain. We introduce a “decloaking” method to find influential nodes in the topology that are well connected to a mining pool. Our results find that in contrast to Bitcoin’s idealized vision of spreading mining responsibility to each node, mining pools are prevalent and hidden: roughly 2% of the (influential) nodes represent three quarters of the mining power.


[TxProbe: Discovering Bitcoin's Network Topology Using Orphan Transactions](https://arxiv.org/abs/1812.00942) by Sergi Delgado et al. 

> Bitcoin relies on a peer-to-peer overlay network to broadcast transactions and blocks. From the viewpoint of network measurement, we would like to observe this topology so we can characterize its performance, fairness and robustness. However, this is difficult because Bitcoin is deliberately designed to hide its topology from onlookers. Knowledge of the topology is not in itself a vulnerability, although it could conceivably help an attacker performing targeted eclipse attacks or to deanonymize transaction senders.
In this paper we present TxProbe, a novel technique for reconstructing the Bitcoin network topology. TxProbe makes use of peculiarities in how Bitcoin processes out of order, or "orphaned" transactions. We conducted experiments on Bitcoin testnet that suggest our technique reconstructs topology with precision and recall surpassing 90%. We also used TxProbe to take a snapshot of the Bitcoin testnet in just a few hours. TxProbe may be useful for future measurement campaigns of Bitcoin or other cryptocurrency networks.

-------------------------

b10c | 2026-10-28 20:54:10 UTC | #3

https://arxiv.org/abs/1805.11060

> Recent work has demonstrated significant anonymity vulnerabilities in Bitcoin's networking stack. In particular, the current mechanism for broadcasting Bitcoin transactions allows third-party observers to link transactions to the IP addresses that originated them. This lays the groundwork for low-cost, large-scale deanonymization attacks. In this work, we present Dandelion++, a first-principles defense against large-scale deanonymization attacks with near-optimal information-theoretic guarantees. Dandelion++ builds upon a recent proposal called Dandelion that exhibited similar goals. However, in this paper, we highlight simplifying assumptions made in Dandelion, and show how they can lead to serious deanonymization attacks when violated. In contrast, Dandelion++ defends against stronger adversaries that are allowed to disobey protocol. Dandelion++ is lightweight, scalable, and completely interoperable with the existing Bitcoin network. We evaluate it through experiments on Bitcoin's mainnet (i.e., the live Bitcoin network) to demonstrate its interoperability and low broadcast latency overhead. 

There was an implementation attempt in https://github.com/bitcoin/bitcoin/pull/13947. When I asked an LLM to summarize why this implementation attempt failed, it spit out this:

> PR #13947 failed mainly because no one found a safe way to handle the hard cases. MarcoFalke opened it in August 2018 as a three-step implementation of BIP 156 (Dandelion transaction relay), and early on he noted it was completely untested and still needed tests and wallet integration. The core design problem surfaced right away. sipa pointed out there was no “stempool,” so Dandelion transactions that depend on other Dandelion transactions would fail mempool acceptance. sdaftuar added that the right behavior for transaction chains and replacement transactions was still unresolved, along with how to prevent DoS attacks during stem routing. He also argued that one shared stempool could leak routing information to an attacker, while a separate stempool per inbound peer would be costly. Reviewers also flagged smaller issues: sending transactions directly instead of queuing them could fill send buffers and delay block relay, and the commits lacked documentation that tied the code to the BIP, which made a privacy-critical change hard to verify. The PR was dropped from the 0.18.0 milestone in December 2018 and closed in July 2019. In closing it, MarcoFalke explained that supporting all wallet behavior (such as CPFP and RBF) without opening DoS vectors was non-trivial, and suggested a simpler “Dandelion one-hop” approach as a better first step. Years later, ajtowns also found that the code roughly doubled the chance of the next node “fluffing” a transaction (about 19% instead of 10%).

-------------------------

ajtowns | 2026-10-31 16:28:24 UTC | #4

[quote="b10c, post:3, topic:196"]
Years later, ajtowns also found that the code roughly doubled the chance of the next node “fluffing” a transaction (about 19% instead of 10%).
[/quote]

I did some design work on what I think is an implementable approach for this: basically put transactions from inbounds into a stempool, and transactions from outbounds into the mempool; for mempool relay immediately to everyone as now; for stempool have a delay queue: at random intervals, relay to each outbound, then once you've relayed to each outbound, add to mempool and relay to any/all inbounds (triggering the global fluff step, more or less).

Would be good to have a theoretical analysis / simulation of that approach (the delay intervals vs number of outbounds changes the effectiveness, eg) before going further on implementation stuff, which is still tricky.

-------------------------

matthias | 2026-11-04 08:29:51 UTC | #5

[Short Paper: An Empirical Analysis of Blockchain Forks in Bitcoin](https://www.dsn.kastel.kit.edu/bitcoin/forks/) by Till Neudecker and Hannes Hartenstein

> Temporary blockchain forks are part of the regular consensus process in permissionless blockchains such as Bitcoin. As forks can be caused by numerous factors such as latency and miner behavior, their analysis provides insights into these factors, which are otherwise unknown. In this paper we provide an empirical analysis of the announcement and propagation of blocks that led to forks of the Bitcoin blockchain. By analyzing the time differences in the publication of competing blocks, we show that the block propagation delay between miners can be of similar order as the block propagation delay of the average Bitcoin peer. Furthermore, we show that the probability of a block to become part of the main chain increases roughly linearly in the time the block has been published before the competing block. Additionally, we show that the observed frequency of short block intervals between two consecutive blocks mined by the same miner after a fork is conspicuously large. While selfish mining can be a cause for this observation, other causes are also possible. Finally, we show that not only the time difference of the publication of competing blocks but also their propagation speeds vary greatly.

-------------------------

deadmanoz | 2026-11-09 13:16:13 UTC | #6

Not a paper, nor a specific idea, but I think there's probably a lot of work of https://organofcorti.blogspot.com/ that could be revived and modernised 10 years later.

I'll update this post if there is anything in particular that stands out to me, though it might be part of the exercise for participants to find something of interest or relevance amongst the content.

-------------------------

deadmanoz | 2026-11-09 13:30:26 UTC | #7

It has also been a goal of mine since earlier this year to empirically test the "stale block disproportionally impacts smaller miners than large miners" theoretical finding (https://delvingbitcoin.org/t/propagation-delay-and-mining-centralization-modeling-stale-rates/2110), but I would be happy to have a BOSS participant pick this up as I can't see myself prioritising this work before the BOSS program for 2027 starts (and completes).

I think the [stale-blocks](https://github.com/bitcoin-data/stale-blocks) dataset is now suitable for this purpose (we have increased it from just over 1000 stales to just over 4000 stales in ~6 months), I am working on improving the [mining-pools](https://github.com/bitcoin-data/mining-pools) dataset as a background task and expect to have this largely finalised before BOSS starts in January.

-------------------------

edilmedeiros | 2026-11-09 22:35:51 UTC | #8

In the context of https://github.com/bitcoin/bitcoin/pull/35558 , I think https://doi.org/10.1007/s11227-024-06468-0 would be a great addition to the mix since the proposed heuristic is identical to what the PR implements.

A comparison to https://onlinelibrary.wiley.com/doi/10.1002/nem.2262 would be even nicer to have. This paper proposes to prefill the most recent txs that entered the node's mempool instead of using the txs we requested in the last reconstruction. The paper is behind a paywall but I'm happy to share it privately if someone is willing to tackle this.

Both papers claim their techniques reduce compact block relay round trips, but there's not a clear comparison between the two approaches. I would go further and suggest there could be some regimes where the former is better and others where the later is better. Confirming (or refuting) that could be even publishable, which I would be happy to collaborate too.

https://ieeexplore.ieee.org/document/9849006 might have some interesting methodological work, even though it analyzes block relay in Bitcoin Unlimited (Bitcoin Cash implementation). They have a set reconciliation protocol called Graphene Protocol \[1,2\] that feels something that is being discussed recently in the Bitcoin community.

\[1\] A. P. Ozisik, G. Andresen, G. Bissias, A. Houmansadr, and B. Levine,  “Graphene: A new protocol for block propagation using set reconciliation,” in Data Privacy Management, Cryptocurrencies and Blockchain Technology, J. Garcia-Alfaro, G. Navarro-Arribas, H. Hartenstein, and J. Herrera-Joancomartí, Eds. Cham, Switzerland: Springer Int., 2017, pp. 420–428. 
\[2\] A. P. Ozisik, G. Andresen, B. N. Levine, D. Tapp, G. Bissias, and  S. Katkuri, “Graphene: Efficient interactive set reconciliation applied to blockchain propagation,” in Proc. ACM Spec. Interest Group Data Commun., New York, NY, USA, 2019, pp. 303–317.

-------------------------

edilmedeiros | 2026-11-09 22:48:20 UTC | #9

Another idea, which is more (crazy) experimentation than work reproduction.

https://arxiv.org/abs/1906.12140v1 presents a sharding technique called Secure fountain codes for distributing the historical block storage. Main potential benefit could be making pruned nodes useful for contributing to IBD of new nodes. There is an implementation using btcd and considerable pushbacks reported in https://delvingbitcoin.org/t/fountain-codes-a-way-to-reduce-blockchain-storage-costs/2624.

The experimentation idea would be: in the context of a quantum upgrade, if we have to put big signatures on the blockchain, we could think about pruning the witnesses and sharding them using fountain codes. That way, nodes could use some form of assumevalid for IBD without downloading the witnesses. Not sure this is straightforward in the current state of the protocol because of the wtxid computation but maybe could be done in a pq upgrade.

-------------------------

edilmedeiros | 2026-11-11 03:19:22 UTC | #10

I would like to see some work on evaluating transaction clustering based on network traffic, even though this line of research feels quite weak based on the papers I have seem so far. 

Main starting point would be [Transaction Clustering Using Network Traffic Analysis for Bitcoin and Derived Blockchains](https://ieeexplore.ieee.org/document/8845213/) (I can provide full text). The paper has several limitations (small sample on testnet where the authors controlled a relevant part of the txs origins, data collected is not well described) but they claim using Tor would not help mitigate. That's where the methodology might inspire something more realistic and useful because of related PRs and issues in Bitcoin Core:

* https://github.com/bitcoin/bitcoin/pull/29415 (merged)
* https://github.com/bitcoin/bitcoin/pull/35252 (closed)
* https://github.com/bitcoin/bitcoin/pull/36330 (draft)
* https://github.com/bitcoin/bitcoin/issues/36403 (high level discussion)

Other references:

https://ieeexplore.ieee.org/document/11172744

https://arxiv.org/abs/1410.6079

Maybe Yuval (nothingmuch) or the guys on [crocs muni](https://crocs.fi.muni.cz/) may have more insights about this.

-------------------------

deadmanoz | 2026-11-12 01:39:47 UTC | #11

Again not a paper, but I think it would be useful for a participant to survey and understand the various tools and approaches that are used to simulate the Bitcoin network, so there is a "go-to" resource for people wanting to simulate the network for whatever purpose? From the smaller size, something like [warnet](https://github.com/bitcoin-dev-project/warnet), up to simulating 10's or 100's of thousands of nodes.

-------------------------

b10c | 2026-11-12 03:37:22 UTC | #12

[quote="deadmanoz, post:11, topic:196"]
From the smaller size, something like [warnet](https://github.com/bitcoin-dev-project/warnet), up to simulating 10’s or 100’s of thousands of nodes.
[/quote]

I've worked on something that supports 10k-100k "nodes" recently to learn about address and block relay. Plan to post it to delving in a bit. There's warnet, which runs a full node (using a real binary) and does real TCP transport, and there's something like @mzumsande's agent-based [addrrelay_sim](https://github.com/mzumsande/addrrelay_sim) in Python, which does not use real Bitcoin Core source code, but implements the relay rules. Mine is somewhere between these. It's based on Bitcoin Core source code, but does not run a full node and doesn't do TCP connections by just passing around messages between different Bitcoin Core network managers.

-------------------------

CedArctic | 2026-11-14 02:10:19 UTC | #13

[quote="deadmanoz, post:11, topic:196"]
it would be useful for a participant to survey and understand the various tools and approaches that are used to simulate the Bitcoin network

[/quote]

[quote="b10c, post:12, topic:196"]
based on Bitcoin Core source code, but does not run a full node and doesn’t do TCP connections

[/quote]

This reminded me of the Shadow simulator. It used to support Core, but then fell out of maintenance.

Shadow: https://shadow.github.io/

The Shadow Bitcoin paper: https://www.robgjansen.com/publications/shadowbitcoin-cset2015.pdf

Bitcoin plugin for Shadow: https://github.com/shadow/shadow-plugin-bitcoin

-------------------------

edilmedeiros | 2026-11-16 14:40:30 UTC | #14

[quote="b10c, post:12, topic:196"]
I’ve worked on something that supports 10k-100k “nodes” recently to learn about address and block relay.

[/quote]

Playing with [ns-3](https://www.nsnam.org/) is in my list for a long time, it's one of the standard tool in academia for network simulation. I should put some clankers to good use…

-------------------------

