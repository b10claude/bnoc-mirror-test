# Lightning network observations: Client diversity, upgrade dynamics,

sorukumar | 2026-11-10 16:05:04 UTC | #1

All, Here are two measurement papers on Lightning Network based on our 3 yr long gossip archive and chain data. I am looking to get feedback on definitions, classification heuristics, and pipeline.

**Network resilience and client diversity** ([arXiv:2610.20952](https://arxiv.org/abs/2610.20952))
explainer: [Does client diversity protect Lightning?](https://bitcoindatalabs.github.io/deep-dives/analyses/2026-11-client-diversity-explained/)

**Release lines and upgrade dynamics** ([arXiv:2610.30350](https://arxiv.org/abs/2610.30350))
 explainer: [Who patches the Lightning Network?](https://bitcoindatalabs.github.io/deep-dives/analyses/2026-11-who-patches-lightning/)

The dataset covers 800+ daily snapshots of the public gossip graph recorded from my LND node between May 2023 and October 2026. I've also cross-referenced my bitcoin core node to read closed channels data.


\---

**Key Observations**

**1. Client Diversity & Outage Blast Radiuses (August 2026 CLN Advisory)**

On August 26, 2026, Core Lightning advised operators who could not upgrade to take their nodes offline.

**Targeted response:** 22% of routable CLN nodes went dark within 48 hours (predominantly Tor-reachable nodes). No other client cohort moved. Five weeks later, 32% of those nodes remained offline.

**Reachability impact:** All-pairs reachability across the network fell by 7.8 percentage points. In our baseline of 94 ordinary rolling two-day windows, 4 experienced larger reachability drops, and the July 2026 Tor DoS wave caused twice as much loss (15.6 percentage points).

**Hub centrality vs. client diversity:** ACINQ's single Eclair hub accounts for roughly four times the reachability impact of all 619 routable CLN nodes combined. 19 of the top 20 routing hubs run LND.

**2. Software Lifecycle & Patch Dynamics**

**Packaged platforms drive upgrades:** The three largest LND upgrade waves in the network followed Umbrel app store releases (median spike 16–27 hours post-merge). Across packaged distributions (including Umbrel and BTCPay Server's bundled stack), the 48-hour post-release windows cover only 4.4% of time but contain 17% of all LND upgrades

**Disclosures do not accelerate patching:** Across 12 security advisories, fixes shipped a median of 256 days before coordinated disclosure. Only one advisory (CLN July 2026) showed a measurable acceleration in operator upgrades post-disclosure.

**Persistent exposure:** Two months after Lightning Labs' August 2026 advisories, 71% of exposed LND nodes (representing 6.4% of live LND capacity) remained on unpatched lines. Big capacity nodes do upgrade quickly though.

**Compliance vs. patch state:** Of the CLN nodes that went offline following the August 26 shutdown call, 23.4% of those already on the *newest* release line went dark, compared to 11.0% of nodes on older lines.

\---

**Methodology & Definitions**

**"Live Node":** A node is counted as live on day t if it has at least one channel in the public graph that is not closed on-chain and not disabled in both directions by channel_update flags. Nodes with only stale or disabled channels are excluded so defunct nodes don't distort cohort shares.

**Client & Release Classification:** Gossip carries no version string. I extracted default feature bit vectors from the source code of every tagged release of LND, CLN, Eclair, and LDK since 2019 (in ln_release_features.json). Feature bit 5 separates CLN (set) from Eclair (unset by default). Where CLN nodes state their version in their alias, the inferred line matches for 132 of 136 node–line pairs. Minor patch releases within a line don't alter gossip bits and are invisible.

**Outage Measurement:** Nodes don't announce when they shut down. An outage is recorded on day t when peers set the channel_update disable flag on all channels leading to the node, or when its channels close on-chain without replacement.

**Reachability:** Measured as all-pairs shortest-path connectivity across live nodes. This is an unweighted topological upper bound reflecting connectivity, not channel liquidity or balance distributions.

\---

**Reproduction & Code**

All code, aggregation scripts, and reference tables are open source:

**Diversity paper repo:** [github.com/bitcoindatalabs/ln-client-diversity](https://github.com/bitcoindatalabs/ln-client-diversity)

**Upgrade dynamics repo:** [github.com/bitcoindatalabs/ln-upgrade-dynamics](https://github.com/bitcoindatalabs/ln-upgrade-dynamics)

Would appreciate feedback on:
 1: the feature-bit mapping (`ln_release_features.json`), 
 2: whether other operators' gossip archives observed the same August 26 CLN drop, and any thoughts on our reachability and outage heuristics
3: are there any gossip heuristics  (e.g. policy defaults or announcement quirks) that could help separate patch releases within a single release line?

-------------------------

jonhbit | 2026-11-10 16:14:52 UTC | #2

Nice work! It's great to see someone else looking into LN gossip (and capturing snapshots going back that far).

[quote="sorukumar, post:1, topic:208"]
**Reachability impact:** All-pairs reachability across the network fell by 7.8 percentage points.
[/quote]
 
It could be useful to also frame this in terms of capacity taken offline. The network has many low-value neighborhoods and leaf nodes, so there are many routes that may not be very useful to other nodes in practice, but were still affected by these incidents (e.x. the Tor-only node with 2 channels, of minimum size, to 1ML and LN.BIG).

I would also be curious to see other graph metrics for the nodes taken offline here, such as centrality etc. Maybe Rene Pickhardt's work on max flow (?) would also be relevant.

[quote="sorukumar, post:1, topic:208"]
July 2026 Tor DoS wave caused twice as much loss (15.6 percentage points).
[/quote]

Do you have more info on this? Could be useful to look for this in other datasets (KIT, peer-observer, etc.) These resources suggest a date range of June 25 - July 28:

[1aeo blog post](https://1aeo.com/blog/circuit-building-dos-anatomy-june-2026.html), [tor-relays mailing list post](https://lists.torproject.org/mailman3/hyperkitty/list/tor-relays@lists.torproject.org/thread/VCUWQJ7KECAOL5ADPFWGX5OMYPQJAWG3/), [lowendtalk mitigation forum thread](https://lowendtalk.com/discussion/219382/mitigating-the-ongoing-ddos-attack-against-tor-relays)

Paging @b10c for follow-up

[quote="sorukumar, post:1, topic:208"]
An outage is recorded on day t when peers set the channel_update disable flag on all channels leading to the node
[/quote]

I think there can be cases where the disable bit doesn't get set properly (unclean shutdown?), but this may also show up if a node stops publishing channel_update messages reguarly (most implementations do this far more often than every 14 days, LND does it every day for example).

[quote="sorukumar, post:1, topic:208"]
I extracted default feature bit vectors from the source code of every tagged release of LND, CLN, Eclair, and LDK since 2019 (in ln_release_features.json).
[/quote]

Nice! I took a quick look at the code - are you also inspecting the feature bits in channel announcements? And besides the channel_update CLTV delta, the feerates and min/max payment sizes are also definitely relevant. Offhand, I would expect these either stay at the defaults, or are broadcasted with the defaults and _then_ updated. I see you're also including on-chain TX fingerprints, which is great.

[quote="sorukumar, post:1, topic:208"]
are there any gossip heuristics (e.g. policy defaults or announcement quirks) that could help separate patch releases within a single release line?
[/quote]

I think a node graceful restart should show up in the data as a set of channel disables, then enables and re-announcements? Which you may not be able to see in daily snapshots, but I may be able to find in my data since P2P message collection is continuous. Maybe some restarts are correlated with minor version releases, or Umbrel / BTCServer update policies.

[quote="sorukumar, post:1, topic:208"]
whether other operators’ gossip archives observed the same August 26 CLN drop,
[/quote]

I don't see anything super clear for August 26th, but there does seem to be a lot of churn for August in general (I think there were some other disclosures then, as well as node shutdowns like Boltz and some BTCPay Server instances? Need to collect info on that).

On this page, if you switch to the '3d' window in the figures:

https://gossip-observer.jharveyb.xyz/#sliding

You can see jumps in node_announcement and channel_update enable/disable message counts. You can see this more clearly looking through the data without sliding windows as well:

https://gossip-observer.jharveyb.xyz/#history

There is also a drop in live channels in the network:

https://gossip-observer.jharveyb.xyz/#graph

With spikes of channel closes on August 10, 14, 20-22, and 26.

-------------------------

b10c | 2026-11-10 18:16:43 UTC | #3

@sorukumar maybe https://caaw.io/2027/ is interesting if you want to present / publish these papers.

-------------------------

sorukumar | 2026-11-11 15:28:12 UTC | #4

thanks for the detailed feedback! Still need to dive into it properly. follow up in a couple of days.

-------------------------

