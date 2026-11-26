# /python-bitcoinlib:0.12.2/ client getting addr-ratelimited (since 2026-04-10)

b10c | 2026-04-13 13:42:32 UTC | #1

Since 2026-04-10 at about 16:30 UTC I've seen multiple IPv4 addresses connect to my monitoring nodes gossiping addresses via `addr` (and not `addrv2`) at a higher rate. These addresses are frequently rate-limited.  

IPs are:
- [130.60.24.200](https://ipinfo.io/130.60.24.200) (uzh.ch - University of Zurich)
- [3.102.33.26](https://ipinfo.io/3.102.33.26) (AWS New Zealand)
- [3.98.91.234](https://ipinfo.io/3.98.91.234) (AWS Canada)
- [51.20.80.202](https://ipinfo.io/51.20.80.202) (AWS Sweden)
- ...

![image|690x465](upload://xqx53n2lJxb6HUls6nwW28RmSmW.png)

My node `erin` is receiving about 40 addresses per minute now.

![image|690x374](upload://yaK89R57Mnok8rWshls8IffAoMh.png)

Looking at the addrman of `erin`, the seems to be only the normal background noise of additions and replacements in the new and tried table:

![image|690x407](upload://lp4uqQ7Fge6EeLeqKClzCL4rvHL.png)

-------------------------

b10c | 2026-04-13 13:34:42 UTC | #2

My first impression is that this is a rather unsuccessful research project from someone at uzh.ch.

Could investigate a bit more by looking at the addresses they are sending.

-------------------------

b10c | 2026-04-13 13:58:31 UTC | #3

From `getpeerinfo`:

```
...
    "addr_relay_enabled": true,
    "addr_processed": 24650,
    "addr_rate_limited": 14316,
    "permissions": [
    ],
    "minfeefilter": 0.00000000,
    "bytessent_per_msg": {
      "addr": 294645,
      "alert": 192,
      "getheaders": 1053,
      "inv": 54973514,
      "ping": 66176,
      "pong": 238336,
      "verack": 24,
      "version": 126
    },
    "bytesrecv_per_msg": {
      "addr": 1272375,
      "inv": 122183,
      "ping": 238368,
      "pong": 66176,
      "verack": 24,
      "version": 136
    },
...
```

> Could investigate a bit more by looking at the addresses they are sending.

At [date=2026-04-13 time=13:47:00 timezone=Etc/Universal] I received a `addr` message with exactly 10 entries. All timestamps were recent (not older than 10min). The IPs seemed reasonable from locations where real nodes could be hosted / run from, the ports were mostly 8333, and the services seemed to be reasonable ones too. 

I also noticed that they always send a ping with value zero and we do announce transactions to them, but they don't seem to request any (spy-node behavior).

-------------------------

matthias | 2026-04-17 09:14:00 UTC | #4

In our [monitoring](https://www.dsn.kastel.kit.edu/bitcoin/#addresses), we see that the number of unique addresses being propagated in the network has risen noticeably during the last days:

![image|690x376](upload://AktFYLX5LirVnGLjduRM9EuxuGw.png)

This effect is probably caused by the peers that are described above in this topic.

The observation indicates that the newly propagated addresses are unreachable and have not previously been announced in the network. Without having looked further into the set of distributed addresses I suppose that they might have been randomly generated.

-------------------------

b10c | 2026-04-27 19:38:09 UTC | #5

Bitnodes seems to be showing something similar for their "unreachable" node stats

https://bitnodes.io/nodes/all/1d/


![grafik|690x437](upload://nU3OgbzArTOKyRF1uPNzdflTVrt.png)

-------------------------

b10c | 2026-05-12 12:26:18 UTC | #6

Fwiw this is still ongoing. I'm seeing ~30% of my peers having at least gotten one address rate-limited now.

![image|690x397](upload://blHW7noWw4qXULmK8CiFZig9WRL.png)

-------------------------

matthias | 2026-07-20 09:45:20 UTC | #7

As already noted in [this thread](https://bnoc.xyz/t/unreachable-addresses-in-bitcoin-getaddr-responses/155), the number of gossiped unreachable addresses declined back to normal level around July 15, 2026. This can be seen in our [monitoring](https://www.dsn.kastel.kit.edu/bitcoin/#addresses):

![unique-small-day9776000|690x376](upload://jjB70zdOt6eAKWmKjxmjNKdzemk.png)

-------------------------

b10c | 2026-08-21 13:22:00 UTC | #8

just a quick note: I've been seeing higher rates of addr entries being processed by my nodes again over the last couple of days (18th and 21st).

-------------------------

naiyoma | 2026-09-02 15:12:59 UTC | #9

Since August 25, I’ve seen a steady increase in the number of addresses being rate-limted as well as the number of addresses received

![addr|690x213](upload://xvbmzPMTBbTxI27M2Lq98HPnEJJ.png)

-------------------------

