# >60% spy-peers connected to freshly setup node

b10c | 2025-10-13 21:14:59 UTC | #1

I recently set up two new nodes and right after IBD, a bunch of spy nodes started connecting to them. At some point over >60% of my peers were spies. 

I found it surprising how aggressive the spies are. 

Some of the peers:

![image|690x443](upload://2iqoMZLbIHZfpiK7M0r8JMMNyQK.png)


| id  | ip                                                | user agent                        | tag | connection type             | network  | transport | tx relay  | addr relay | received | sent | connected time | addr processed    |  addr rate limited | ping   | minping | feefilter         |
|------|---------------------------------------------------------------------|-----------------------------------------|:---:|---------------------|-------|----|-------|-------|--------|--------|-------|------|---|-------|-----|-----------|
| 85   | 174.138.24.121:58174                                                | /Satoshi:24.0.1/                        | spy | inbound             | ipv4  | v1 | true  | false | 0.0 MB | 0.9 MB | 5535s | 0    |   | 234   | 232 | -         |
| 1215 | [2400:6180:0:d0::108d:2001]:47746                                   | /Satoshi:24.0.1/                        | spy | inbound             | ipv6  | v1 | true  | false | 0.0 MB | 0.8 MB | 5175s | 0    |   | 238   | 235 | -         |
| 1249 | 24.144.98.209:42578                                                 | /Satoshi:24.0.1/                        | spy | inbound             | ipv4  | v1 | true  | false | 0.0 MB | 0.7 MB | 4695s | 0    |   | 77    | 77  | -         |
| 1269 | [2604:a880:400:d0::e6a:6001]:58234                                  | /Satoshi:24.0.1/                        | spy | inbound             | ipv6  | v1 | true  | false | 0.0 MB | 0.7 MB | 4335s | 0    |   | 79    | 79  | -         |
| 1290 | [2a00:1398:4:2a03::bc11]:59856                                      | /dsn.kastel.kit.edu/bitcoin:28.0.0/     | spy | inbound             | ipv6  | v2 | true  | true  | 0.0 MB | 0.7 MB | 4002s | 0    |   | 4427  | 195 | -         |
| 1295 | [2001:67c:1220:808:f6:d81b:74a:ae60]:49694                          | /bitcoinj:0.16.2/Bitcoin Wallet:9.26/   | spy | inbound             | ipv6  | v1 | true  | true  | 0.0 MB | 0.6 MB | 3923s | 0    |   | 5289  | 173 | -         |
| 1310 | [2001:41b8:810:40:f8d9:8dff:fed6:866d]:56736                        | /dsn.tm.kit.edu/bitcoin:0.9.99/         | spy | inbound             | ipv6  | v1 | true  | true  | 0.0 MB | 0.6 MB | 3831s | 1    |   | 166   | 156 | -         |
| 1311 | [2a00:1398:4:2a03:4e52:62ff:fe22:6c13]:41658                        | /dsn.tm.kit.edu/bitcoin:0.9.99/         | spy | inbound             | ipv6  | v1 | true  | true  | 0.0 MB | 0.6 MB | 3831s | 0    |   | 169   | 160 | -         |
| 1328 | [2001:67c:1220:808:d5:a28:cc2:27c5]:57934                           | /bitcoinj:0.16.2/Bitcoin Wallet:9.26/   | spy | inbound             | ipv6  | v1 | true  | true  | 0.0 MB | 0.6 MB | 3689s | 0    |   | 11048 | 164 | -         |
| 1464 | [2a01:4f8:222:291f::2]:44763                                        | /bitnodes.io:0.3/                       | spy | inbound             | ipv6  | v1 | true  | false | 0.0 MB | 0.4 MB | 2198s | 0    |   | 157   | 157 | -         |
| 1567 | 23.88.18.119:34518                                                  | /:1.0.0-deve79d9922c/                   | spy | inbound             | ipv4  | v1 | true  | true  | 0.0 MB | 0.2 MB | 1252s | 0    |   | 163   | 163 | -         |
| 1604 | 46.101.92.98:35868                                                  | /Satoshi:24.0.1/                        | spy | inbound             | ipv4  | v1 | true  | false | 0.0 MB | 0.1 MB | 886s  | 0    |   | 144   | 144 | -         |
| 1642 | [2604:d500:4:1::4]:48775                                            | /bitcoinj:0.14.4/Bitcoin Wallet:5.20/   | spy | inbound             | ipv6  | v1 | true  | true  | 0.0 MB | 0.1 MB | 467s  | 1    |   | 122   | 122 | -         |
| 1643 | [2604:d500:4:1::3:34]:11386                                         | /Satoshi:0.15.0.1/                      | spy | inbound             | ipv6  | v1 | true  | true  | 0.0 MB | 0.1 MB | 467s  | 1    |   | 126   | 126 | -         |
| 1644 | [2604:d500:4:1::3:63]:23275                                         | /bitcoinj:0.14.4/Bitcoin:1.075/         | spy | inbound             | ipv6  | v1 | true  | true  | 0.0 MB | 0.1 MB | 467s  | 1    |   | 124   | 124 | -         |
| 1658 | 209.222.252.41:44223                                                | /Satoshi:0.15.0/Knots:20170914/         | spy | inbound             | ipv4  | v1 | true  | true  | 0.0 MB | 0.0 MB | 348s  | 1    |   | 133   | 133 | -         |
| 1659 | 162.218.65.145:30475                                                | /Satoshi:0.14.2(BIP148)/Knots:20170618/ | spy | inbound             | ipv4  | v1 | true  | true  | 0.0 MB | 0.0 MB | 348s  | 1    |   | 138   | 138 | -         |
| 1660 | 91.198.115.55:22385                                                 | /Satoshi:0.10.0/                        | spy | inbound             | ipv4  | v1 | true  | true  | 0.0 MB | 0.0 MB | 348s  | 1    |   | 147   | 147 | -         |
| 1669 | [2a03:b0c0:1:d0::f1b:c001]:40408                                    | /Satoshi:24.0.1/                        | spy | inbound             | ipv6  | v1 | true  | false | 0.0 MB | 0.0 MB | 276s  | 0    |   | 150   | 150 | -         |
| 1678 | [2604:d500:4:1::4]:36126                                            | /Satoshi:0.19.1/                        | spy | inbound             | ipv6  | v1 | true  | true  | 0.0 MB | 0.1 MB | 224s  | 0    |   | 321   | 321 | -         |
| 1680 | 91.198.115.114:31742                                                | /Satoshi:0.13.1/                        | spy | inbound             | ipv4  | v1 | true  | true  | 0.0 MB | 0.1 MB | 209s  | 0    |   | 257   | 257 | -         |
| 1694 | 209.222.252.80:46991                                                | /bitcoinj:0.14.4/Bitcoin Wallet:5.25/   | spy | inbound             | ipv4  | v1 | true  | false | 0.0 MB | 0.0 MB | 66s   | 0    |   | 177   | 177 | -         |
| 1695 | 209.222.252.238:62468                                               | /Satoshi:0.10.1/                        | spy | inbound             | ipv4  | v1 | true  | false | 0.0 MB | 0.0 MB | 66s   | 0    |   | 185   | 185 | -         |
| 1696 | 209.222.252.167:57642                                               | /Satoshi:0.13.1/                        | spy | inbound             | ipv4  | v1 | true  | false | 0.0 MB | 0.0 MB | 66s   | 0    |   | 186   | 186 | -         |
| 1697 | [2604:d500:4:1::4]:49039                                            | /Bitcoin ABC:0.15.0(EB8.0)/             | spy | inbound             | ipv6  | v1 | true  | false | 0.0 MB | 0.0 MB | 54s   | 0    |   | 164   | 164 | -         |
| 1698 | [2604:d500:4:1::4]:9440                                             | /Bitcoin ABC:0.14.6(EB8.0)/             | spy | inbound             | ipv6  | v1 | true  | false | 0.0 MB | 0.0 MB | 54s   | 0    |   | 174   | 174 | -         |

-------------------------

ajtowns | 2025-12-04 17:45:03 UTC | #2

[quote="b10c, post:1, topic:15"]
I found it surprising how aggressive the spies are.

[/quote]

I think it’s also that genuine nodes are very non-aggressive in making connections – it takes a while for your address to propagate, takes a while for it to be tried, and you’ll only get a long lasting connection when the node restarts or if you get lucky via the extra blocks only or extra outbound logic.

-------------------------

bruno | 2025-12-09 17:10:31 UTC | #3

I just noticed the same on a freshly node I set up. I thought very weird to have many connections from these kind of user agents.

-------------------------

