# Historical Bitcoin Core IP address manager snapshots (via getrawaddrman)

b10c | 2026-02-02 12:50:36 UTC | #1

Starting today, 2026-02-02, I have set up a repository to collect Bitcoin Core IP address manager (addrman) snapshots. These are collected daily from nodes via `getrawaddrman`. Historical snapshots are recorded in the Git history of the files.

https://github.com/bitcoin-data/getrawaddrman

For now, I include snapshots from the two https://demo.peer.observer nodes, which are generously sponsored by [Localhost Research](https://lclhost.org/): a Bitcoin-Focused Research Center in the Bay Area. 

The snapshots are licensed under the [CC0 License](https://github.com/bitcoin-data/getrawaddrman/blob/main/LICENSE) and intended for researchers and engineers. Attribution is not required, but welcome.

-------------------------

deadmanoz | 2026-06-12 07:10:47 UTC | #2

I have uploaded daily `getrawaddrman` snapshots from 4 nodes that I have been running to the BNOC data share (that was announced here: [https://bnoc.xyz/t/a-bnoc-data-share/114/6](https://bnoc.xyz/t/a-bnoc-data-share/114/6)).

Collection details are in the README.

https://drive.google.com/drive/folders/1-Ot7Whi1L1ElBNvvRkoUxOyZd4NdIEvs?usp=drive_link


edit b10c: these start on 2026-03-05, see README

-------------------------

b10c | 2026-06-12 07:19:17 UTC | #3

Awesome @deadmanoz! Thanks for sharing these publicly.

Starting 2026-06-09, I have `getrawaddrman` snapshots available from my production peer-observer nodes. Happy to give these to developers and Researcher on a per-request basis.

Enabled by https://github.com/peer-observer/infra-library/pull/160 & https://github.com/peer-observer/infra-library/pull/174.

-------------------------

