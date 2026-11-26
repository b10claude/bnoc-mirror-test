# Any reachable node receiving tx announcement via `MSG_WITNESS_TX`?

Antoine | 2026-08-10 17:47:25 UTC | #1

Bitcoin Core contributors are [discussing](https://github.com/bitcoin/bitcoin/pull/35920) ignoring transaction announcements that use `MSG_WITNESS_TX` INV types. That type was only defined for GETDATA’s in [BIP 144](https://github.com/bitcoin/bips/blob/master/bip-0144.mediawiki#relay), but Bitcoin Core has supported its use in INV’s ever since the Segwit implementation was merged.

I’d like to make reasonably sure that there isn’t an application out there that came to rely on it. A quick way to check using [AJ’s snippet](https://github.com/bitcoin/bitcoin/pull/35920#discussion_r3739650033):

```bash
grep got.inv: /path/to/debug.log | cut -d" "  -f5 | awk '{c[$0]++} END {for (l in c) printf "%8d %s\n", c[l], l}'
```

Would appreciate if anybody with a long-running reachable node could share the result of the above command.

-------------------------

b10c | 2026-08-10 19:12:23 UTC | #2

Short answer: yes, someone is using this. I primarily see it on my `-bloomfilter=1` node `alice`, but others see it too from time to time.

![image|690x329](upload://cdvFe33bgdDdozuIDNAIZ5rvRta.png)


I'll check which client / UA is sending these.

-------------------------

ajtowns | 2026-08-10 19:42:37 UTC | #3

Probably would be useful to know if the txs they announce are real, have witness data, and if the hash provided matches the txid or the wtxid in practice.

-------------------------

Antoine | 2026-08-11 15:48:22 UTC | #4

[quote="b10c, post:2, topic:159"]
`-bloomfilter=1`

[/quote]

I had a quick look at bitcoinj, and it looks like they are not the culprit here, since they just bypass normal transaction relay and [send transactions unannounced](https://github.com/bitcoinj/bitcoinj/blob/328da890c4cdd6d92685223428ec930576251369/core/src/main/java/org/bitcoinj/core/TransactionBroadcast.java#L145-L152).

-------------------------

b10c | 2026-08-12 14:59:42 UTC | #5

I've only sampled/tracked down a few peers who send this yet, but a few seem to be `/btcwire:0.5.0/neutrino:0.12.0-beta/`. Neutrino seems to be setting the `INV` to `InvTypeWitnessTx` in `sendTransaction()`.

https://github.com/lightninglabs/neutrino/blob/c96685a023c6946be7d463541b49e0f37f527982/query.go#L951-L969

-------------------------

b10c | 2026-08-13 08:25:44 UTC | #6

[quote="Antoine, post:4, topic:159, full:true"]
[quote="b10c, post:2, topic:159"]
`-bloomfilter=1`
[/quote]

I had a quick look at bitcoinj, and it looks like they are not the culprit here, since they just bypass normal transaction relay and [send transactions unannounced](https://github.com/bitcoinj/bitcoinj/blob/328da890c4cdd6d92685223428ec930576251369/core/src/main/java/org/bitcoinj/core/TransactionBroadcast.java#L145-L152).
[/quote]

In hindsight: the node also serves compact block filters, that's why the neutrino clients are connecting to it. My first guess was bitcoinj too.

-------------------------

