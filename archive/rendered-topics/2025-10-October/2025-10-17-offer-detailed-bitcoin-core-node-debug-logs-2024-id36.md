# Offer: detailed Bitcoin Core node debug.log's (2024-...)

b10c | 2025-10-17 07:49:06 UTC | #1

Starting sometime early 2024, I have detailed Bitcoin Core node debug logs from multiple nodes (usually 10+) that I could share for research and development purposes. I've been collecting these as part of my [peer-observer](https://b10c.me/projects/024-peer-observer/) project. As of October 2025, this is about 4 TB compressed and more than 30 TB uncompressed.

They include the following Bitcoin Core debug log categories.

* net
* addrman
* cmpctblock
* mempoolrej
* validation
* bench
* txpackages
* mempool (since 2024-05-04)

These debug logs aren't cleaned up yet (e.g. remove my honeypot node IP addresses), so that's probably something I'd want to do beforehand. Getting these from archival storage is a bit of effort, too.

-------------------------

b10c | 2025-10-17 07:48:07 UTC | #2

Some sample debug.log's might be available on [https://demo.peer.observer/debug-logs/](https://demo.peer.observer/debug-logs/)

-------------------------

