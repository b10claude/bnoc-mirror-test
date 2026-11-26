# Bitcoin Network Topology Discovery Using Timing Analysis (2023)

b10c | 2025-10-14 12:31:15 UTC | #1

https://sec.cs.univie.ac.at/fileadmin/user_upload/i_sec/docs/teaching/thesis/2023/Klonowski_Timo_-_2023_-_Bitcoin_Network_Topology_Discovery_Using_Timing_Analysis.pdf

## Abstract

The cryptocurrency Bitcoin consists of a set of miners that are connected to a peer-to-peer
network. Within said network, messages are efficiently forwarded between clients using
a gossip protocol. The exact topology of this network is supposed to be kept secret;
each miner only knows the connections to their neighbours, as well as a set of potential
peers’ addresses. Knowledge of the topology would enable attackers to launch certain
attacks and compromise the anonymity of clients. In contrast, measuring the topology
also allows researchers to analyse the properties of the network.

We propose a method to exploit the relaying of address messages in the network to
measure the topology of the network. To do this, we combine a node degree estimation
with an inference of potential connections. In particular, we show that peculiarities in
the propagation of ADDR-messages in the context of the gossip protocol enable these
attacks. This holds true despite the basic idea behind both attacks being known already
and the countermeasures trickling and rate-limiting having been implemented by the
reference client. We show that said countermeasures do not prevent these measurement
methods and that both methods can be executed together to perform a comprehensive
topology discovery with considerable accuracy.

In doing so, we also compare estimation methods based on idiosyncratic Bitcoin-specific
behaviour with a statistical timing analysis of flooding inherent time delays. We validate
our method on a testbed node and find that, in particular, the time-based estimator can
estimate the topology with significant accuracy despite artificially introduced forwarding
delays. The relative error of the degree estimation is less than 10 %, and the connection
inference’s precision and recall are approximately 40 % each.

We performed an active measurement on the open Bitcoin mainnet and analysed the
graph-theoretic properties of the topology we found. Our attack can be performed with
low hardware expenses as well as in a short time. The analysis shows that the network
exhibits non-random properties in its structure, especially in the distribution of node
degrees and local clustering coefficients.

-------------------------

