# Follow-up to data request: research paper on passive, network attack

cndolo | 2026-10-19 10:09:42 UTC | #1

Hi,

A few months ago, I posted here [requesting packet captures](https://bnoc.xyz/t/request-bitcoin-and-or-lightning-packet-captures/111) of Bitcoin/LN traffic that I needed for a research project. I got traces from @b10c in time and @jonhbit provided LN traces as well but the paper was already submitted by then (thank you both again).

Our [paper](https://cndolo.github.io/assets/pdf/acsac2026.pdf) has since been accepted to [ACSAC 2026](https://www.acsac.org/2026/program/papers/) and I would like to share some of the results briefly.

**Summary**: The paper presents a passive, network-level attack on Bitcoin nodes. The attack exploits co-location of Bitcoin and LN nodes (i.e., running under the same IP) to link an IP address to a Bitcoin address and, in some cases, a real-world entity. The adversary detects a channel opening via message type classification in the LN, uses the timing of the observed messages to pinpoint the block containing the funding transaction and then applies a revised property heuristic to find LN transactions. The victim's LN alias can then be used to complete the tuple, which we found works far more often for institutional operators (20%) than individuals (4%).

We also looked into port randomisation as a potential countermeasure and the rest of this post focuses on that. Using random ports has been suggested before as a measure against network attacks in Bitcoin and LN, e.g., [here](https://ieeexplore.ieee.org/document/7958588) and [here](https://ieeexplore.ieee.org/document/10190502).

**Question/Methodology**: The attack assumes both applications run on their default ports, so we investigated whether port randomisation is a viable defence by examining the feasibility of passive traffic analysis. We trained a random forest classifier to answer the binary question of whether a given TCP stream carries Bitcoin (or LN) traffic or not. It uses 12 coarse trace-level features such as packet counts, size percentiles and directionality as they all remain observable under encryption (see Table 2 in the paper). We deliberately excluded timing features because the LN traces came from our testbed and such features would not generalise, but we contend that the results still hold in the wild. The dataset covers various captures of Bitcoin V2 P2P, LN, Ethereum and IPFS traffic which is all encrypted. It also includes non-P2P but encrypted services (SSH, HTTPS, SSTP) to model a node running alongside typical services.

**Results**: Both protocols are detected accurately and quickly. Bitcoin traffic reaches a precision and recall of 1.0 within a 1 to 10 second window while LN traffic is detectable almost immediately due to the deterministic nature of the protocol. This complements the findings in [this recent post](https://bnoc.xyz/t/passive-traffic-analysis-of-bitcoin-p2p-v2/161) that show that V2 transport leaves identifiable structure despite encryption.

| Scenario |  | Window (secs) | Precision | Recall (TPR) | FPR |
|----|----|----|----|----|----|
| Bitcoin | P2P | ≤ 0.05 | 0.922 | 0.826 | 0.015 |
|  |  | \[0.05, 1\] | 0.985 | 0.975 | 0.002 |
|  |  | \[1, 10\] | 1.0 | 1.0 | 0.0 |
|  | Services | ≤ 0.05 | 0.926 | 0.835 | 0.02 |
|  |  | \[0.05, 1\] | 0.984 | 0.978 | 0.003 |
|  |  | \[1, 10\] | 0.999 | 0.999 | 0.0 |
| LN | P2P | ≤ 0.05 | 0.983 | 0.994 | 0.0001 |
|  |  | \[0.05, 1\] | 0.999 | 0.999 | 0.0 |
|  |  | \[1, 10\] | 1.0 | 0.999 | 0.0 |
|  | Services | ≤ 0.05 | 0.995 | 0.993 | 0.0001 |
|  |  | \[0.05, 1\] | 0.999 | 0.999 | 0.0 |
|  |  | \[1, 10\] | 1.0 | 0.999 | 0.0 |

*Table 3: Classification scores across various observation windows*

**Conclusion**: Port randomisation adds a layer of complexity to such attacks, as the adversary must first work out whether a stream is relevant at all, but it is not a strong deterrent. The advantages should be weighed carefully as there are some downsides and some have [been raised before](https://github.com/bitcoin/bitcoin/issues/31036). Given this, we believe traffic shaping is inevitable if the traffic should not be detectable.
The feature importance analysis points to the rate of packets of 66 bytes or less as the strongest signal, so that seems like a sensible place to start. We are currently working on traffic shaping for the LN and hope to be able to share our results soon.

Happy to discuss further as well as future work that may be of interest.

-------------------------

b10c | 2026-10-19 19:26:40 UTC | #2

Thank you for sharing this here! 

@Razor, your project is also mentioned!

-------------------------

