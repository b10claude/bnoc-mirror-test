# Addresses with multiple ports

stratospher | 2026-05-21 10:23:11 UTC | #1

While comparing alice, bob, frank, mike, nico, dave, erin, kane and my addrman, it was interesting to see that while most IP addresses advertise 1 port - some IP addresses advertised multiple ports.

| ports | addresses |
|------:|----------:|
|     1 |   238,886 |
|     2 |     5,310 |
|     3 |       499 |
|     4 |       163 |
|     5 |        50 |
|     6 |        15 |
|     7 |         4 |
|     8 |         7 |
|     9 |         6 |
|    10 |         2 |
|    12 |         1 |
|    16 |         1 |
|    24 |         1 |
|    25 |         1 |
|    32 |         1 |

Checking some of these addresses with large number of ports:

| index | ip address       | total ports | pattern                        | in tried table of peers                             |     total distinct ports in tried table |
|-------|------------------|------------:|--------------------------------|-----------------------------------------------------|----------------------------------------:|
| 1     | 73.252.158.134 |          32 | 8301–8332                      | alice, dave, erin, frank, mike, nico, me (7/9)      |                                      18 |
| ~~2~~ | ~~73.71.63.98~~ | ~~25~~ | ~~some in 8306–8431 range~~ | ~~alice, bob, dave, frank, kane, mike, nico, me (8/9)~~ | ~~21~~ |
| 3     | 73.231.159.252 |          24 | some in 8301–8332 range        | alice, bob, frank, nico (4/9)                       |                                       7 |
| 4     | 79.127.184.3   |          16 | random high ports 36863…64837  | none (0/9)                                          |                                       0 |
| 5     | 65.109.115.232 |          12 | some in 8065–8888 range, 28333 | alice, bob, kane, mike, nico (5/9)                  |                           1 (only 8333) |
| 6     | 162.33.177.91  |          10 | 8333, 14406…15406              | all 9                                               | 9 (all the 14k/15k ports, but not 8333) |

- the top 3 are in 73.x.x.x. maybe some industry use case? Idk.
  - looks like 73.252.158.134 has 2 - 20 hours ago timestamp. so still being used.
  - 73.71.63.98 was from 6 months ago

Onion addresses advertise at most 2 ports - usually 8333 (88.6%), sometimes 8334 (4.5%), sometimes both (6.9%). 8334 gets advertised but almost never works. misconfiguration I guess but wonder why it happens.

-------------------------

b10c | 2026-05-19 08:41:40 UTC | #2

[quote="stratospher, post:1, topic:129"]
Onion addresses advertise at most 2 ports - usually 8333 (88.6%), sometimes 8334 (4.5%), sometimes both (6.9%). 8334 gets advertised but almost never works. misconfiguration I guess but wonder why it happens.
[/quote]

4.5% is quite high. Maybe interesting to check (via GitHub search) if some of node-in-a-box projects (Umbrel, raspliblitz, ...) set this.

-------------------------

b10c | 2026-05-19 08:43:18 UTC | #3

[quote="stratospher, post:1, topic:129"]
the top 3 are in 73.x.x.x. maybe some industry use case? Idk.

* looks like 73.252.158.134 has 2 - 20 hours ago timestamp. so still being used.
* 73.71.63.98 was from 6 months ago
[/quote]

[73.0.0.0/8](https://ipinfo.io/AS7922/73.0.0.0/8) is owned by Comcast Cable Communications, LLC, an US ISP.

-------------------------

