# Consecutive Block Patterns Don't Match What Hashrate Predicts

sorukumar | 2026-03-31 06:50:40 UTC | #1

Been poking at consecutive block data since recent [two block re-org](https://bnoc.xyz/t/two-block-reorg-at-height-941880/97).

A few things don’t square with what independent competing Poisson processes would predict:

* 7+ block streaks are 3–7× more frequent than hashrate predicts. Foundry (\~24% share average since 2021) has 33 such streaks vs. \~10 expected. 3.17× over. F2Pool has one such event but at 6.69×, sample of one, but that’s not a luck margin

* Win a block, you’re more likely to win the next one too. P(same pool wins N+1 | just won N) should equal hash share exactly. 1× baseline. SpiderPool runs at 2.70×, SecPool 2.58×, Poolin 2.31×. Upon solving N you already hold the header; everyone else is still propagating.

* Some pools are sequencing consecutive blocks within 30 seconds. At 600s mean block time that sub-30s tail should be thin. It isn’t, hundreds of same-pool pairs, concentrated in the pools above. That timing window is inconsistent with full block validation before starting the next template

* SpiderPool: 1.74% empty blocks (104/5,963), highest in the dataset, and they lead the second-block uplift too. Foundry, despite the streak anomalies, is 0 empty in 67,531 blocks.

* Binance Pool’s 30-day empty block rate (1.06%) has gotten worse, not better ,against their 0.43% all-time average. Every other historical offender has trended toward zero. Worth watching.

Here are some charts:

Pls visit to see the charts and number: https://sorukumar.github.io/bitcoin-mining-pools/index.html#forensics . The analysis is based on **post-2021** data.

Let me know your feedback.Happy to dig into methodology.

Any thoughts on what else we should look at to understand it better.

Here is the data if you want to play on your own. https://github.com/sorukumar/bitcoin-mining-pools/tree/main/dashboard/data

-------------------------

b10c | 2026-04-02 12:19:32 UTC | #2

Welcome @sorukumar!

[quote="sorukumar, post:1, topic:105"]
7+ block streaks are 3–7× more frequent than hashrate predicts. Foundry (~24% share average since 2021) has 33 such streaks vs. ~10 expected. 3.17× over. F2Pool has one such event but at 6.69×, sample of one, but that’s not a luck margin
[/quote]

Since Foundry had it's first 7-block streak at the end of 2022 (2022-11-06), when they were already close to 30% hashrate (and probably had slightly more than 30% hashrate since the beginning of 2023 on average; I haven't checked in detail), I think it makes sense to do this calculation again with e.g. 30% and 32% hashrate numbers instead of 24%.

See https://mainnet.observer/charts/mining-pools-foundry/

[quote="sorukumar, post:1, topic:105"]
Win a block, you’re more likely to win the next one too. P(same pool wins N+1 | just won N) should equal hash share exactly. 1× baseline. SpiderPool runs at 2.70×, SecPool 2.58×, Poolin 2.31×. Upon solving N you already hold the header; everyone else is still propagating.
[/quote]

I was curious how you calculate this for e.g. SpiderPool. The data on your page suggests it's using data from 2021 till now and are using an average hashrate over that time, but SpilderPool did have highly variable hashrate through this period. I'd assume that for a pool going from 0% to 10% hashrate in two years (and no blocks before) doesn't produce a usable average? See [mempool.space/mining/pool/spiderpool](https://mempool.space/mining/pool/spiderpool)

Might be better to look at shorter timeframe without much variance in hashrate? Or graph the expected and observed "Second Block Uplift" on e.g. a per-month level per pool?

-------------------------

sorukumar | 2026-04-03 02:39:58 UTC | #3

Thanks. Sharp observation.

I updated the methodology to use block-weighted hash share from Nov 2022 (\~30%) — the period when Foundry actually held meaningful hashrate. Using that as the baseline, Foundry's 7+ streak frequency is **1.19× expected**, within plausible variance range.

Exploring next-block behavior further. Will update if I find anything interesting.

-------------------------

