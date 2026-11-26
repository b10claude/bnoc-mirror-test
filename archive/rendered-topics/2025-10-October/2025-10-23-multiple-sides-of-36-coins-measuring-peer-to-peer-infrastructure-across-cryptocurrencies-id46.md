# Multiple Sides of 36 Coins: Measuring Peer-to-Peer Infrastructure Across Cryptocurrencies

matthias | 2025-10-23 13:39:48 UTC | #1

The paper [Multiple Sides of 36 Coins: Measuring Peer-to-Peer Infrastructure Across Cryptocurrencies](https://hdl.handle.net/20.500.12761/1982) by Lucianna Kiffer, Lioba Heimbach, Lucianna Vonlanthen, Oliver Gasser, and Dennis Trautwein describes measurements of several peer-to-peer networks, including Bitcoin.

An interesting idea is that they searched for Bitcoin peers by probing the complete IPv4 address space and checked the replies when connecting on Bitcoin's default port 8333. Thereby, the found about 9,000 addresses that seemed to belong to Bitcoin peers in July 2025. They compared these addresses to the addresses that a Bitcoin client received in ADDR messages. As far as I understand the numbers in the paper, they found that about 80 % of the 9,000 addresses were also received in ADDR messages and that the 9,000 addresses correspond to about 90 % of addresses of peers being reachable over IPv4.

-------------------------

