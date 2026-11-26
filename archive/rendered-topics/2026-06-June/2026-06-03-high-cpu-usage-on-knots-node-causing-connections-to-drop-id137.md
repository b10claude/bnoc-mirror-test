# High CPU usage on Knots node causing connections to drop

b10c | 2026-06-03 21:54:40 UTC | #1

As part of my [peer.observer](https://public.peer.observer) Bitcoin node monitoring infrastructure I'm running a `v29.3.knots20260508` Knots node with the name `nico`. 

I noticed that on 2026-05-28 at around 20:30 UTC the inbound connections this node had started to drop. At the same time, the CPU usage increased.


![image|690x450](upload://9LZ6x9uDAGtc4ScmIv4VBIGNsEV.png)


edit: to be clear: all other nodes were fine during this period, but this doesn't mean this is a problem specific to Knots - it could also be a problem caused by parts of the codebase that's shared between the projects. At the moment, I run (and pay for) one Knots node for monitoring.

-------------------------

b10c | 2026-06-03 16:21:59 UTC | #2

At the same time, the localhost Bitcoin Protocol ping-pong duration on this node increased, which is usually a sign that the node isn't able to keep up with message processing. This will cause connections to drop after a while.

![image|690x229](upload://6JDDVtZdi3oAw0Fau72TJfLSvYB.png)

-------------------------

b10c | 2026-06-03 21:57:35 UTC | #3

Interestingly, the CPU usage of the `net` and `msghand` threads dropped (likely due to fewer peers) and a while later (the first time at 21:15 UTC), the `bitcoind` thread usage increased and stayed elevated for a while. This is different behavior from e.g. https://bitcoincore.org/en/2024/10/08/disclose-large-inv-to-send/, where the CPU usage was in `msghand`. 

![image|690x402](upload://1IJPc5qo6v96MhvMBv3jncH3aQb.png)


I have a debug.log of this node, and will dig through it a bit more, but haven't found anything special yet. I'll also look into having continues profiling data available for this node incase it happens again.

-------------------------

b10c | 2026-06-04 10:55:14 UTC | #4

There seem to have been elevated, but not high, disk reads and writes during the high CPU usage. The spikes in disk io before and after the high CPU usage are likely leveldb disk compactions.

![image|690x492](upload://k9hwM1wuNH1OsVgIH6oh0NTSV5i.jpeg)
 
The `bitcoind` (unnamed) thread does handle leveldb compaction.

-------------------------

b10c | 2026-06-08 20:36:09 UTC | #5

To get a better overview over the debug.log file, I ran it through a work-in-progress debug.log log message template extraction tool I'm hacking on. See more: https://github.com/peer-observer/peer-observer/issues/336#issuecomment-4648428261

Here are the counts and templates in the log on the 28th:

<details>
<summary>templates: debug.log-20260528-nico.gz</summary>

```
=== addrman ===
 14492 Selected <IPv4:PORT> from <*>
  2141 Removed <IPv4:PORT> from new [ <INT> ] [ <INT> ]
  2004 Added <IPv4:PORT> to new [ <INT> ] [ <INT> ]
  1991 Selected <IPv6:PORT> from new
  1956 Added <INT> addresses ( of <INT> ) from <IPv4> : <INT> tried , <INT> new
   755 Added <IPv6:PORT> to new [ <INT> ] [ <INT> ]
   616 Removed <IPv6:PORT> from new [ <INT> ] [ <INT> ]
     9 Moved <IPv4:PORT> to tried [ <INT> ] [ <INT> ]
     8 Collision with <IPv4:PORT> while attempting to move <IPv4:PORT> to tried table. Collisions = <INT>
     6 Unable to test; replacing <IPv4:PORT> with <IPv4:PORT> in tried table anyway
     6 Moved <IPv4:PORT> from tried [ <INT> ] [ <INT> ] to new [ <INT> ] [ <INT> ] to make space
     1 GetAddr returned <INT> random addresses

=== bench ===
   501 - Connect <*> : <DUR> [ <DUR> ( <DUR> / blk ) ]
   168 - Using cached block
   168 - Load block from disk : <DUR>
   168 - Sanity checks : <DUR> [ <DUR> ( <DUR> / blk ) ]
   168 - Fork checks : <DUR> [ <DUR> ( <DUR> / blk ) ]
   167 - Connect <INT> transactions : <DUR> ( <DUR> / tx , <DUR> / txin ) [ <DUR> ( <DUR> / blk ) ]
   167 - Verify <INT> txins : <DUR> ( <DUR> / txin ) [ <DUR> ( <DUR> / blk ) ]
   167 - Write undo data : <DUR> [ <DUR> ( <DUR> / blk ) ]
   167 - Index writing : <DUR> [ <DUR> ( <DUR> / blk ) ]
   167 - Flush : <DUR> [ <DUR> ( <DUR> / blk ) ]
   167 - Writing chainstate : <DUR> [ <DUR> ( <DUR> / blk ) ]
    54 FlushStateToDisk : find files to prune started
    54 FlushStateToDisk : find files to prune completed ( <DUR> )
    23 FlushStateToDisk : write block and undo data to disk started
    23 FlushStateToDisk : write block and undo data to disk completed ( <DUR> )
    23 FlushStateToDisk : write block index to disk started
    23 FlushStateToDisk : write block index to disk completed ( <DUR> )
    23 FlushStateToDisk : write coins cache to disk ( <INT> coins , <*> ) started
    23 FlushStateToDisk : write coins cache to disk ( <INT> coins , <*> ) completed ( <DUR> )
     2 FlushStateToDisk : unlink pruned files started
     2 FlushStateToDisk : unlink pruned files completed ( <DUR> )

=== cmpctblock ===
   430 Initialized PartiallyDownloadedBlock for block <HASH> using a cmpctblock of size <INT>
   165 Successfully reconstructed block <HASH> with <INT> txn prefilled , <INT> txn from mempool ( incl at least <INT> from extra pool ) and <INT> txn requested
     5 Reconstructed block <HASH> required tx <HASH>

=== mempool ===
287006 AcceptToMemoryPool : <PEER> : accepted <HASH> ( wtxid = <HASH> ) ( poolsz <INT> txn , <INT> kB )
 12074 replacing mempool tx <HASH> ( wtxid = <HASH> , fees = <INT> , vsize = <INT> ) . New tx <HASH> ( wtxid = <HASH> , fees = <INT> , vsize = <INT> )
 10654 replaced <INT> mempool transactions with <INT> new transaction for <INT> additional fees , <INT> delta bytes
   509 not keeping orphan with rejected parents <HASH> ( wtxid = <HASH> )
     7 replacing mempool tx <HASH> ( wtxid = <HASH> , fees = <INT> , vsize = <INT> ) . New package <HASH> with <INT> txs , fees = <INT> , vsize = <INT>
     6 replaced <INT> mempool transactions with <INT> new one ( s ) for <INT> additional fees , <INT> delta bytes

=== mempoolrej ===
1801255 <HASH> ( wtxid = <HASH> ) from <PEER> was not accepted : <*>
 16548 <HASH> ( wtxid = <HASH> ) from <PEER> was not accepted : min relay fee not met , <INT> < <INT>
  1609 <HASH> ( wtxid = <HASH> ) from <PEER> was not accepted : insufficient fee , rejecting replacement <HASH> , not enough additional fees to relay; <FLOAT> < <FLOAT>
   344 <HASH> ( wtxid = <HASH> ) from <PEER> was not accepted : insufficient fee , rejecting replacement <*> new feerate <FLOAT> BTC / kvB < = old feerate <FLOAT> BTC / kvB
    49 <HASH> ( wtxid = <HASH> ) from <PEER> was not accepted : too-long-mempool-chain , too many unconfirmed ancestors [ limit : <INT> ]
    45 <HASH> ( wtxid = <HASH> ) from <PEER> was not accepted : insufficient fee , rejecting replacement <HASH> , less fees than conflicting txs; <FLOAT> < <FLOAT>
     1 <HASH> ( wtxid = <HASH> ) from <PEER> was not accepted : too-long-mempool-chain , too many descendants for tx <HASH> [ limit : <INT> ]

=== msghand ===
 39786 New inbound <*> peer connected : version : <INT> , blocks = <INT> , <PEER> , peeraddr = <IPv4:PORT>
  1511 New outbound-full-relay <*> peer connected : version : <INT> , blocks = <INT> , <PEER> , peeraddr = <IPv4:PORT>
   168 Saw new header hash = <HASH> <HEIGHT>
   162 UpdateTip : new best = <HASH> <HEIGHT> version = <HEX> log2_work = <FLOAT> tx = <INT> date = ' <*> ' progress = <FLOAT> cache = <*> ( <*> ) warning = ' Miner violated version bit protocol '
    64 Saw new cmpctblock header hash = <HASH> <PEER>
     5 UpdateTip : new best = <HASH> <HEIGHT> version = <HEX> log2_work = <FLOAT> tx = <INT> date = ' <*> ' progress = <FLOAT> cache = <*> ( <*> )
     2 Outbound peer has old chain , best known block = <HASH> , disconnecting <PEER> peeraddr = <IPv4:PORT>

=== net ===
17258897 got inv : <*> <HASH> <*> <PEER>
6432576 received : <*> ( <BYTES> ) <PEER>
2869594 Requesting tx <HASH> <PEER>
2304136 sending getdata ( <BYTES> ) <PEER>
1770200 sending tx ( <BYTES> ) <PEER>
1368625 sending inv ( <BYTES> ) <PEER>
639118 Requesting wtx <HASH> <PEER>
545454 received getdata ( <INT> invsz ) <PEER>
545454 received getdata for : <*> <HASH> <PEER>
145684 sending addrv2 ( <BYTES> ) <PEER>
137282 Received addr : <INT> addresses ( <INT> processed , <INT> rate-limited ) from <PEER>
136204 Resetting socket for <PEER> peeraddr = <IPv4:PORT>
136197 Cleared nodestate for <PEER>
136139 Added connection to <IPv4:PORT> <PEER>
130380 connection from <IPv4:PORT> accepted
127729 timeout of inflight <*> <HASH> from <PEER>
120527 sending ping ( <BYTES> ) <PEER>
 96391 sending pong ( <BYTES> ) <PEER>
 94681 selected inbound connection for eviction , disconnecting <PEER> peeraddr = <IPv4:PORT>
 94307 sending version ( <BYTES> ) <PEER>
 94307 send version message : version <INT> , blocks = <INT> , them = <IPv4:PORT> , txrelay = <INT> , <PEER>
 91518 sending wtxidrelay ( <BYTES> ) <PEER>
 91518 sending sendaddrv2 ( <BYTES> ) <PEER>
 90716 sending verack ( <BYTES> ) <PEER>
 41020 receive version message : <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> , txrelay = <INT> , <PEER> , peeraddr = <IPv4:PORT>
 40964 sending sendcmpct ( <BYTES> ) <PEER>
 40847 sending feefilter ( <BYTES> ) <PEER>
 40497 sending getheaders ( <BYTES> ) <PEER>
 40453 initial getheaders ( <INT> ) to <PEER> ( <*> )
 33264 receive version message : / <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> , txrelay = <INT> , <PEER> , peeraddr = <IPv4:PORT>
 29112 socket recv error , disconnecting <PEER> peeraddr = <IPv4:PORT> : <*> <*> <*> <*> ( <INT> )
 15059 sending addr ( <BYTES> ) <PEER>
 13022 trying v2 connection <*> lastseen = <*>
 12610 sending headers ( <BYTES> ) <PEER>
  9449 receive version message : <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> , txrelay = <INT> , <PEER> , peeraddr = <IPv4:PORT>
  8244 socket closed , disconnecting <PEER> peeraddr = <IPv4:PORT>
  7904 getheaders <INT> to end from <PEER>
  6251 connection attempt to <IPv4:PORT> timed out
  5329 sending notfound ( <BYTES> ) <PEER>
  5190 Advertising address <*> to <PEER>
  4695 SendMessages : sending header <HASH> to <PEER>
  4586 receive version message : / <*> <*> <*> <*> <*> / : version <INT> , blocks = <INT> , us = <IPv4:PORT> , txrelay = <INT> , <PEER> , peeraddr = <IPv4:PORT>
  4497 start sending v2 handshake to <PEER>
  3273 SendMessages : sending inv <PEER> hash = <HASH>
  3223 sending sendheaders ( <BYTES> ) <PEER>
  3040 received : feefilter of <FLOAT> BTC / kvB from <PEER>
  2403 peer lacks NODE_REDUCED_DATA and already have <INT> non-BIP110 outbound peers ( limit <INT> ) , disconnecting <PEER> peeraddr = <IPv4:PORT>
  2294 trying v1 connection <*> lastseen = <*>
  2276 receive version message : / <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> , txrelay = <INT> , <PEER> , peeraddr = <IPv4:PORT>
  1986 connect ( ) to <IPv6:PORT> failed : Network is unreachable ( <INT> )
  1614 sending getaddr ( <BYTES> ) <PEER>
  1614 Added time offset <DUR> , total samples <INT>
  1081 setting try another outbound <*>
  1076 disconnecting extra outbound <PEER> ( last block announcement received at time <INT> )
  1037 Ignoring repeated "getaddr". <PEER>
   928 retrying with v1 transport protocol for <PEER>
   870 pcp : Timeout
   788 sending cmpctblock ( <BYTES> ) <PEER>
   697 connect ( ) to <IPv4:PORT> failed after wait : Connection refused ( <INT> )
   678 PeerManager::NewPoWValidBlock sending header-and-ids <HASH> to <PEER>
   622 connect ( ) to <IPv4:PORT> failed after wait : No route to host ( <INT> )
   580 pcp : Retrying ( <INT> )
   521 keeping outbound <PEER> chosen for eviction ( connect time : <INT> , blocks_in_flight : <INT> )
   451 sending alert ( <BYTES> ) <PEER>
   364 sending getblocktxn ( <BYTES> ) <PEER>
   299 version handshake timeout , disconnecting <PEER> peeraddr = <IPv4:PORT>
   290 portmap : gateway [ IPv4 ] : <IPv4>
   290 pcp : Requesting port mapping for addr <IPv4> port <INT> from gateway <IPv4>
   290 pcp : Internal address after connect : <IPv4>
   290 pcp : Giving up after <INT> tries
   290 portmap : Could not determine IPv6 default gateway
   261 socket no message in first <INT> seconds , never <*> <*> peer , disconnecting <PEER> peeraddr = <IPv4:PORT>
   209 Peer <INT> sent us block transactions for block we weren ' t expecting
   128 connected to non-BIP110 outbound peer ( <INT> / <INT> ) , outbound-full-relay
   104 Requesting block <HASH> from <PEER>
    97 Flushed <INT> addresses to peers.dat <DUR>
    92 peer does not offer the expected services ( <*> offered , <INT> expected ) , disconnecting <PEER> peeraddr = <IPv4:PORT>
    77 receive version message : / <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> <*> , txrelay = <INT> , <PEER> , peeraddr = <IPv4:PORT>
    76 sending blocktxn ( <BYTES> ) <PEER>
    71 sending block ( <BYTES> ) <PEER>
    35 socket send error , disconnecting <PEER> peeraddr = <IPv4:PORT> : <*> <*> <*> <*> ( <INT> )
    31 sendtxrcncl from <PEER> ignored , as our node does not have txreconciliation enabled
    31 more getheaders ( from <HASH> ) to <PEER>
    31 ping timeout : <DUR> , disconnecting <PEER> peeraddr = <IPv4:PORT>
    28 socket recv error , disconnecting <PEER> peeraddr = <IPv4:PORT> : Connection timed out ( <INT> )
    26 socket send error , disconnecting <PEER> peeraddr = <IPv4:PORT> : Connection timed out ( <INT> )
    24 sendaddrv2 received after verack , disconnecting <PEER> peeraddr = <IPv4:PORT>
    20 receive version message : <*> : version <INT> , blocks = <INT> , us = <IPv4:PORT> , txrelay = <INT> , <PEER> , peeraddr = <IPv4:PORT>
    19 socket no message in first <INT> seconds , never received from peer , never sent to peer , disconnecting <PEER> peeraddr = <IPv4:PORT>
    16 receive version message : / Satoshi:29.3.0 ( <*> <*> <*> <*> <*> <*> <*> <*> <*> / <*> / : version <INT> , blocks = <INT> , us = <IPv4:PORT> , txrelay = <INT> , <PEER> , peeraddr = <IPv4:PORT>
    15 received block <HASH> <PEER>
    12 socket send error , disconnecting <PEER> peeraddr = <IPv4:PORT> : Broken pipe ( <INT> )
    11 Protecting outbound <PEER> from eviction
    11 SendMessages : <INT> headers , range ( <HASH> , <HASH> ) , to <PEER>
     9 wtxidrelay received after verack , disconnecting <PEER> peeraddr = <IPv4:PORT>
     8 more getheaders ( <INT> ) to end to <PEER> ( startheight:443555 )
     7 pong <PEER> : <*> <*> , <*> expected , <*> received , <BYTES>
     7 Unknown command <*> from <PEER>
     5 sending getheaders to outbound <PEER> to verify chain work ( current best known <*> , benchmark blockhash : <HASH> )
     4 ignoring redundant verack message from <PEER>
     4 Ignore block request below NODE_NETWORK_LIMITED threshold , disconnecting <PEER> peeraddr = <IPv4:PORT>
     3 connect ( ) to <IPv4:PORT> failed after wait : Network is unreachable ( <INT> )
     3 Initial headers sync started with <PEER> : <HEIGHT> , max_commitments = <INT> , min_work = <HASH>
     3 getblocks <INT> to <HASH> limit <INT> from <PEER>
     3 getblocks stopping , pruned or too old block at <INT> <HASH>
     3 V2 handshake timeout , disconnecting <PEER> peeraddr = <IPv4:PORT>
     2 socket receive timeout : <DUR> , disconnecting <PEER> peeraddr = <IPv4:PORT>
     2 connection from <IPv4:PORT> dropped ( discouraged )
     1 Unsupported message "ping" prior to verack from <PEER>

=== scheduler ===
    24 Flushed fee estimates to fee_estimates.dat.
     5 Potential stale tip detected , will try using extra outbound peer ( last tip update : <INT> seconds ago )

=== txpackages ===
16983663 added <PEER> as a candidate for resolving orphan <HASH>
15193511 added <PEER> as announcer of orphan tx <HASH>
1790221 removed orphan tx <HASH> ( wtxid = <HASH> ) after <DUR>
1790152 stored orphan tx <HASH> ( wtxid = <HASH> ) , weight : <INT> ( mapsz <INT> outsz <INT> )
1774469 orphanage overflow , removed <INT> tx
  5660 added <HASH> ( wtxid = <HASH> ) to peer <INT> workset
  5392 accepted orphan tx <HASH> ( wtxid = <HASH> )
  3773 found tx <HASH> ( wtxid = <HASH> ) in reconsiderable rejects , looking for child in orphanage
  1859 tx <HASH> ( wtxid = <HASH> ) failed but reconsiderable , looking for child in orphanage
   181 removed orphan tx <HASH> ( wtxid = <HASH> )
   155 invalid orphan tx <HASH> ( wtxid = <HASH> ) from <*> txn-datacarrier-nonstandard
   154 Erased <INT> orphan transaction ( s ) included or conflicted by block
   147 package evaluation for parent <HASH> ( wtxid = <HASH> , sender = <INT> ) + child <HASH> ( wtxid = <HASH> , sender = <INT> ) : package <*>
    80 Erased <INT> orphan transaction ( s ) from <PEER>
    16 Erased <INT> orphan tx due to expiration
     7 invalid orphan tx <HASH> ( wtxid = <HASH> ) from <*> min relay fee not met , <INT> < <INT>
     6 package RBF checks passed : parent <HASH> ( wtxid = <HASH> ) , child <HASH> ( wtxid = <HASH> ) , package hash ( <HASH> )
     4 invalid orphan tx <HASH> ( wtxid = <HASH> ) from <*> too-long-mempool-chain , too many unconfirmed ancestors [ limit : <INT> ]
     1 invalid orphan tx <HASH> ( wtxid = <HASH> ) from peer=497549. insufficient fee , rejecting replacement ad9831cae2eed43505daa705ca345a4820dcaa523ea3ada6dbcca76521e287ff; new feerate <FLOAT> BTC / kvB < = old feerate <FLOAT> BTC / kvB

=== validation ===
287006 Enqueuing TransactionAddedToMempool : txid = <HASH> wtxid = <HASH>
287006 TransactionAddedToMempool : txid = <HASH> wtxid = <HASH>
 12802 Enqueuing TransactionRemovedFromMempool : txid = <HASH> wtxid = <HASH> reason = <*>
 12802 TransactionRemovedFromMempool : txid = <HASH> wtxid = <HASH> reason = <*>
   168 NewPoWValidBlock : block hash = <HASH>
   167 BlockChecked : block hash = <HASH> state = Valid
   167 Enqueuing MempoolTransactionsRemovedForBlock : block <HEIGHT> txs removed = <INT>
   167 MempoolTransactionsRemovedForBlock : block <HEIGHT> txs removed = <INT>
   167 Enqueuing BlockConnected : block hash = <HASH> block <HEIGHT>
   167 Enqueuing UpdatedBlockTip : new block hash = <HASH> fork block hash = <HASH> ( in IBD = false )
   167 ActiveTipChange : new block hash = <HASH> block <HEIGHT>
   167 BlockConnected : block hash = <HASH> block <HEIGHT>
   167 UpdatedBlockTip : new block hash = <HASH> fork block hash = <HASH> ( in IBD = false )
    54 Pre-allocating up to position <HEX> in <*>
    23 Enqueuing ChainStateFlushed : block hash = <HASH>
    23 ChainStateFlushed : block hash = <HASH>
```

</details>
 
Nothing besides maybe `127729   timeout of inflight <*> <HASH> from <PEER>` stands out to me directly. This seems however to be an effect, not the cause.

-------------------------

b10c | 2026-06-10 22:37:39 UTC | #6

I've been asked out-of-band for the configuration of this node. Posting it here to have it all in one place. I've stripped the RPC auth information.

```
chain=main
[main]

prune=4000

logips=1
logthreadnames=1
logtimemicros=1
rest=1
server=1

debug=net
debug=addrman
debug=cmpctblock
debug=mempoolrej
debug=validation
debug=bench
debug=txpackages
debug=mempool
debug=leveldb

printtoconsole=0
```

-------------------------

b10c | 2026-06-12 07:52:54 UTC | #7

I've set the node up with continues profiling (using https://github.com/mstange/samply) and enabled `debug=leveldb` on all nodes. If it happens again, we'll have more data to dig into it. As of now, I don't think we can find out much more about the root cause from the data that we have.

-------------------------

