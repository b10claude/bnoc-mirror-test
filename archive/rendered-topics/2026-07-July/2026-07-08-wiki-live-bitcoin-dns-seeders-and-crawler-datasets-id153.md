# Wiki: Live Bitcoin DNS seeders and crawler datasets

jorisstrakeljahn | 2026-08-17 09:40:06 UTC | #1

While working on the [ASmap dashboard](https://jorisstrakeljahn.github.io/asmap-dashboard/#network) I collected a list of crawlers and DNS seeders. Ended up checking quite a few of them, so in case it helps someone, here is the list:

## Crawlers / node datasets
(Every DNS seeder runs its own network crawler internally - some operators publish that crawler's full view as a dump, which is why I put several of the seeders from the section below also in here)

| Source | What you get | Code | Status |
|----|----|----|----|
| https://mainnet.achownodes.xyz/ | Full dnsseed.dump of achow101's crawler: one line per known node with uptime stats (2h to 30d), block height, services, user agent. A `makeseeds.py` source with the widest service-bit coverage. | [achow101/dnsseedrs](https://github.com/achow101/dnsseedrs) | live, fresh |
| https://bitcoin.fish.foo/ | Same dump format from Will Clark's [dnsseedrs instance](https://github.com/willcl-ark/dnsseedrs). Not in Core's vSeeds, so an independent vantage point | | live, fresh |
| https://bitnod.es/ | BitMEX Research node explorer: one cumulative "last seen" CSV per day with IP, country, ISP, services, user agent, height. Daily since 2026-06-26, weekly before. The site credits [ayeowch/bitnodes](https://github.com/ayeowch/bitnodes) as its network crawler. | [ayeowch/bitnodes](https://github.com/ayeowch/bitnodes) | live, fresh |
| https://btcnodes.io/ | Revival of the original bitnodes.io crawler. Full snapshots including Tor/I2P/CJDNS via [`/api/v1/snapshots/latest/`](https://btcnodes.io/api/v1/snapshots/latest/); API history back to 2026-05-10. | [brunneis/btcnodes](https://github.com/brunneis/btcnodes) (bitnodes fork) | live, fresh |
| [dsn.kastel.kit.edu/bitcoin](https://www.dsn.kastel.kit.edu/bitcoin/) | KIT DSN group research crawl: one dossier per day with per-node whois/ASN annotations under [`/bitcoin/snapshots/`](https://www.dsn.kastel.kit.edu/bitcoin/snapshots/). The public index goes back to 2015-07 | | live, fresh |
| https://haf.ovh/seed.txt | Full `dnsseed.dump` from `seed.bitcoin.haf.ovh`, run by [Retropex](https://github.com/Retropex). Not in Core's vSeeds, so another independent vantage point | | live, fresh |
| https://21.ninja/seeds.txt.gz | virtu's crawler, also a `makeseeds.py` source. The dump is frozen since 2026-05-22; the [21.ninja](https://21.ninja/) data site itself is still up. | [virtu/p2p-crawler](https://github.com/virtu/p2p-crawler) | stale since 2026-05 |
| https://bitcoin.sipa.be/seeds.txt.gz | sipa's `dnsseed.dump`, the published file is frozen since 2025-11-22, even though the DNS seed itself is fine | [sipa/bitcoin-seeder](https://github.com/sipa/bitcoin-seeder) | stale since 2025-11 |
| [blockchair.com/bitcoin/nodes](https://blockchair.com/bitcoin/nodes) | Only a filtered "recently active" subset via [api.blockchair.com/bitcoin/nodes](https://api.blockchair.com/bitcoin/nodes), not a full crawl | | live, fresh |

## DNS seeders

* The eight mainnet seeds from Bitcoin Core: [chainparams.cpp](https://github.com/bitcoin/bitcoin/blob/f0da26cfc8a42e917fb8144530c03fbb2f319d8c/src/kernel/chainparams.cpp#L168-L175)
* [seed.bitcoin.wiz.biz](https://wiz.biz/bitcoin/seed) returns IPv4 addresses only (no IPv6 records) and publishes no crawler dump, just an HTML status page ([wiz/dnsseed-rust](https://github.com/wiz/dnsseed-rust))
* [seed.bitcoin.fish.foo](https://bitcoin.fish.foo/) is a ninth, non-Core seeder run by willcl-ark that also answers (its dump is in the table above)
* [seed.bitcoin.haf.ovh](https://haf.ovh/leo.html) is a tenth, non-Core seeder run by [retropex](https://github.com/Retropex) that also answers and publishes a full dump (in the table above)
* Two former Core seeds are still live and answering: `dnsseed.bitcoin.dashjr-list-of-p2p-nodes.us` (removed from vSeeds in [Dec 2025](https://github.com/bitcoin/bitcoin/pull/33723), still in [Knots' chainparams.cpp](https://github.com/bitcoinknots/bitcoin/blob/28.x-knots/src/kernel/chainparams.cpp)) and `seed.bitcoinstats.com` (removed in [Aug 2024](https://github.com/bitcoin/bitcoin/commit/c88a7dc53e3be7489605c3326cf768df5437393a))

[octavio.xyz](https://octavio.xyz/projects/dns-monitoring/) monitors the quality of some of these seeds daily (advertised, reachable, stale, pristine, duplicate) via a small JSON API, own measurements since 2026-05-17. It also hosts virtu's older series (Oct 2022 to Nov 2025, originally at [21.ninja/dns-seeds](https://21.ninja/dns-seeds/)) as static CSVs under `demo-data/`

## Related, but no raw node data

* the [dnsseedrs dashboard](https://willcl-ark.github.io/dnsseedrs/) is willcl-ark's frontend for his fish.foo dump above
* [census.yonson.dev](https://census.yonson.dev/) publishes feature-acceptance aggregates
* [Seed Coat](https://dns-seed.github.io/) only record counts per seeder
* [bitdis.org](https://bitdis.org/) only Core/Knots totals

If you know a live source I missed, I'd be happy to hear about it. Thanks!

-------------------------

jorisstrakeljahn | 2026-07-21 22:03:11 UTC | #2

Two weeks ago I posted the list of live seeders and crawler datasets above. Since then I have been archiving all of them daily in [bitcoin-seeder-data](https://github.com/jorisstrakeljahn/bitcoin-seeder-data): DNS answers from the eight Core seeds plus fish.foo every 6 hours, and every published dump once a day. Here is what the first two weeks show.

All population and overlap numbers below are clearnet only (IPv4 + IPv6). Onion, I2P and CJDNS are left out of those comparisons.

## Clearnet population sizes

Raw totals are not comparable across sites, each operator uses a different reachability rule:

| source | clearnet | reachability rule |
|---|---|---|
| KIT dossier | 9,669 | all entries in the public dossier |
| bitnod.es | 9,319 | last seen within 1 day of the newest export |
| btcnodes | 8,793 | completed handshake in one crawl round |
| sipa seeds.txt (frozen since 2025-11) | 8,947 | seeder good flag |
| fish.foo seeds.txt | 5,899 | seeder good flag |
| achow101 seeds.txt | 4,250 | seeder good flag |

With the address family fixed, KIT / bitnod.es / btcnodes sit near 9k. The seeder good sets are smaller: they require uptime scores over windows from 2h to 30d, not only a recent sighting.

KIT's dossier accumulates over months. Cutting on "lastConnect" changes the count: 3,271 within 1d, 5,129 within 7d, 9,669 for all entries.

bitnod.es moves day to day inside the 9k band (export timing and uneven daily buckets I think). A 7-day rolling mean removes most of that movement, but the level sits a few hundred hosts above btcnodes, consistent with the wider 1-day last-seen window.

## Pairwise overlap

bitnod.es vs btcnodes (both forks from [ayeowch/bitnodes](https://github.com/ayeowch/bitnodes)). On 2026-07-21 the two agree on 8,166 clearnet hosts: 88% of the bitnod.es set (9,319) and 93% of the btcnodes set (8,793). Of the 1,153 bitnod.es-only hosts that day, 783 (68%) appear in at least one archived btcnodes snapshot from the previous week; 370 (32%) do not. Part of the gap is the 1-day last-seen window versus a single crawl round I guess.

achow101 vs fish.foo (both run [dnsseedrs](https://github.com/achow101/dnsseedrs); willcl-ark's [fish.foo](https://github.com/willcl-ark/dnsseedrs) is a fork of achow's). fish.foo's good clearnet set (5,899) contains 96% of achow's (4,250); the shared hosts make up 69% of fish.foo's set, so fish.foo has about 1,800 hosts that achow does not. I think the remaining gap is vantage, uptime history and probe timing. Also fish.foo is some commits ahead, mostly packaging, performance and crawl scheduling.

## DNS responses vs a full crawl

I also checked whether pooling DNS answers over time can stand in for a full dump in a clearnet census. Over 14 days (6h cadence, all nine seeds), against the btcnodes clearnet set of 2026-07-21, with recall^[share of the btcnodes set that the pooled DNS answers cover] and precision^[share of the pooled DNS answers that appear in the btcnodes set]:

| window | unique clearnet IPs | recall | precision |
|---|---|---|---|
| 1d | 2,996 | 23% | 67% |
| 3d | 6,565 | 47% | 62% |
| 7d | 9,693 | 61% | 56% |
| 14d | 12,394 | 68% | 48% |

The pooled set grows into the thousands, but precision falls as older answers stay in the union. Size-dependent metrics (groups-to-50%, bucketing ratios) also change with sample size, so a DNS pool and a full crawl are different inputs. But maybe for the seeder-side full view, the published seeds.txt files (like from fish.foo, achow101) could be used.

## DNS seed coverage

Also here is the share of IPv4 addresses each seed served on 2026-07-20 that appear in the crawlers' clearnet sets from 2026-07-21, plus a reachability check from [octavio.xyz](https://octavio.xyz/projects/dns-monitoring/).

| seed | unique A | bitnod.es | btcnodes | octavio |
|---|---|---|---|---|
| sipa.be | 440 | 95% | 92% | 100% |
| fish.foo | 177 | 95% | 94% | - |
| emzy.de | 456 | 93% | 89% | 88% |
| achownodes.xyz | 831 | 89% | 86% | - |
| petertodd.net | 430 | 79% | 77% | 96% |
| bluematt.me | 127 | 75% | 89% | 86% |
| sprovoost.nl | 433 | 65% | 64% | 57% |
| wiz.biz | 207 | 59% | 66% | 76% |
| jonasschnelli.ch | 423 | 50% | 49% | 50% |

## What I take from this

The point of the archive was to put one clearnet basis under the sources in the list above. With that in hand, two things stand out for me.

First, raw "node counts" across sites are different objects. KIT / bitnod.es / btcnodes land near 9k clearnet hosts under their own rules. Seeder good sets are smaller because they score uptime over 2h…30d. For a population series I would pick one rule and keep it: a btcnodes snapshot, or bitnod.es last-seen with a fixed window and a 7-day mean.

Second, sharing a software line still leaves a measurable gap. bitnod.es and btcnodes agree on 88% and 93% of their respective sets, and of the bitnod.es-only hosts that day, about a third never show up in a week of btcnodes snapshots. For achow101 and fish.foo, 96% of achow's good hosts are in fish.foo's set, but fish.foo carries about 1,800 hosts achow does not.

Everything regenerates from the raw archives with two scripts in analysis/ of the [bitcoin-seeder-data repo](https://github.com/jorisstrakeljahn/bitcoin-seeder-data). If a number looks wrong from your side, I would like to know.

-------------------------

matthias | 2026-07-22 14:48:01 UTC | #3

Thank you! This is a great compilation of the different data sources.

A clarification about the KIT dossiers: All peers contained in a dossier are active and connected to the monitor at the time of creation of the dossier. The `lastConnect` field indicates when each connection was initiated. Assuming that `now` is the time of the dossier, this means the connections with `lastConnect < now - 7d` are active connections that have already existed for more than seven days while connections with `lastConnect > now - 1d` are connections that have been initiated within the last 24 hours.

-------------------------

jorisstrakeljahn | 2026-07-23 17:59:50 UTC | #4

Thanks, that clears it up. I had read lastConnect like a last-seen freshness cutoff. Good to know every entry is connected at snapshot time.

-------------------------

deadmanoz | 2026-07-27 08:16:02 UTC | #5

Hey @jorisstrakeljahn this is great, love that you're looking right at the start, that is, the interaction a node has when it is spun up for the first time.

BTW here is the GitHub link for nyonon's census project: https://github.com/nyonson/bitcoin-peers

-------------------------

jorisstrakeljahn | 2026-07-28 00:04:36 UTC | #6

A short note on the roughly 9k clearnet figures above: as discussed in [#121](https://bnoc.xyz/t/small-getaddr-responses-from-897-nodes-satoshi-27-0-0-on-as63949/121/11), bitnod.es and btcnodes each include about 950 reachable endpoints from the same AS63949 fleet. They complete the Bitcoin handshake but do not behave like normal Bitcoin Core nodes afterward.

And thanks for the link, @deadmanoz. I hadn’t seen this implementation before. I’ll take a closer look and may include it in my crawler comparison.

-------------------------

b10c | 2026-08-15 11:10:45 UTC | #7

Made the top post a discourse-"WIki". Frequent contributors to this forum should be able to edit the wiki post now.

-------------------------

