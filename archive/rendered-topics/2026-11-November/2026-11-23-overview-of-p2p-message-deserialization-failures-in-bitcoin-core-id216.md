# Overview of P2P message deserialization failures in Bitcoin Core

b10c | 2026-11-23 20:32:53 UTC | #1

I was recently asked how common deserialization failures of received P2P messages on Bitcoin Core nodes are. I looked through my [debug-logs](https://bnoc.xyz/t/offer-detailed-bitcoin-core-node-debug-logs-2024/36) for this. I will post them as comments here to make it easier to link to one specific observation.

-------------------------

b10c | 2026-11-24 04:44:24 UTC | #2

## empty `addrv2` messages

These were by far the most commonly observed ones. I first saw them in early February 2024 when I started keeping logs and they ended in 2025-03-13. They are logged similar to:

```
[ProcessMessage] [net] received: addrv2 (0 bytes) peer=XYZ
[ProcessMessages] [net] ProcessMessages(addrv2, 0 bytes): Exception 'DataStream::read(): end of data: iostream error' (NSt8ios_base7failureB5cxx11E) caught
```

Normally, the addrv2 message is an array of address elements. It should include a count of addresses followed by the addresses. Here it does not contain a count and no addresses.

These were primarily from a client with the user agent `/nodes.mom.market:0.2/` (also seen as `/nodes.mom.market.io:0.2/`) from `94.237.44.67` and `2a04:3544:1000:1510:b08f:6fff:fe1b:3007`. I saw these on all of my nodes. nodes.mom.market seems to have been doing some sort of network monitoring and listed node-counts on their website. See https://web.archive.org/web/20240805133530/https://nodes.mom.market/.

(edit: an earlier version of this post claimed that these likely came from bitnodes-io software, which was incorrect. I removed it).

---

Followup question that came to mind: Is there someone that sent a valid addrv2 message with a count of zero elements? I think these would not fail deserialization.

-------------------------

b10c | 2026-11-23 23:39:31 UTC | #3

## empty `addr` messages

I saw about 85k of these on 2024-12-02 and 2024-12-03 from a client with the user agent `semikek` from `46.250.250.117` and `2400:d320:2227:8537::1`. 


```
[net] received: addr (0 bytes) peer=842
[net] ProcessMessages(addr, 0 bytes): Exception 'DataStream::read(): end of data: iostream error' (NSt8ios_base7failureB5cxx11E) caught
```


Their behavior is as follows:

* It connects inbound over v1 with protocol 70016, the correct current height, and transaction relay on.
* It sends `sendaddrv2`, announcing `addrv2` support, but then only sends legacy `addr` messages
* Every received 1-address `addr` (31 bytes) is immediately followed by an empty `addr` message (this looks like it splits a list with one element into two chunks and sends an empty chunk)
* It answers our `ping` with the nonce byte-reversed. Bitcoin Core never gets a valid pong, so it drops the peer after the 20-minute ping timeout

I don't know which addresses it announced to us on these two days.

We've previously seen a [client](https://github.com/Charterino/bitlens-rs) with the user-agent `semikek` in https://bnoc.xyz/t/two-block-reorg-at-height-941880/97/26 - however the [first commit ](https://github.com/Charterino/bitlens-rs/commit/a85a47dfcde839eb215d426c96d3967c25858613)in that repository is from June 2025 (about seven months after the observation).

-------------------------

b10c | 2026-11-24 00:15:10 UTC | #4

### Non-canonical CompactSize `tx`

From 2026-10-03 04:36 to 2026-10-05 14:25 UTC, 11 of my nodes received about 4.8 million `tx` messages, all exactly 83 bytes, from a single IP: `178.220.163.###` (AS8400, an ISP in Serbia) with the user agent `/Satoshi:28.0.0/`. All of them failed deserialization.

```
[net] received: tx (83 bytes) peer=XYZ
[net] ProcessMessages(tx, 83 bytes): Exception 'non-canonical ReadCompactSize(): iostream error' (NSt8ios_base7failureB5cxx11E) caught
```

A CompactSize must use the shortest possible encoding. For example, a length of 1 has to be `01`, not `fd0100`. Otherwise `ReadCompactSize()` throws:
https://github.com/bitcoin/bitcoin/blob/dbe9eacd17ae1cc24581081613123a40b44a9f31/src/serialize.h#L326-L333

The peer made 83 inbound v1 connections to my nodes. On one of them, it first completed a normal handshake, announced a transaction, and sent a valid 234-byte `tx`. About a minute later it started sending the 83-byte messages. That connection stayed open for 46 hours and delivered about 2 million of them (around 12 per second).

Which field was malformed is unknown, as the raw transaction was not logged. It could be any CompactSize in a transaction: the input or output count, a `scriptSig` or `scriptPubKey` length, or a witness item count or length.

This doesn't look like the first time. Since November 2024, I've seen smaller amounts of malformed `tx` messages (mostly truncated) with the user agents `/Satoshi:28.0.0/` and `/Satoshi/` from `93.86.147.###` (same AS, 2024-11) and `178.220.97.###` (same AS, 2025-08). On 2026-10-18, `178.220.163.###` came back with about 21.7k 129-byte `tx` messages that failed with `DataStream::read(): end of data` and `ReadCompactSize(): size too large`.

-------------------------

edilmedeiros | 2026-11-24 16:14:36 UTC | #5

What a coincidence, last week I did a deep dive week session with the team and we mostly followed `ProcessMessage` processing paths (handshake, address relay and something on transaction processing). One thing that I put on my todo list was to check if the exception treatment on `ProcessMessages` was reporting useful/enough information; seems so, but maybe could be improved? I also wonder how many failures on deserialization of message headers (magic, command, length, checksum) we get.

-------------------------

b10c | 2026-11-24 18:34:55 UTC | #6

## `blocktxn` messages from `/Satoshi:0.20.1/`

Between at least 2024-02-10 and 2024-11-08, I saw about 550 `blocktxn` messages that failed deserialization, at most 11 per day. There were three different exceptions:

* `DataStream::read(): end of data` (about 280x)
* `Superfluous witness record` (about 170x)
* `Unknown transaction optional data` (about 100x)

```
[net] received: blocktxn (301 bytes) peer=XYZ
[net] ProcessMessages(blocktxn, 301 bytes): Exception 'DataStream::read(): end of data: iostream error' (NSt8ios_base7failureB5cxx11E) caught
```

Normally, a `blocktxn` message is the response to a `getblocktxn` request during compact block reconstruction ([BIP152](https://github.com/bitcoin/bips/blob/master/bip-0152.mediawiki)). These were not. The interaction with this client was:

1. We announce a new block header to the client
2. The client requests the compact block with a `getdata`
3. The `cmpctblock` is sent to the client
4. The client answers with a `blocktxn` message, which fails deserialization

A client that is missing transactions from a compact block should answer with a `getblocktxn`, not with a `blocktxn`. My guess is that these peers send their `getblocktxn` request with the wrong message type. A `getblocktxn` contains the block hash and a list of differentially encoded transaction indexes. If that list is parsed as transactions, an index difference of zero is read as the segwit marker and the following byte as the segwit flag. This would explain the `Superfluous witness record` and `Unknown transaction optional data` exceptions:

https://github.com/bitcoin/bitcoin/blob/f0de87f040621468b956f01f526a43a010310501/src/primitives/transaction.h#L223-L237

The sender for these messages was a client with the user agent `/Satoshi:0.20.1/` and protocol version 70015. These were mostly inbound connections (but some we also picked as outbounds) from many different IPs (93 different IPs for the 134 messages), and most IPs only sent a single failing message. The clients are hosted at cloud providers: mostly DigitalOcean, with some Hetzner and Google Cloud.

I wonder who is able to spin up a custom (and broken) client on close to 100 IPs. My suspection is a mining pool..?

This stopped after 2024-11-08.

-------------------------

