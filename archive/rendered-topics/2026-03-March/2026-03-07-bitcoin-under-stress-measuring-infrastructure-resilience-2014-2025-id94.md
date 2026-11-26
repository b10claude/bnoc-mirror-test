# Bitcoin Under Stress: Measuring Infrastructure Resilience 2014-2025

b10c | 2026-03-07 00:43:40 UTC | #1

[Wenbin Wu](https://arxiv.org/search/cs?searchtype=author&query=Wu,+W) & [Alexander Neumueller](https://arxiv.org/search/cs?searchtype=author&query=Neumueller,+A) recently published [Bitcoin Under Stress: Measuring Infrastructure Resilience 2014-2025](https://arxiv.org/abs/2602.14372)

https://arxiv.org/pdf/2602.14372

> Bitcoin's design promises resilience through decentralization, yet the physical infrastructure supporting the network creates hidden dependencies. We present the first longitudinal study of Bitcoin's resilience to submarine cable failures, using 11 years of P2P network data (2014--2025) and 68 verified cable fault events. Applying a Buldyrev-style cascade model at country level, we find that Bitcoin's clearnet (non-TOR) critical failure threshold    --  for random failures, meaning the vast majority of inter-country cables must fail before significant node disconnection. Targeted attacks are an order of magnitude more effective (   -- ). To address the majority of nodes now using TOR with unobservable locations, we develop a 4-layer multiplex model incorporating TOR relay infrastructure. Because relay bandwidth concentrates in well-connected European countries, TOR adoption increases resilience under current relay geography (   -- ) rather than introducing hidden fragility. Empirical validation confirms weak physical-layer coupling: 87% of historical cable faults caused less than 5% node impact. We contribute: (1) a multiplex percolation framework for overlay-underlay coupling, including a 4-layer TOR relay model; (2) the first empirical measurement of Bitcoin's physical-layer resilience over a decade; and (3) evidence that TOR adoption amplifies resilience, with distributional bounds quantifying uncertainty under partial observability.

-------------------------

b10c | 2026-03-07 00:57:01 UTC | #2

Systems like Starlink help with undersee cable problems too, to a certain extend. I'm not sure how much traffic can be routed through sattelites, but could be enough two bridge blocks between somewhat particioned networks.

Receiving and relaying blocks to local network via Blockstream Sattelite helps too, but I'm not sure how much it's actually used.

-------------------------

Emzy | 2026-03-07 03:09:38 UTC | #3

Starlink still is dependent on local ground stations. I think the newer satellites with satellite-to-satellite laser communication are not in production yet.

More details here:
https://starlinkinsider.com/starlink-gateway-locations/

-------------------------

