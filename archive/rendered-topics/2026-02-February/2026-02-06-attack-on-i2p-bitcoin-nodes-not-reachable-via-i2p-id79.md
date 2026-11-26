# Attack on I2P: Bitcoin nodes not reachable via I2P

b10c | 2026-02-07 15:43:06 UTC | #1

There's an [Ongoing Attack on I2P Network Causing Degraded Performance](https://www.reddit.com/r/i2p/comments/1qvalmq/megathread_ongoing_attack_on_i2p_network_causing/) that's also affecting Bitcoin node connectivity via I2P. I run four Bitcoin nodes with I2P connectivity, and all seem to be affected.

My monitoring indicates it started on 2026-02-03 at around 7 am UTC when all my nodes lost its peers that were connected via I2P. Since then, connectivity seems to have been close to non-existent.

![image|690x137](upload://cenDB1Vk79aveQaQAOS0PM5NUE4.png)

Interestingly, the number of total I2P peers I had jumped from 19 to 29 right before connectivity stopped.

![image|690x137](upload://lbBL47ma2MDVm0AWY7BYoZXdw1j.png)

Splitting it up by node shows that node `kane`, which is only connected via Tor and I2P, saw the biggest increase in I2P peers. 

![image|690x186](upload://7H0fTwYQK4ZmUPPm7v5SMMYRTdG.png)

-------------------------

b10c | 2026-02-06 13:54:38 UTC | #2

This is pure speculation. I don't actually know how I2P works in detail:

One idea I had why `kane` saw more I2P connections shortly before I saw the attack on my nodes was: Other nodes were affected first. So their I2P connections went down and they started to look for a new connection. Since they could still reach me, my I2P connections increased.

-------------------------

Emzy | 2026-02-06 14:14:29 UTC | #3

I see the same on my Electrum server. No i2p connections anymore.
```
$ bitcoin-cli -netinfo
 Bitcoin Core client v30.1 - server 70016/Satoshi:30.1.0(@emzy)/ 
           ipv4     ipv6    onion    i2p   total   block  manual

 in        145      38      22       0     205
 out         7       4       1       0      12       2       2
 total     152      42      23       0     217
 ```

-------------------------

deadmanoz | 2026-02-09 07:56:55 UTC | #4

Just curious, and maybe not *completely* related, do you periodically snapshot addrman for your nodes?

-------------------------

b10c | 2026-02-09 09:35:42 UTC | #5

I have some for the demo.peer.observer nodes here: https://bnoc.xyz/t/historical-bitcoin-core-ip-address-manager-snapshots-via-getrawaddrman/77 (added last week). 

Also, in peer-observer, with the `rpc-extractor`, we query both `getaddrmaninfo` and `getrawaddrman` since recently and generate various addrman metrics with the metrics tool.

For example, the I2P addresses in the addrman tried table (we tried this address and there was a reachable node behind it) has been declining slowly since the I2P attack started on 2026-02-03: 
![image|690x203](upload://sCUSKY4NBNmIz6lUd1yuutNRfbN.png)
  (time range is "past 14 days")

-------------------------

b10c | 2026-02-12 20:57:07 UTC | #6

Some context here: https://krebsonsecurity.com/2026/02/kimwolf-botnet-swamps-anonymity-network-i2p/

-------------------------

