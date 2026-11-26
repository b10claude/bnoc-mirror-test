# Electrum Server Monitoring: Header Propagation and Shared Infrastructure

dutenrapha | 2026-11-23 19:07:03 UTC | #1


In my previous post (https://bnoc.xyz/t/electrum-server-monitoring/135), I explored whether public Electrum servers could be grouped by comparing their `mempool.get_fee_histogram` responses.

The initial hypothesis was simple: if multiple Electrum servers use the same Bitcoin node as backend, they may expose very similar or even identical mempool fee histograms.

That experiment produced surprisingly large clusters of servers with identical histograms. However, identical fee histograms alone are weak evidence of shared infrastructure. Different servers running the same Electrum implementation and similar configurations can potentially generate very similar results.

So I started looking for a second, independent signal: **how Electrum servers observe new Bitcoin blocks.**

### Monitoring the blockchain tip

Electrum provides the method:

`blockchain.headers.subscribe`

Instead of polling every few minutes, I now maintain persistent connections to a set of public Electrum servers and record every new block header they announce.

For each observation I store information such as:

* server

* block height

* block hash

* previous block hash

* timestamp

* transport

* recent ping latency

This allows me to compare not only **which block a server sees**, but also **when it sees it**.

The hypothesis is that servers sharing the same Bitcoin backend should tend to:

* see the same block first;

* see it at nearly the same time;

* be on the same side when temporary tip divergence happens;

* potentially switch to the same chain at approximately the same time during a reorg.

This provides a signal that is different from the mempool/JSD analysis.

### Current dataset

The latest dataset contains:

* **45 Electrum servers**

* **990 server pairs**

* **4 detected tip-divergence / fork candidates**

For each server pair, I calculate metrics such as:

* how often they initially saw the same block hash;

* median difference between their first observations;

* whether they showed the same reorg behavior;

* timing difference if both switched branches.

I combine some of these into a `fork_behavior_similarity` score, although the individual metrics are currently more informative than the final score.

### Electrum header propagation is surprisingly heterogeneous

One interesting observation is that Electrum servers can announce the same new block at very different times.

Across server pairs, the median first-seen difference was approximately:

**84.5 seconds**

Around **68% of pairs** had median differences between **30 seconds and 5 minutes**.

This is much slower than Bitcoin P2P block propagation itself. What I am measuring here is not pure Bitcoin gossip latency, but when the Electrum server actually exposes the new tip to clients.

This probably mixes several effects such as internal polling cycles, Bitcoin backend latency, server implementation details, and network latency.

But a few pairs behave completely differently.

### Some servers move almost simultaneously

Several pairs consistently saw the same tip with differences measured in milliseconds.

Some of the strongest examples were:

```
bitcoin.grey.pw
fulcrum.grey.pw
median difference: ~31.5 ms

```

```
147.228.238.35.bc.googleusercontent.com
35.238.228.147
median difference: ~221 ms

```

```
18.195.224.155
tool.sh
median difference: ~446 ms

```

All of these pairs observed the same initial block side across the shared events.

The first two cases also have relatively straightforward explanations: the `grey.pw` servers appear related, and the GCP pair is effectively two names referring to the same host.

This is useful as a kind of positive control.

When two endpoints are clearly closely related, the measurement detects synchronization on the order of tens or hundreds of milliseconds.

That makes similar behavior between apparently unrelated domains much more interesting.

### Same operator does not necessarily mean same backend

The `keff.org` servers provide another interesting example.

The four servers consistently saw the same initial block hash across the four observed events.

However, their timing was very different.

Some internal pairs were separated by only a few seconds, while others had median differences approaching **three minutes**.

So:

```
same operator != same tip timing

```

This suggests that multiple servers operated by the same entity may still use different Bitcoin backends, different update loops, or different internal architectures.

This is exactly why looking only at domain ownership is insufficient.

### Being on a different fork side is not the same as being slow

Another observation is that servers that disagreed most frequently with the majority were not necessarily the slowest servers.

Examples include:

```
mempool.8333.mobi
electrum.blockitall.us
2ex.digitaleveryware.com

```

Some of these servers observed minority hashes while still receiving blocks relatively quickly.

So there appear to be at least two independent dimensions:

```
Which block did the server see?

vs.

When did the server see it?

```

That distinction seems useful when trying to fingerprint the infrastructure behind Electrum endpoints.

### Combining this with the fee histogram experiment

The most interesting part for me is combining this new signal with the previous Jensen-Shannon Divergence experiment.

The two measurements describe different layers.

JSD approximately asks:

> Do these servers expose the same mempool / fee policy?

Header monitoring asks:

> Do these servers observe the Bitcoin chain through the same timing and tip behavior?

These signals are not equivalent.

Two servers can have nearly identical fee histograms but observe new blocks at very different times.

Likewise, two servers can usually agree on the same blockchain tip without necessarily sharing the same Bitcoin node.

For that reason, I am currently experimenting with a conservative rule for strong shared-infrastructure candidates:

```
JSD < 0.05
AND
median header timing difference < 1 second
AND
same initial tip
AND
at least 3 shared events

```

The idea is not that this proves common ownership, but that agreement across independent signals should produce substantially stronger candidates than either metric alone.

### One major limitation: I still haven't captured the interesting reorg behavior

The original motivation for this experiment was to observe what happens during temporary Bitcoin forks:

> If two servers initially see the losing branch, do they switch to the winning branch at the same time?

So far, the dataset does **not** provide enough information to answer that.

Although four tip-divergence candidates were detected, I did not capture pairs of servers with measurable branch-switch timing.

This means the current experiment is much better at measuring:

```
same tip + propagation timing

```

than:

```
reorg convergence timing

```

This is an important limitation because the current `fork_behavior_similarity` score is therefore dominated by the initial-side signal.




As with the previous experiment, **none of this is evidence that a particular server is a spy node or operated by Chainalysis**.

The goal is narrower: determine whether apparently independent public Electrum endpoints actually behave as independent pieces of infrastructure.

The current results suggest that counting hostnames is probably not enough. Some endpoints behave independently, some clearly do not, and a small number are synchronized closely enough that they are worth investigating with additional independent signals.

-------------------------

b10c | 2026-08-25 21:53:43 UTC | #2

Thanks for the continued work on this! I found this to be an interesting read - exactly the kind of exploration I was hoping to get out of the project-idea I posted!

[quote="dutenrapha, post:1, topic:167"]
Around **68% of pairs** had median differences between **30 seconds and 5 minutes**.
[/quote]

I'm now wondering how large timing differences between two Electrum servers attached to the same Bitcoin node could be.

[quote="dutenrapha, post:1, topic:167"]
```
18.195.224.155
tool.sh
median difference: ~446 ms
```
[/quote]

That's interesting too, as tool.sh resolves to 18.195.224.155, so I'd expect to get the same timestamps. Have you tried to connect to e.g. tool.sh (or any of the other endpoints) with two or more connections to see if they announce the block at roughly the same time on all connections?

-------------------------

dutenrapha | 2026-08-26 18:13:09 UTC | #3

I don’t have ground-truth “same bitcoind” labels in the current dataset, so I can’t directly answer that yet. What I can say is that **same operator clearly does not imply the same header clock**: for example, keff.org is consistently on the same initial-hash side across four forks, while some of its endpoints differ by \~9 s and others by \~191 s. So the 30 s–5 min band I observed between arbitrary Electrum endpoints shouldn’t be interpreted as an upper bound for servers sharing one Bitcoin node.

Where I have a stronger same-host/backend signal, the differences are much smaller: grey.pw **32 ms**, GCP IP↔PTR **221 ms**, and `tool.sh`↔`18.195.224.155` **446 ms** (N=4, always on the same side). That makes my current hypothesis that two sessions ultimately fed by the same backend should usually be much closer — perhaps sub-second — but I don’t have enough ground truth yet to claim that.

On `tool.sh`: yes, I agree that since it resolves to `18.195.224.155`, you’d expect nearly identical timestamps. I have **not** yet opened multiple connections to the exact same `host:port`. What I currently have are two independent SSL sessions: one to the hostname and one directly to the IP, created independently by the collector. So it is effectively a dual-connect under two labels. My suspicion is that the 446 ms difference is connection/scheduling noise rather than evidence of a different backend, but your proposed experiment is exactly the right way to establish that floor.

My next step is therefore a controlled version of this: run several Electrum servers **all against the same Bitcoin Core node**, subscribe to headers from all of them, and measure pairwise first-seen deltas for new blocks (and, ideally, fork events). In parallel, I can open N independent connections to the exact same Electrum `host:port`. That should give me two useful baselines:

* same Electrum endpoint, different sessions;
* different Electrum servers, same `bitcoind`.

Then we can compare the \~446 ms observation against those distributions rather than guessing from the public-server dataset.

-------------------------

deadmanoz | 2026-08-27 02:49:07 UTC | #4

It would be interesting to see which of the IP addresses that the Electrum server hostnames resolve to show up in the AddrMan data that has been published [here](https://bnoc.xyz/t/historical-bitcoin-core-ip-address-manager-snapshots-via-getrawaddrman/77), and then also connecting to each node to get the subversion string (strong proxy for node version).

I imagine there are a few Electrum servers on the same IP address as a Bitcoin node, and also that the subversion string of a few in cluster 1 of https://bnoc.xyz/t/electrum-server-monitoring/135 indicate the same node version. Same node version would be strongly correlated with same fee rate publication of Electrum Server.

This might help narrow the pool of which Electrum server which might truly be backed by the same Bitcoin node?

-------------------------

dutenrapha | 2026-08-27 17:25:22 UTC | #5

That makes sense. it’s a cross-check I haven’t done yet, and it fits well with what I’m measuring.

What I collect today in the fingerprint is the Electrum server version (`server.version` / `server.features`: Fulcrum, ElectrumX, etc.), not the `bitcoind` subversion (`/Satoshi:28.x/` on P2P). Those are two different layers. The same Electrum version (a lot of people on default Fulcrum) already shows up on my side as JSD ≈ 0 even when the tip diverges — so the same published fee histogram does not prove the same `bitcoind`. I agree the Bitcoin node subversion would be an extra signal; I just wouldn’t treat it as almost equivalent to the Electrum fee publication.

The join you describe, as I see it:

1. Resolve the Electrum hostname → IP(s).
2. Check whether that IP appears in AddrMan.
3. Connect on Bitcoin P2P (usually 8333) and read the subversion.
4. Compare that with fee clusters and with header behavior.

If Electrum `:50002` and a `bitcoind` `:8333` sit on the same IP, that strengthens “same host / same operator.” It still doesn’t prove the Electrum process is talking to that `bitcoind`: there can be a proxy, another process on the box, or Electrum pointing at Core on a different IP. It still narrows the pool, yes.

On cluster 1: if that’s the large identical-histogram cluster, I’d expect a lot of Fulcrum on the same Electrum version, and not necessarily the same `bitcoind`. The filter I’m using for a strong “same chain upstream” suspicion is more the header clock (tens/hundreds of ms Δ + same side on a fork), not fee alone.

The next experiment I want to run is the controlled complement: several Electrum servers deliberately pointed at the same node, then measure `headers.subscribe` deltas. Crossing DNS × AddrMan × subversion on the public set is the other arm, if you have the link/file for the AddrMan dump you mentioned, I’ll look at it.

Thanks for the idea.

-------------------------

