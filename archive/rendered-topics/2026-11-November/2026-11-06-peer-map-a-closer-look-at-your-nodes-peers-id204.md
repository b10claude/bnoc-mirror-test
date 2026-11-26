# Peer Map: a closer look at your node's peers

benunskilled | 2026-11-06 10:27:25 UTC | #1

I build a peermap for my node and @b10c  suggested I share this here.

Peer Map labels every peer by what it does, not only by its user agent: the services it offers, its protocol version, whether it wants transactions, how often it pings or asks for addresses. A disguised peer shows why it got that label, and LinkingLion gets its own red pill. There's also a map, so you see where your peers are and how many sit at the same hosting company. It's an app for Umbrel, and everything runs locally, no peer address leaves the node.

Demo, a snapshot of my node with every address replaced:

https://peermap.xyz

Code: https://github.com/benunskilled/peer-map

Why I built it: I'm not a developer or a network researcher, just a home miner. My solo pool handed out new work more than a second after the public solo pools. Most of that turned out to be my old computer, but part of it was peers, so I started looking at which peer brought me each block first. Looking that closely, I kept finding peers that didn't seem to be what they claimed, like an old "Bitcoin Core" offering encryption Core only got years later, or a "Bitcoin Core" that keeps asking for addresses.
That turned into Peer Map.
So that’s where I am coming from, so please bear with me.
I only learned about bnoc a couple of weeks ago and appreciate it a lot. 
The labels are a best guess, so some will be wrong. If you know a client better, or see one that looks mislabeled, I'd like to hear it.
Any feedback or help is welcome!

-------------------------

stratospher | 2026-11-06 14:07:29 UTC | #2

this is super cool honestly! :fire:
1 question: how did you link tor exit IPs to wallets (wasabi or ginger)?

-------------------------

edilmedeiros | 2026-11-06 14:34:04 UTC | #3

[quote="benunskilled, post:1, topic:204"]
Why I built it: I’m not a developer or a network researcher, just a home miner. My solo pool handed out new work more than a second after the public solo pools. Most of that turned out to be my old computer, but part of it was peers, so I started looking at which peer brought me each block first.

[/quote]

The project is very interesting. Never underestimate what questions the curious mind of a service operator can ask.

Do you have any lessons learnt so far because of this observability effort you could share?

-------------------------

benunskilled | 2026-11-06 14:36:32 UTC | #4

Thank you so much. I don't link the exit IPs. The label comes from behaviour, the Tor exits only made me look closer. Peer Map spots exits with the Tor Project's exit list, which I bundle fresh with every release.

Wasabi picks one of 13 Core user agents at random per connection (Constants.UserAgents), Ginger uses Wasabi's older list of 31. Both use NBitcoin, so the handshake is just sendaddrv2 + verack: no wtxidrelay, no sendcmpct, no services, tx relay on. Peer Map only labels a peer as Wasabi or Ginger when the name and that handshake both match. Otherwise it stays Disguised. The list tells them apart: a name only on Ginger's list reads as Ginger, one on both lists as "Wasabi or Ginger".

On my node most of these came from Tor exits (73% Wasabi, 89% Ginger), but the rule doesn't use that.

-------------------------

benunskilled | 2026-11-06 14:41:58 UTC | #5

Thanks! Two things that surprised me:

* **Measure before blaming the peers.**  Raising blockmintxfee to 1 sat/vB saved about 0.75 s on my node, more than anything I did with peers.
* **User agents say little.** I'd run my node for years and never thought some of my peers might not be what they say. A lot of what calls itself Bitcoin Core isn't: wallets borrowing Core names (Wasabi, Ginger), crawlers, and fleets like the /Satoshi:31.0.0/ one. What a peer offers and asks for in the first minutes tells you much more than its name.

-------------------------

edilmedeiros | 2026-11-06 14:49:12 UTC | #6

Did you figure out an optimized setup based on this knowledge (e.g. banning nodes based on them being crawlers, etc)? Interested to hear if and how much connecting to a better mix of peers influences solo miners (and what "better mix" would even mean in this context).

-------------------------

benunskilled | 2026-11-06 14:56:45 UTC | #7

[quote="edilmedeiros, post:6, topic:204"]
Did you figure out an optimized setup based on this knowledge (e.g. banning nodes based on them being crawlers, etc)? Interested to hear if and how much connecting to a better mix of peers influences solo miners (and what “better mix” would even mean in this context)

[/quote]


I did not do any banning yet. In bitcoin lab I have that rotation and finding that one manual that now delivers 8/10 blocks helped the most timewise. If I disconnect him my average drops like 100ms at least, tried that. But looking for that one peer can take weeks. But I am keen trying more or using a banlist in the future

-------------------------

b10c | 2026-11-06 20:22:29 UTC | #8

[quote="benunskilled, post:4, topic:204"]
Wasabi picks one of 13 Core user agents at random per connection (Constants.UserAgents), Ginger uses Wasabi’s older list of 31. Both use NBitcoin, so the handshake is just sendaddrv2 + verack: no wtxidrelay, no sendcmpct, no services, tx relay on. Peer Map only labels a peer as Wasabi or Ginger when the name and that handshake both match. Otherwise it stays Disguised. The list tells them apart: a name only on Ginger’s list reads as Ginger, one on both lists as “Wasabi or Ginger”.

On my node most of these came from Tor exits (73% Wasabi, 89% Ginger), but the rule doesn’t use that.
[/quote]

Oh cool, I didn't know about the fake user-agents in Wasabi and Ginger

https://github.com/WalletWasabi/WalletWasabi/blob/e752515f9d08a35b405e28c5253110234234f2bc/WalletWasabi/Helpers/Constants.cs#L103-L118

https://github.com/GingerPrivacy/GingerWallet/blob/a881f1c4d2816a6164713bb2b1f7e948c4a80acf/WalletWasabi/Helpers/Constants.cs#L119-L152

-------------------------

benunskilled | 2026-11-06 20:40:06 UTC | #9

Glad it's useful! Peer Map keeps a copy of both lists, and I check them for changes before every release.

-------------------------

benunskilled | 2026-11-07 10:24:14 UTC | #10

> If I disconnect him my average drops like 100ms at least, tried that.

Coming back to the 100 ms: I wouldn't trust that number. I wasn't looking at compact blocks back then. Bitcoin Lab now tracks them, and since last night 7 of 42 blocks needed 300–800 kB of missing transactions via getblocktxn, all from AntPool, F2Pool, ViaBTC or SpiderPool (P2A runestone mints, similar to https://bnoc.xyz/t/198/11 ). That easily outweighs 100 ms.

@edilmedeiros my guess is the peer mix and quantity matters less than that, and on my old computer less than building the next template by far. Can't compare other hardware though. Need a few days for more reliable numbers

-------------------------

Antoine | 2026-11-16 18:53:58 UTC | #11

I'm curious how you estimate pools delay before switching to new work in the Stratum Race panel? How do you guess the time at which their node saw (or activated) a new block?

-------------------------

benunskilled | 2026-11-25 18:44:31 UTC | #12

Sorry Antoine, I only saw your question now.

It doesn't estimate either. It only measures when each pool's new job arrives at my node. Peer Lab keeps a stratum connection open to each pool, just listening, no hashing. The first mining.notify with a new prevhash is t=0 and every other pool is timed against that.


So "+40 ms" means that pool's job reached me 40 ms after the fastest one. That covers the block getting to their node, building the new job and the path from their server to me. 

What I use it for: my own solo pool runs on the same box, so I can see how fast it switches to a new block compared to the public pools.

-------------------------

