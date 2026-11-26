# Increase in the number of reachable IPv4 nodes (bitprojects.io)

matthias | 2025-11-25 14:37:05 UTC | #1

A few days ago, a sudden increase in the number of reachable IPv4 nodes from about 8,500 to 10,500 was observed by our [monitoring nodes at KIT](https://www.dsn.kastel.kit.edu/bitcoin/):

![nconn-v-2592000-marked|690x345](upload://mvLZdzjiOsc3FUsZecwQWQRl6gj.png)

This increase seems to come mostly from 2040 new reachable addresses in the autonomous systems 12029 and 29798. From each of these ASes, we see 1020 IP addresses distributed over four /24 subnets:

AS 12029:
45.40.98.0/24
103.47.56.0/24
173.46.87.0/24
206.206.109.0/24

AS 29798:
89.106.27.0/24
174.140.231.0/24
184.174.95.0/24
216.107.135.0/24

According to [whois data](https://whois.arin.net/rest/asn/AS12029.html), these ASes are owned by TenSpire Network / bitprojects.io (see [/Satoshi:29.1.0(dont-spam-me-bro)/ nodes?](https://bnoc.xyz/t/satoshi-29-1-0-dont-spam-me-bro-nodes/40))

-------------------------

b10c | 2025-10-24 10:28:48 UTC | #2

Thanks for sharing! I think bitprojects went offline for a while to fix their misconfigurations (https://antoinep.com/posts/misbehaving_nodes/) and now came online again. 

[quote="matthias, post:1, topic:45"]
AS 12029:
45.40.98.0/24
103.47.56.0/24
173.46.87.0/24
206.206.0/24

AS 29798:
89.106.27.0/24
174.140.231.0/24
184.174.95.0/24
216.107.135.0/24
[/quote]


Note that https://bnoc.xyz/t/satoshi-29-1-0-dont-spam-me-bro-nodes/40/2?u=b10c mentions `203.11.72.185` as an example which isn't included here. I assume there might be even more IP ranges belonging to them. I heard something of about 3000 IPs.

-------------------------

b10c | 2025-10-24 10:30:26 UTC | #3

I also noticed that I don't have any connections to them at the moment. Maybe they are offline again?

-------------------------

b10c | 2026-06-19 11:43:02 UTC | #4

Seems like AS401199 (TenSpire Network) is the other AS:

66.163.223.0/24
103.246.186.0/24
123.100.246.0/24
203.11.72.0/24

edit: this post mentioned 23.100.246.0/24, but that’s not bitprojects! It should have been 123.100.246.0/24!

-------------------------

matthias | 2025-10-30 13:32:01 UTC | #5

![nconn-v-604800-decrease|690x345](upload://iSKrgw2DA0dRNBVTiSOleiHIMQk.png)

Since yesterday, the addresses from the three mentioned ASes appear to be offline from the view of our monitors. However, I'm not sure whether they are actually offline or just blocking connections from our peers because one of our monitor nodes lost the connections to those peers about 24 hours earlier than the other two monitor nodes.

-------------------------

b10c | 2025-10-30 16:07:44 UTC | #6

Interesting! I noticed already last Friday (2025-10-24) that I didn't have any open connections to "dont-spam-me-bro" nodes anymore. But they seems to just have changed their user-agent at around 3am UTC on that day.

-------------------------

instagibbs | 2025-11-20 18:39:14 UTC | #7

Here are the TenSpire Network AS connections I’ve seen on my node fwiw

401199 (most common amongst my banned peers)
1426
12029
29798

-------------------------

b10c | 2025-11-25 14:27:10 UTC | #8

fwiw: AS1426 is [104.204.252.0/23](https://ipinfo.io/AS1426/104.204.252.0/23)

-------------------------

matthias | 2025-11-27 12:22:07 UTC | #9

![nconn-v-604800-nov25|690x345](upload://zBJq0DGcbHW0wPy8f1ZeYUp0brT.png)

About 3000 nodes are back. Now, they have the user agent /Satoshi:29.2.0/Knots:20251110/.

![versionstr_week-nov25|690x391](upload://dGGoNRFXIesAodlXRGZhDqqwKln.png)

-------------------------

b10c | 2025-12-05 14:03:34 UTC | #10

[quote="matthias, post:5, topic:45"]
Since yesterday, the addresses from the three mentioned ASes appear to be offline from the view of our monitors. However, I’m not sure whether they are actually offline or just blocking connections from our peers because one of our monitor nodes lost the connections to those peers about 24 hours earlier than the other two monitor nodes.
[/quote]

I think you are right. The person running bitprojects indicated that there is some automatic blocking of connections and specifically mentioned the KIT monitors to be affected by this.

-------------------------

b10c | 2026-07-03 15:07:09 UTC | #11

[quote="b10c, post:4, topic:45"]
edit: this post mentioned 23.100.246.0/24, but that’s not bitprojects! It should have been 123.100.246.0/24!

[/quote]

For completeness, these are the 12x /24 IPv4 subnets that were owned by bitprojects until late March 2026:

* 45.40.98.0/24
* 103.47.56.0/24
* 173.46.87.0/24
* 206.206.109.0/24
* 189.106.27.0/24
* 174.140.231.0/24
* 84.174.95.0/24
* 216.107.135.0/24
* 66.163.223.0/24
* 103.246.186.0/24
* 123.100.246.0/24
* 203.11.72.0/24

-------------------------

stratospher | 2026-10-02 19:16:02 UTC | #12

looks like a few bitprojects IPs made it into the Bitcoin Core fixed seeds. :smiling_face_with_tear: 
EDIT: ~~not very sure about whether bitprojects started in 2024.~~ edit: ok thanks @b10c for pointing out [this](https://bnoc.xyz/t/outbound-connection-success-rates-of-a-bitcoin-node/142/5) - bitprojects started in mid-jul 2024.


| seed update | bitprojects IPs                                                         | shipped in                          |
|-------------|-------------------------------------------------------------|-------------------------------------|
| 2024-08-27  | 203.11.72.118, 203.11.72.199                                | v28.0, v28.1, v28.2, v28.3, v28.4   |
| 2025-03-06  | 103.246.186.143, 103.246.186.234                            | v29.0, v29.1, v29.2, v29.3, v29.4   |
| 2025-09-02  | 123.100.246.36, 203.11.72.173                               | v30.0, v30.1, v30.2, v30.3          |
| 2026-02-25  | 66.163.223.67, 103.246.186.167, 203.11.72.53, 203.11.72.174 | v31.0, v31.1                        |
| 2026-09-08  | none                                                        | v32.0 (rc1–rc3), master             |

-------------------------

