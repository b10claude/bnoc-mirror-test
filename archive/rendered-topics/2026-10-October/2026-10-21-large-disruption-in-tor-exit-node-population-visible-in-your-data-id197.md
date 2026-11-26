# Large disruption in Tor exit node population: visible in your data?

jonhbit | 2026-10-21 14:37:03 UTC | #1

Looks like there was an attack that hijacked 300+ Tor relay nodes, promoted them to exit nodes (to become 10+% of the count of exit nodes at the time), and was then discovered and stopped. Roughly, detected on October 2nd and resolved by October 5th.

https://kaba.cx/posts/20261020_Tor/

I wonder if any of us can observe the churn in the Tor population of relays and exits in our own data. I haven't spend much effort yet looking at connection churn on my setup, but I think others have.

-------------------------

b10c | 2026-10-21 23:05:44 UTC | #2

I did not see any significant drop or change in Tor peer connectivity on these dates across.

![image|690x201](upload://FmXBIqVAmzLRRveZs1ARFIbpkJ.png)

Neither did I see any significant connection drop or change in connectivity from IPv4 connections from Tor exit nodes.

![image|690x307](upload://tGZCRZhlmP7dDAlJZd0PiXQ1I5f.png)

However, I'm also not sure if that's actually looking at the right data.

-------------------------

