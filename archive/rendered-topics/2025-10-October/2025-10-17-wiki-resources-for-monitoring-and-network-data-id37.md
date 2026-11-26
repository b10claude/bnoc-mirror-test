# Wiki: Resources for monitoring and network data

deadmanoz | 2026-10-09 14:57:11 UTC | #1

A topic for various sites and datasets relating to monitoring and network data:

- https://btcnodes.io/ Node count (Similar to the old bitnodes-io)
- https://www.dsn.kastel.kit.edu/bitcoin/ KIT DSN Bitcoin Monitoring and their network snapshots
- https://blockchair.com/bitcoin/nodes Bitcoin node counts (there's also an [API](https://api.blockchair.com/bitcoin/nodes))
- https://statoshi.info/  Realtime Bitcoin Node Stats
- https://p2pobservatory.networks.imdea.org/analysis?network=bitcoin Numbers on reachable IPv4 and IPv6 nodes

-------------------------

deadmanoz | 2025-10-17 14:38:20 UTC | #4

Likely operational since [mid-2013](https://github.com/ayeowch/bitnodes/commit/bef4b3cba4c36fc4393f68aea6087d34037eeb92)..

https://bitnodes.io/

https://github.com/ayeowch/bitnodes

-------------------------

admin | 2026-08-15 11:17:34 UTC | #6

(made this a wiki post, will edit the OP at some point to be the wiki post)

-------------------------

b10c | 2026-10-09 15:13:39 UTC | #8

https://gist.github.com/m4ycon/faa8b141a501c2c5c6cc3c4e5310da3d by @m4ycon has a bunch of links that could be added here (feel free to move them here if you want, Maycon)

-------------------------

m4ycon | 2026-10-15 01:05:35 UTC | #9

This list was previously on my [gist](https://gist.github.com/m4ycon/faa8b141a501c2c5c6cc3c4e5310da3d) as a personal list, as b10c mentioned, but I think it fits better here.

Here are some links that I found while reading bitcoin related stuff, probably you'll find most of them here at BNOC.

Other resource aggregators:

* https://bitcoin-noc.github.io/map-of-bitcoin-monitoring/
* https://www.lopp.net/bitcoin-information.html

Resources:

* Alternatives to https://bitnodes.io/ while a WIP is happening
  * https://bitnod.es/
  * https://bitdis.org/
* https://census.yonson.dev/ : listening nodes and the acceptance ratio for a given feature
* [bitcoin-data](https://github.com/bitcoin-data) org hosts many Bitcoin datasets: GitHub issue and PR backups (bitcoin, bips, secp256k1, gui), network stats archives, Bitcoin Core addrman exports, stale blocks, mining pool coinbase tags and addresses, block arrival times, P2P health metrics, and many others.
* https://willcl-ark.github.io/dnsseedrs/ : detailed dashboard focused on Bitcoin DNS seeders, providing information about node distribution, classification (such as "Good Nodes"), and possible Sybil attacks, based on IP prefixes and ASNs
* https://bitcoindatalabs.github.io/bitcoin-mining-pools/#forensics : various mining-related data. E.g.: the probability of pool X mining block N+1 given that it mined block N, reported vs. actual hash rate
* https://bitcoindatalabs.org/ : data about lightning, mining, some visualizations about bitcoin ecosystem, funding, graph of contributors and their level of influence
* <https://21.ninja/> : open-source empirical data and metrics on Bitcoin's P2P network (dns seeds, reachability...)
* <https://octavio.xyz/projects/dns-monitoring/> : DNS seed monitor tracking advertised, reachable, stale and duplicate addresses per seed
* <https://dns-seed.github.io/> : health status of Bitcoin Core's DNS seeds (IPv4/IPv6 responses per seed)
* <https://demo.peer.observer/> : public demo of peer-observer, a tool for detecting attacks and anomalies on the Bitcoin P2P network
* <https://mainnet.observer/> : on-chain statistics charts covering transactions, blocks, the UTXO set and mining
* <https://fork.observer/> : chain tips from multiple nodes side by side, useful for spotting forks, stale blocks and reorgs
* <https://dune.com/murchandamus/opreturn-counts> : dashboard tracking OP_RETURN output counts over time
* <https://data.bnoc.xyz/> : BNOC shared datasets (node and mempool data, packet captures, addrman exports) (see [114](https://bnoc.xyz/t/a-bnoc-data-share/114?u=m4ycon))
* <https://dashboard.asmap.org/> : how ASmap builds change across Bitcoin Core releases (routing drift, IP/ASN coverage)
* <https://stratum.work/> : real-time view of mining pools' Stratum V1 job templates (coinbase, merkle branches, first tx)
* <https://mmm.deadmanoz.xyz/> : Merge Mining Monitor, which recovers Bitcoin stale and orphan blocks from merge-mined child chains (see [146](https://bnoc.xyz/t/introducing-the-merge-mining-monitor/146?u=m4ycon))

-------------------------

