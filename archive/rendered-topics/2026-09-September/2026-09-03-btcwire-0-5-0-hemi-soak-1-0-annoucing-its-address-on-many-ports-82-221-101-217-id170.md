# /btcwire:0.5.0/hemi-soak:1.0/ annoucing its address on many ports (82.221.101.217)

stratospher | 2026-09-03 20:32:44 UTC | #1

I found it hard to believe the number of IP addresses received including duplicates rose to 460,241 addresses on 31 august in a node I was looking at.

Apparently 99.2% of all the addresses which got rate limited in net_processing in the node's debug.log (since it started) came from 1 ip address `82.221.101.217` which advertises it's own IP addresses on 67 different ports. It sends all addresses with services = 0, so none of them would enter the addrman anyways.

- addresses it sent:
    - from Aug 18 - 20: same ip address `82.221.101.217` on 20 contiguous different ports (so an ADDR message was 20 different addresses but it was the same IP on 20 different ports)
    - from Aug 20 onwards: same ip address `82.221.101.217` on 67 contiguous different ports from ports 8333–8399.
- frequency: 1 ADDR message every ~30 seconds.

I tried connecting to it:

- it's version message was `ver=70016  services=0000000000000000  height=1965166  ua='/btcwire:0.5.0/hemi-soak:1.0/'` and the height is roughly double the real network's \~964,600.
- all its ports were reachable but it disconnected me after \~30 seconds. (I haven't tried from a real node yet btw)

side note: this isn't responsible for the recent [increase in KIT's Unique Addresses per Day graph](https://www.dsn.kastel.kit.edu/bitcoin/#addresses) after mid-august since the graph doesn't count duplicates.

-------------------------

stratospher | 2026-09-03 20:35:14 UTC | #2

hmm probably software on some other chain accidentally connecting to us? [seeing this on bitnod.es](http://bitnod.es/node_explorer.php?user_agent=%2Fbtcwire%3A0.5.0%2Fhemi-soak%3A1.0%2F&sort=export_date&dir=desc). seems to have connected to other normal nodes as well.

EDIT: no idea and could 100% be wrong but maybe https://hemi.xyz

-------------------------

jonhbit | 2026-09-14 18:53:31 UTC | #3

I couldn't find that specific UA string in their repo, but it is referenced here:

https://github.com/hemilabs/heminetwork/pull/1174

And that project is definitely using btcd & related deps. in a few places, for light clients and/or full nodes of some sort.

-------------------------

stratospher | 2026-09-14 19:45:25 UTC | #4

oh wow, thanks for finding that UA! currently seeing 4,298,947 addresses from that IP address which got rate limited. maybe we should open an issue there.

EDIT: created an [issue](https://github.com/hemilabs/heminetwork/issues/1177)

-------------------------

stratospher | 2026-09-21 23:12:45 UTC | #5

![Screenshot 2026-09-21 at 7.04.30 PM|690x208](upload://f8fJTSk2WdGf4H71cBHxaBDSRG5.png)
we checked @b10c's peer-observer graphs and saw this IP disconnecting on 20 sep ~21:18 UTC across many nodes. :headstone: :blossom:

-------------------------

