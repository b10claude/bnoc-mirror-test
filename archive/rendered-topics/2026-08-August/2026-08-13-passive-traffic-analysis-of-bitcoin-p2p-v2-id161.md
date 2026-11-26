# Passive Traffic Analysis of Bitcoin P2P v2

victorandre957 | 2026-08-13 08:18:06 UTC | #1

I started working on this subject after reading the discussion in
[0xB10C/project-ideas#12](https://github.com/0xB10C/project-ideas/issues/12).
The question that interested me was relatively simple: after BIP324 removes the
cleartext Bitcoin message framing, what can a passive observer still learn from
the traffic?

BIP324 prevents an observer from directly reading commands such as `inv`, `tx`,
and `block`. However, TCP behavior, payload sizes, traffic direction, timing,
and encrypted bursts remain visible. I built a controlled Warnet experiment to
explore how useful those signals are, without decrypting the traffic or running
another Bitcoin node to observe the protocol directly.

The complete write-up is available here:

[Passive Traffic Analysis of Bitcoin P2P v2](https://victorandre957.github.io/personal_blog/posts/bip324-passive-traffic-analysis-and-randomized-ports/)

The experiment uses two repositories. The
[bip324-traffic-lab](https://github.com/victorandre957/bip324-traffic-lab)
project generates reproducible Warnet traffic, background noise, PCAPs, Bitcoin
Core logs, and metadata. The
[bip324-traffic-analysis](https://github.com/victorandre957/bip324-traffic-analysis)
project processes those captures and evaluates the resulting candidates.

## Approach

The analysis combines characteristics of the initial BIP324 TCP exchange with
packet sizes, direction, inter-packet gaps, and bursts observed at different
time scales. TCP sequence numbers are used to avoid counting retransmitted
payload twice. The detector also looks for temporal sequences that may resemble
transaction relay and for propagation evidence appearing across independent
flows.

Candidate generation is based on captured traffic. In the Warnet experiment,
an IP map first limits the evaluation to the controlled lab endpoints, but it
does not tell the classifier whether a retained flow is Bitcoin or noise.
Bitcoin Core logs and simulation metadata are only used afterward for
validation and reproducibility.

## Current observations

The current run contains 632 retained lab flows: five labeled BIP324 flows and
627 background-noise flows.

Inside the common PCAP/log interval, the handshake heuristic found all five
reference handshakes. When all retained lab flows were considered, it also
classified the single obfs4 flow as a handshake candidate.

In the table below, TP means that a Bitcoin flow was detected, FP is a noise
flow incorrectly selected, FN is a missed Bitcoin flow, and TN is a noise flow
correctly rejected. Precision measures how many selected flows were correct,
recall measures how many reference Bitcoin flows were found, and F1 summarizes
both values.

| TP | FP | FN | TN | Precision | Recall | F1 |
|---:|---:|---:|---:|---:|---:|---:|
| 5 | 1 | 0 | 626 | 83.33% | 100.00% | 90.91% |

![Handshake confusion matrix](upload://vleCxfeY9LjXA8stUzeKvjrDdk4.svg)

This is still a small controlled sample. The obfs4 result provides one concrete
case in which the current heuristic fails, but a single flow is not enough to
estimate a general false-positive rate for obfs4.

The transaction-related results were mixed. The transaction-relay sequence
reached `71.80%` measured recall and `61.07%` F1, while still producing 292
false positives. INV and TX-like evidence had moderate results, whereas
request-like detection reached only `24.41%` recall.

Block detection was considerably weaker. Block arrival, compact-block arrival,
and propagation-wave detection all had recall below `14%`. One difficulty is
that Bitcoin Core logs contain observations from several nodes and peers, while
a passive burst may contain or aggregate more than one encrypted message.
Consequently, the validation is an operational reference rather than
packet-level ground truth.

These results describe the current detector and this particular Warnet run.
They do not show that BIP324 application messages can be identified reliably
from traffic metadata.

## Randomized listening ports

I also implemented an experimental Bitcoin Core option for selecting a random
high listening port at startup:

[Randomized P2P port implementation](https://github.com/victorandre957/bitcoin/pull/3)

When started with `-port=0`, the node selects an available port between `49152`
and `65534`, persists it after startup, advertises it through Bitcoin Core’s
existing local-address mechanism, and reuses it on later restarts.

The intention is to reduce the usefulness of the default listening port as an
initial traffic-selection signal. The implementation remains experimental and
would benefit from further review, especially regarding configuration, address
advertisement, reachability, and operational behavior.

Comments on this research would be very helpful. I would particularly
appreciate ideas for detecting other events, improving the heuristics already
tested, or approaching the same problem differently. Feedback on the
randomized-port implementation and its practical trade-offs would also be
welcome.

-------------------------

dutenrapha | 2026-09-03 19:40:51 UTC | #2

Really interesting work. After going through the experiment and the analysis pipeline, one direction that seems like a natural extension would be to replace or complement the manually defined heuristics with a supervised machine learning model.

Most of the signals you are already extracting, such as initial flight sizes, entropy, directionality, packet sizes, inter-packet gaps, burst statistics, retransmissions, and multi-scale temporal features, could be used directly as model features.

Warnet also seems particularly well suited for generating a much larger labeled dataset. In principle, it should be possible to generate a large number of BIP324 connections while varying topology, latency, jitter, packet loss, transaction activity, garbage length, node behavior, and other network conditions, and combine them with large amounts of non-BIP324 traffic.

I think the negative examples would be particularly important. Rather than relying mainly on easy negatives, I would include many hard negatives such as obfs4, Tor, TLS/HTTPS, QUIC, and other encrypted or obfuscated protocols. The fact that obfs4 already produced a false positive in the current heuristic makes this especially interesting.

A first experiment could be relatively simple:

PCAP → existing pipeline features → classifier → P(BIP324)

Then, models such as logistic regression, Random Forest, XGBoost, and an MLP could be compared against the current heuristic baseline.

-------------------------

Razor | 2026-10-03 14:42:17 UTC | #3

Hi @victorandre957!

I am for opt-in random port selection. You're also not the first one to think about that. There's this older issue here in which people discuss about the tradeoffs: https://github.com/bitcoin/bitcoin/issues/31036#issuecomment-5243447210

There are multiple issues with randomized ports, one of them being: if a node restarts, and it then chooses a new random port, the old addrman entry becomes stale. I'm not sure exactly what's the effect of that, but maybe there are way around it.

-------------------------

b10c | 2026-10-09 14:36:06 UTC | #4

[quote="Razor, post:3, topic:161"]
There are multiple issues with randomized ports, one of them being: if a node restarts, and it then chooses a new random port, the old addrman entry becomes stale. I’m not sure exactly what’s the effect of that, but maybe there are way around it.
[/quote]

One idea is to save the port to a file in the nodes data directory or derive it from the peers.dat's random key deterministically so it's preserved across restarts.

-------------------------

