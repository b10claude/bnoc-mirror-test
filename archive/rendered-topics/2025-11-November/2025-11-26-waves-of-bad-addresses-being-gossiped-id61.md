# Waves of (bad) addresses being gossiped

b10c | 2025-11-26 21:05:15 UTC | #1

I recently re-observed something I previously looked into in 2023. Every couple of hours, at seemingly random intervals and times, my peers (i.e. the whole network) starts sending a spike in addresses. When I looked into it in 2023, these were mostly "bad" (i.e. i couldn't connect to them). 

I re-observed this when looking at the rate of addresses my Bitcoin Core nodes announces to the peer-observer custom measurement client ([p2p-extractor](https://github.com/peer-observer/peer-observer/tree/master/extractors/p2p)). All of my nodes, which aren't connected to each other, spiked in addresses gossiped to the p2p-extractor (which is connected via a `-addnode` manual outbound connection).

The screenshot below shows two spikes I observed in the last 12 hours across all of my nodes. I haven't checked if these are still mostly "bad" addresses.
  
![image|690x245](upload://1JkQJwisnSz4PMJreheCuKwbpID.png)

I wonder what or who is causing these.

-------------------------

b10c | 2025-11-26 17:06:31 UTC | #2

These are two plots from March 2023 I did back then. On the y-axis is peer_id (higher id/newer connections are further up). On the x-axis is time. Red indicates a "bad" address (I can't connect to it) and green indicates a "good" address which I can connect to and do a version handshake.

![image|662x500](upload://rKSwDVPwfn7HSrQ919oxGLPwf9.jpeg)


![image|662x500](upload://7MRGra60SIROzlRsDDqTL1TkEdC.jpeg)
 

Both of these show that:
- all of our peers send us more addresses at (there's less white space to see)
- most of the addresses are "bad" (there's more red dots to see)
- during the spike, we get inbound connections at a higher rate and they are mostly short-lived and send us a few bad addresses (the red dots without any other addresses afterwards)


I've yet to check if the recent spikes still show the same behavior. I do have a fair bit of historical data on this though.

-------------------------

