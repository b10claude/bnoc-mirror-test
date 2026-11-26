# Bitcoin Core versions run by mining pools

b10c | 2026-09-03 12:47:10 UTC | #1

By looking at which pools mine P2A spends, we can guess when a pool roughly upgraded their getblocktemplate node to Bitcoin Core version v28.

|pool|first spend|first creation|total inputs|total outputs|
|---|---|---|---|---|
|MARA Pool|867278 (2024-10-25)|881521 (2025-01-30)|186633|186660|
|ViaBTC|883626 (2025-02-13)|883626 (2025-02-13)|412064|412084|
|Foundry USA|896194 (2025-05-11)|850457 (2024-07-03)|884113|883988|
|F2Pool|898061 (2025-05-23)|850307 (2024-07-02)|737765|737769|
|AntPool|900676 (2025-06-10)|867352 (2024-10-25)|479620|479701|
|SpiderPool|907615 (2025-07-28)|907610 (2025-07-28)|368225|368199|
|Ocean.xyz|925458 (2025-11-27)|925458 (2025-11-27)|21173|21181|
|Innopolis Tech|927765 (2025-12-13)|927765 (2025-12-13)|1|1|
|Braiins Pool|956252 (2026-07-01)|850000 (2024-06-29)|61275|61274|
|Unknown|957382 (2026-07-10)|957382 (2026-07-10)|36982|36987|
|Solo CK|959115 (2026-07-22)|959115 (2026-07-22)|1224|1224|
|Mining-Dutch|959195 (2026-07-23)|959195 (2026-07-23)|1820|1817|
|CleanIncentive|959666 (2026-07-26)|959666 (2026-07-26)|14505|14505|
|NiceHash|964462 (2026-08-28)|964462 (2026-08-28)|280|280|
|Luxor|-|962760 (2026-08-16)|0|4|
|BTC.com|-|961321 (2026-08-06)|0|1|
|Binance Pool|-|958434 (2026-07-17)|0|1|
|SecPool|-|896193 (2025-05-11)|0|3|
|Mining Squared|-|894977 (2025-05-03)|0|1|


As per https://bitcoincore.org/en/lifecycle/, v28 was released on 2024-10-02. It seems like MaraPool upgraded fairly quickly. ViaBTC upgraded sometime in early Feburary 2025, about four month after the release.

On 2025-04-14, v29 was released. In May and June, Foundry, F2Pool, and AntPool upgraded to v28. SpiderPool upgraded sometime in July. This matches what I've heard elsewhere: some pools are lagging behind on purpose. 

Braiins, SecPool, MiningSquared don't have much hashrate, so we don't know if they would mine a P2A spent if they see one. Similar with the remaining pools not appearing here.

The same can be done with Ephemeral Dust to see when the upgraded to v29 as described in https://github.com/0xB10C/mainnet-observer/issues/101.

-------------------------

Antoine | 2025-11-21 15:51:36 UTC | #2

[quote="b10c, post:1, topic:57"]
ViaBTC upgraded sometime in early Feburary 2025, about four month after the release.

[/quote]


Which appears to exactly follow the release of minor release 28.1 (2025-01-15).

[quote="b10c, post:1, topic:57"]
SpiderPool upgraded sometime in July.

[/quote]

28.2 was released at the end of June.

-------------------------

b10c | 2026-09-03 12:45:29 UTC | #4

[quote="b10c, post:1, topic:57"]
The same can be done with Ephemeral Dust to see when the upgraded to v29 as described in https://github.com/0xB10C/mainnet-observer/issues/101.
[/quote]

As of 2026-09-03:

|pool | first ephemeral dust|
|--- | ---|
|MARA Pool | 894455                      (2025-04-29)|
|AntPool | 900676                      (2025-06-10)|
|F2Pool | 901146                      (2025-06-14)|
|SpiderPool | 913602                      (2025-09-07)|
|Ocean.xyz | 925458                      (2025-11-27)|
|Innopolis Tech | 927765                      (2025-12-13)|
|ViaBTC | 949140                      (2026-05-12)|
|Foundry USA | 949159                      (2026-05-13)|
|Braiins Pool | 956252                      (2026-07-01)|
|CleanIncentive | 965144                      (2026-09-02)|


Bitcoin Core v29.0 was released on 2025-04-15. MaraPool mined their first block with it two weeks later.  AntPool and F2Pool upgraded (at least partly) about two months after the release. Spiderpool upgraded on 2025-09-07.

-------------------------

b10c | 2026-01-15 13:03:35 UTC | #5

mainnet-observer now has daily updated tables for both P2A and ephemeral dust:

- https://mainnet.observer/charts/mining-pools-mining-ephemeral-dust/
- https://mainnet.observer/charts/mining-pools-mining-p2a/

-------------------------

b10c | 2026-09-03 13:10:53 UTC | #6

I've updated the two tables above. Since January this year, there are the following possible upgrades. For the pools that don't frequently find blocks, the data might not be accurate. For these, an upgrade can always have happened earlier, but we didn't know about it until they ended up finding a block.

- May 2026: ViaBTC upgrades from v28 (since February 2025) to v29+
- May 2026: Foundry upgrades from v28 (since May 2025) to v29+
- July 2026: Braiins upgrades to v28 and v29+
- July 2026: CleanIncentive upgrades to v28+
- Sept 2026: CleanIncentive upgrades to v29+

-------------------------

