# Request: block filter peers being disconnected due to invalid block requests

davidgumberg | 2026-03-28 10:54:16 UTC | #1

During the recent [2-block reorg at 941880](https://bnoc.xyz/t/two-block-reorg-at-height-941880/97) I noticed while inspecting the log files of a node that was stalled for 10 minutes ([link **☢️** big file](https://achow101.com/files/debug.log2026-03-23-foundry-reorg.txt)) that one of it's peers was sending blockfilter requests for the blocks this node was stalled from receiving:


`[net] peer requested invalid block hash: 95b0d0f836f18d78dfbae435fb37bf6fff2e37a4fc01c20be8495bc3ea4fbb58, disconnecting peer=8502032, [...]`

A node with a similar version message then proceeds to continually reconnect after being disconnected and asking for more forbidden filters :).

Note, this behavior on the part of the requesting client is a violation of [BIP-0157](https://github.com/bitcoin/bips/blob/master/bip-0157.mediawiki#getcfheaders) which states:

> StopHash MUST be known to belong to a block accepted by the receiving peer. This is the case if the peer had previously sent a `headers` or `inv` message with that block or any descendents. A node that receives `getcfheaders` with an unknown StopHash SHOULD NOT respond.

But it seems some BIP157 light clients are not complying, and I'm curious to learn what clients out there are getting disconnected for this reason, could anyone that has `debug=net` logging enabled share the results of the following awk script which prints the associated version strings of compact blocks peers that violate this rule:

```
awk -F'peer=' '
    BEGIN {
        print "| peer | version | blockhash |";
        print "|------|---------|-----------|";
    }
    # 2026-03-23T15:23:40.335605Z [msghand] [../../src/net_processing.cpp:3691] [ProcessMessage] [net] receive version message: /btcwire:0.5.0/neutrino:0.12.0-beta/: [etc...], peer=8502032, [etc...]
    /receive version message/ {
        v=$1; 
        sub(/.*receive version message: /, "", v); 
        sub(/: .*/, "", v); 
        sub(/: .*/, "", v); 

        p=$2;
        sub(/,.*/, "", p);
            
        ver[p]=v;
    } 
    # 2026-03-23T15:23:52.623454Z [msghand] [../../src/net_processing.cpp:3281] [PrepareBlockFilterRequest] [net] peer requested invalid block hash: 95b0d0f836f18d78dfbae435fb37bf6fff2e37a4fc01c20be8495bc3ea4fbb58, disconnecting peer=8502032, [...]
    /invalid block hash/ {
        h=$1; 
        sub(/.*invalid block hash: /, "", h); 
        sub(/,.*/, "", h); 

        p=$2;
        sub(/,.*/, "", p);

        print "| "p" | "ver[p]" | "h" |";
    }
' debug.log
```

One-line form:
```bash
awk -F'peer=' 'BEGIN{print "| Peer | Block Hash | Version |";print "|------|------------|---------|";}/receive version message/{v=$1;sub(/.*receive version message: /, "", v);sub(/: .*/, "", v);sub(/: .*/, "", v);p=$2;sub(/,.*/, "", p);ver[p]=v;}/invalid block hash/{h=$1;sub(/.*invalid block hash: /, "", h);sub(/,.*/, "", h);p=$2;sub(/,.*/, "", p);print "| "p" | "h" | "ver[p]" |";}' debug.log
```

This bitcoin core issue is also relevant: [bitcoin/bitcoin#29655](https://github.com/bitcoin/bitcoin/issues/29655)

All of the nodes on the log sample I analyzed had the same version string: `/btcwire:0.5.0/neutrino:0.12.0-beta/`

| peer | version | blockhash |
|------|---------|-----------|
| 8531836 | /btcwire:0.5.0/neutrino:0.12.0-beta/ | 00000000000000000000bd4930a5982911e7749eb491886206e71abdc1ec0cc6 |
| 8532044 | /btcwire:0.5.0/neutrino:0.12.0-beta/ | 00000000000000000000bd4930a5982911e7749eb491886206e71abdc1ec0cc6 |
| 8532234 | /btcwire:0.5.0/neutrino:0.12.0-beta/ | 0000000000000000000085ebdcd669c404195dbfeccbee902fc646dadc367a20 |
| 8532026 | /btcwire:0.5.0/neutrino:0.12.0-beta/ | 0000000000000000000085ebdcd669c404195dbfeccbee902fc646dadc367a20 |
| 8541062 | /btcwire:0.5.0/neutrino:0.12.0-beta/ | 95b0d0f836f18d78dfbae435fb37bf6fff2e37a4fc01c20be8495bc3ea4fbb58 |
| 8539079 | /btcwire:0.5.0/neutrino:0.12.0-beta/ | 00000000000000000001f8562235e11fc74d5eea589e4c37b671b4213e89f52f |

-------------------------

b10c | 2026-03-27 08:09:32 UTC | #2

I have one node that I have `net` debug logs for and that has `blockfilterindex=1`. I ran your awk script against my logs since 2026-01-01.

In total, I have 1734 entries of this happening. All but four clients have `btcwire:0.5.0/neutrino:0.12.0-beta` as the user agent. For three I don't have a user agent in the output (probably connected to me before 2026-01-01 and the version message is in a different log file), and for one I have `/btcwire:0.5.0/zap-desktop:0.7.7-beta/`.

I have IP logging enabled on my nodes, so my output includes IPs. Not posting these here, but can share privately, if that's interesting to you.

Looking some of these IPs up, it seems they all belong to a diverse set of cloud hosters (Digital Ocean, Hetzner, Google Cloud, some Swedish cloud hosters, ...). I didn't check all IPs, but the only residential IP I saw was for the `zap-desktop:0.7.7-beta` user agent. This led me to believe that these are LN nodes hosted in the cloud. Looking some of the IPs up on https://amboss.space and 1ml.com shows that there are actually LN nodes running behind these. I don't know if you can fingerprint/identify LN node implemenations by behavior if you just have their IP addresses, but my guess would be that `btcwire:0.5.0/neutrino:0.12.0-beta/` is LND?

Looking at block hashes, I have 1166 (67%) entries with `95b0d0f836f18d78dfbae435fb37bf6fff2e37a4fc01c20be8495bc3ea4fbb58`. I could not find a mention of this on GitHub besides on your https://github.com/bitcoin/bitcoin/pull/34933 PR. I didn't check BIP 157 yet. It might be hardcoded somewhere, but encoded.

I looked a few of the remaining block hashes up in a block explorer and they all seem to be valid. 


[data (without peer column)](https://gist.github.com/0xB10C/1c02770fcc84361ae1acbe7fa4565dfb)

-------------------------

mzumsande | 2026-03-27 16:38:35 UTC | #3

[quote="b10c, post:2, topic:101"]
I have one node that I have `net` debug logs for and that has `blockfilterindex=1`

[/quote]

On top of that, do you see any events of “Failed to find block filter in index” logs (followed by ignoring the request, not disconnection)? As brought up in https://github.com/bitcoin/bitcoin/issues/29655#issuecomment-1999066275 this might happen even with BIP157 compliant peers who send their request right after they receive the INV for the block (but the node hasn’t indexed the block yet because that happens in another thread). This would need to be fixed withing Core, if it actually was an issue.

-------------------------

b10c | 2026-03-28 10:37:25 UTC | #4

I've found a single occurence of `Failed to find block filter in index` from December 2024 on the `blockfilterindex=1` node. This seems to be a floresta `peer=1580012` that (at least back then) would request a `getcfilters` for a block we hadn't connected and neither inv'ed to it yet.

```
2024-12-21T19:45:35.353185Z [msghand] [net_processing.cpp:3580] [ProcessMessage] [net] receive version message: /Floresta:0.7.0/: version 70016, blocks=0, us=X, txrelay=0, peer=1580012, peeraddr=Y
...
2024-12-21T22:52:54.450806Z [msghand] [net_processing.cpp:4330] [ProcessMessage] Saw new cmpctblock header hash=000000000000000000009f27b05ec8d4a533b8ad61f670b8441e3a656a2ad084 peer=Z
2024-12-21T22:52:54.558481Z [msghand] [blockencodings.cpp:220] [FillBlock] [cmpctblock] Successfully reconstructed block 000000000000000000009f27b05ec8d4a533b8ad61f670b8441e3a656a2ad084 with 1 txn prefilled, 2081 txn from mempool (incl at least 16 from extra pool) and 28 txn requested
...
2024-12-21T22:52:55.700045Z [scheduler] [validationinterface.cpp:215] [operator()] [validation] BlockConnected: block hash=000000000000000000009f27b05ec8d4a533b8ad61f670b8441e3a656a2ad084 block height=875798
2024-12-21T22:52:55.704025Z [msghand] [net_processing.cpp:3382] [ProcessMessage] [net] received: getcfilters (37 bytes) peer=1580012
2024-12-21T22:52:55.704055Z [msghand] [net_processing.cpp:3183] [ProcessGetCFilters] [net] Failed to find block filter in index: filter_type=basic, start_height=875798, stop_hash=000000000000000000009f27b05ec8d4a533b8ad61f670b8441e3a656a2ad084
2024-12-21T22:52:55.713134Z [scheduler] [validationinterface.cpp:179] [operator()] [validation] UpdatedBlockTip: new block hash=000000000000000000009f27b05ec8d4a533b8ad61f670b8441e3a656a2ad084 fork block hash=00000000000000000000f9038e041a74a5b69790258b1ed9c17573e161bbeca2 (in IBD=false)
...
2024-12-21T22:52:55.713346Z [msghand] [net_processing.cpp:5651] [SendMessages] [net] SendMessages: sending inv peer=1580012 hash=000000000000000000009f27b05ec8d4a533b8ad61f670b8441e3a656a2ad084
```

-------------------------

Crypt-iQ | 2026-03-30 22:31:22 UTC | #5

I don’t have much to add here, but I think `95b0d0f836f18d78dfbae435fb37bf6fff2e37a4fc01c20be8495bc3ea4fbb58` could be a case of a neutrino light-client with a corrupted database. For some reason, I remember there being a few database corruption issues which would make sense since the hash is not a block hash. Maybe it could be a \`cfheader\` hash? Are those requests all from the same peer?

-------------------------

b10c | 2026-03-31 11:42:52 UTC | #6

Good point. I didn't notice this while initially looking at the data, but all of these `95b0d0f836f18d78dfbae435fb37bf6fff2e37a4fc01c20be8495bc3ea4fbb58` hashes come from 176.126.84.91. The first connection I've logged is from 2025-08-29.

-------------------------

davidgumberg | 2026-04-01 22:05:59 UTC | #7

The reason why all the nodes have the same version message is that neutrino has not updated it's version message since 0.12.0

Current master:

https://github.com/lightninglabs/neutrino/blob/93548a77b8137569ac3e5e3aa08c6b1ac414d844/neutrino.go#L53

-------------------------

randomlogin | 2026-05-10 13:29:40 UTC | #8

I experience the exactly same behaviour with kyoto ( https://github.com/2140-dev/kyoto ) : it asks for filters for already advertised block hashed, but filters have not yet been constructed, thus bitcoin core does not respond and gets banned.

It seems this error is more common during initial sync, a race condition window there is probably bigger (if a node downloaded all blocks, validates them, then ready to advertise and only then constructs filters, but I’m not sure it works like that).

Signet example:


`2026-05-07T19:00:25Z CreateNewBlock(): block weight: 884 txs: 0 fees: 0 sigops 400`
`2026-05-07T19:00:25Z Saw new header hash=71b15f879c48bfaa6413662f7a54186fa19c0637fdb93d6c5c3920cd9573dd26 height=6`
`2026-05-07T19:00:25Z UpdateTip: new best=71b15f879c48bfaa6413662f7a54186fa19c0637fdb93d6c5c3920cd9573dd26 height=6 version=0x20000000 log2_work=3.807355 tx=7 date=‘2026-05-07T19:00:26Z’ progress=1.000000 cache=0.3MiB(6txo)`
`2026-05-07T19:00:25Z CreateNewBlock(): block weight: 884 txs: 0 fees: 0 sigops 400`
`2026-05-07T19:00:25Z Saw new header hash=0d67555c6555a14f096bd77cf0981fe6e836452e2bbae1382c3252885200ea88 height=7`
`2026-05-07T19:00:25Z [default] AddToWallet c780d2ba32bd80b86d57e18f45062281b048ddbe090c700e18cec4b98921fd43  new Confirmed (block=2e3bd9faadeb6999f4cb4e159c5578663032daf97b824e28e88a67acdd532a66, height=2, index=0)`
`2026-05-07T19:00:25Z [net] SendMessages: sending header 2e3bd9faadeb6999f4cb4e159c5578663032daf97b824e28e88a67acdd532a66 to peer=0`
`2026-05-07T19:00:25Z [net] sending headers (82 bytes) peer=0`
`2026-05-07T19:00:25Z [net] SendMessages: sending header 2e3bd9faadeb6999f4cb4e159c5578663032daf97b824e28e88a67acdd532a66 to peer=1`
`2026-05-07T19:00:25Z [net] sending headers (82 bytes) peer=1`
`2026-05-07T19:00:25Z [net] received: getheaders (101 bytes) peer=0`
`2026-05-07T19:00:25Z [net] getheaders 2 to end from peer=0`
`2026-05-07T19:00:25Z [net] sending headers (406 bytes) peer=0`
`2026-05-07T19:00:25Z [net] received: getheaders (101 bytes) peer=1`
`2026-05-07T19:00:25Z [net] getheaders 2 to end from peer=1`
`2026-05-07T19:00:25Z [net] sending headers (406 bytes) peer=1`
`2026-05-07T19:00:25Z [net] received: getheaders (165 bytes) peer=0`
`2026-05-07T19:00:25Z [net] getheaders 3 to end from peer=0`
`2026-05-07T19:00:25Z [net] sending headers (325 bytes) peer=0`
`2026-05-07T19:00:25Z [net] received: getheaders (165 bytes) peer=1`
`2026-05-07T19:00:25Z [net] getheaders 3 to end from peer=1`
`2026-05-07T19:00:25Z [net] sending headers (325 bytes) peer=1`
`2026-05-07T19:00:25Z [net] received: getcfheaders (37 bytes) peer=1`
`2026-05-07T19:00:25Z [net] Failed to find block filter hashes in index: filter_type=basic, start_height=2, stop_hash=71b15f879c48bfaa6413662f7a54186fa19c0637fdb93d6c5c3920cd9573dd26`
`2026-05-07T19:00:25Z [net] received: getcfheaders (37 bytes) peer=0`
`2026-05-07T19:00:25Z [net] Failed to find block filter hashes in index: filter_type=basic, start_height=2, stop_hash=71b15f879c48bfaa6413662f7a54186fa19c0637fdb93d6c5c3920cd9573dd26`

-------------------------

