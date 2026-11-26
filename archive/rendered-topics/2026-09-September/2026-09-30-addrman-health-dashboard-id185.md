# Addrman health dashboard

naiyoma | 2026-09-30 17:03:33 UTC | #1

Sharing an addrman health dashboard ( https://stratospher.github.io/addrman-dashboard/ ) which @stratospher and I vibe-coded for fun last month.

The dashboard lets you upload your addrman (`peers.dat`) and gives a quick overview of the state and composition of your addrman. The addrman is from where we select peers for outbound connections, and it’s important that we pick good and diverse peers to connect to.

Current sections include:

1. General Stats

* Address age distribution
* Network distribution
* `nRefCount` distribution
* Service flag distribution
* Tor exit IPs in your addrman (just for testing PR 35578)

2. Reachability

* Connection attempts
* Reachability according to 3rd party bitnod.es for comparison

3. `isTerrible` Stats

4. Eclipse Resistance

* Addresses on multiple ports
* Source netgroups in the tried table
* Netgroups in the full Addrman
* Source netgroups in the full Addrman

The dashboard is still experimental, and contributions, feedback, and suggestions are very welcome! Also feel absolutely free to reply in this post with any metric in the dashboard that you found interesting/standing out. Would love to hear about interesting trends in your addrman!

Github link: https://github.com/stratospher/addrman-dashboard

-------------------------

b10c | 2026-10-01 17:35:37 UTC | #2

Nice! I think this is in a way similar to what I wanted to add to addrman.observer, but never got to do in a pre-LLM world. Also directly uploading `peers.dat` files is neat and not having to have a `getrawaddrman` JSON output (this was also not something I wanted to implement by hand too).

-------------------------

b10c | 2026-10-01 19:05:42 UTC | #3

Sometimes it makes sense to have a sample peers.dat somewhere (e.g. a GitHub Gist) that can be loaded for demonstration by clicking a button. If you want, feel free to use something from https://demo.peer.observer/

-------------------------

ismaelsadeeq | 2026-10-20 05:38:18 UTC | #4

I parsed peers.dat from two of my nodes and wanted to share what stood out. Both are clearnet-only, and both snapshots were taken 2026-10-20 04:32Z. Reachability is cross-checked against the bitnod.es export from 2026-10-19.

* Alice: short-running, \[\~1 month, v31\]
* Bob: long-running, \[\~6months, v31\]

| Metric | Alice | Bob |
|----|----|----|
| New / tried fill | 100% / 8.5% | 100% / 40.5% |
| Median age new / tried | 5.3 d / 13 h | 5.1 d / 31 h |
| Success rate of attempted dials | 4.6% | 16.1% |
| Never attempted | 52.4% | 34.8% |
| bitnod.es reachable | 12.5% | 17.4% |
| Terrible: new / tried | 0.11% / 1.01% | 0.34% / 30.15% |
| Worst over-dialled netgroup | 16.0× | 9.5× |
| Distinct source netgroups | 872 | 2,514 |
| Top-10 source share | 20.8% | 10.4% |
| Tor exit IPs (slots) | 489 (667) | 693 (916) |

**Alice**

* **Untested new table.** It fills within days, but only about 4.6% of dials succeed and over half of the entries have never been tried.
* **Misleadingly low isTerrible.** The 0.13% rate mostly reflects that entries haven't yet aged past the thresholds.
* **Concentrated sources.** Source diversity is much lower: the top 10 source netgroups account for about 21% of addrman, and dialling is skewed (worst netgroup 16× expected).
* **Junk multi-port entries.** 79.127.184.3 appears on 8 ports and 173.31.104.199 on 6, with zero successful connections on any of them.

**Bob**

* **Healthier overall.** It has better source diversity and success rate than the short-running node.
* **Silted tried table.** About 30% of tried entries are terrible, almost all stale for more than 30 days. 38% of tried entries haven't had a success in over 90 days, and 18% have ≥10 failed attempts since their last success.
* **Hidden by the headline number.** Tried entries only leave through collisions or by moving back to new, so dead peers accumulate there. The aggregate isTerrible (3.08%) hides this because the new table dominates the denominator. A per-table view seems more informative.

-------------------------

