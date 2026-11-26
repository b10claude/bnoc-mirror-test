# Continuous Measurement of Bitcoin-Derived P2P Networks with DaeConn

matthias | 2026-07-07 08:34:16 UTC | #1

I just came across this recent paper written by a team from Uni Zurich: [Demo: Continuous Measurement of Bitcoin-Derived P2P Networks with DaeConn](https://ieeexplore.ieee.org/document/11575443)

It describes a measurement tool that finds peers in the network and collects information about them. Thus, the tool is an implementation of a \`spy node’ similar to bitnodes. The tool is available at https://github.com/DogukanBaysal/DaeConn

-------------------------

matthias | 2026-07-07 08:44:13 UTC | #2

Related to this, the same authors simulated the Bitcoin P2P network and analyzed the simulated network’s topology and how blocks are propagated in a simulated network:

* [Protocol Driven Dynamics of the Bitcoin Peer-to-Peer Network under Churn](https://ieeexplore.ieee.org/document/11575505)
* [Non-Monotonic Effects of Node Churn on Block Synchronization in Bitcoin](https://ieeexplore.ieee.org/document/11575512)

-------------------------

b10c | 2026-07-07 11:20:24 UTC | #3

It seems I don’t have access to this paper.

We recently saw https://bnoc.xyz/t/python-bitcoinlib-0-12-2-client-getting-addr-ratelimited-since-2026-04-10/116 from Uni Zurich, but looking at the DaeConn tool a bit, it has a different UA. 

https://github.com/DogukanBaysal/DaeConn/blob/e183a43006d1a514a33ce2509c91da4d1a1bbb6e/app/network/scanner.py#L90

and seems to also hardcode an IP I haven’t seen here before:

https://github.com/DogukanBaysal/DaeConn/blob/e183a43006d1a514a33ce2509c91da4d1a1bbb6e/app/network/scanner.py#L309

-------------------------

stratospher | 2026-07-08 07:59:46 UTC | #4

interesting! thanks for sharing!

[quote="b10c, post:3, topic:148"]
[/python-bitcoinlib:0.12.2](https://bnoc.xyz/t/python-bitcoinlib-0-12-2-client-getting-addr-ratelimited-since-2026-04-10/116)
[/quote]

DaeConn seems to be a crawler with the `connector` UA and the hard coded IP is just testing the crawler works.

maybe the other paper (or some other research) might have this `python-bitcoinlib` UA and address rate limiting? though the timeline feels a bit short - it was presented in June and the addr spam started in April/May.

-------------------------

deadmanoz | 2026-07-13 07:54:01 UTC | #5

Here's the full paper as ("un-watermarked") images (it's only 2 pages) :slight_smile: 

![Screenshot 2026-07-13 at 3.51.36 pm|454x500](upload://265KHQKqpN0E9Nq3ssit3R7uBK0.jpeg)

![Screenshot 2026-07-13 at 3.52.33 pm|445x500](upload://kg56J6Jn86y89A2CYpvQTebFaC9.jpeg)

-------------------------

