# Did the number of reachable nodes in residential ISPs increase since Bitcoin Core v30.0?

b10c | 2026-04-28 15:50:55 UTC | #1

With the release of Bitcoin Core v30.0 on 2025-10-10, the `-natpmp` has been enabled by default. The hope is that this will increase the number of reachable nodes in residential ISPs. The [release notes](https://bitcoincore.org/en/releases/30.0/#updated-settings) mention: 

> The `-natpmp` option is now set to `1` by default. This means nodes with `-listen` enabled (the default) but running behind a firewall, such as a local network router, will be reachable if the firewall/router supports any of the `PCP` or `NAT-PMP` protocols. ([#33004](https://github.com/bitcoin/bitcoin/pull/33004))

-------------------------

b10c | 2026-04-28 15:51:11 UTC | #2

To explore if this change had a measurable effect on the network, I've looked at the historical network snapshots captures by bitnodes.io. Particularly, I'm looking at 36310 snapshots from 2025-07-10 till 2026-04-27 that I've archived. To map IPs to ASNs, I'm using   [2026/1772726400_asmap.dat](https://github.com/bitcoin-core/asmap-data/blob/main/2026/1772726400_asmap.dat). I've manually classified the ASNs with 25 or more nodes into either "cloud/hosting" or "residential/ISP". This yields 58 "residential" ISPs. I'm counting both IPv4 and IPv6 addresses as distinct nodes, which likely inflates the numbers a bit, as likely some residential nodes listen on both IPv4 and IPv6.

[details="ASN classification"]
```python
hosting = [
    "AS24940", # Hetzner
    "AS16276", # OVH SAS
    "AS16509", # Amazon 02
    "AS396982", # Google Cloud Platform
    "AS14061", # Digital Ocean
    "AS51167", # Contabo
    "AS40021", # Contabo
    "AS141995", # Contabo Asia
    "AS8560", # IONOS SE
    "AS14618", # Amazon.com, Inc.
    "AS197540", # netcup GmbH
    "AS20473", # Vultr
    "AS31898", # Oracle
    "AS12876", # Scaleway SAS
    "AS6939", # Hurricane Electric
    "AS63949", # Akamai Connected Cloud
    "AS54415", # Wiz (mempool space)
    "AS47583", # Hostinger
    "AS9009", # M247 Europe SRL
    "AS19318", # Interserver
    
    "AS1299", # Arelion Sweden AB (not sure)
    "AS45021", # BIP21 SAS (not sure)
]

residential = {
    "AS3320": "Deutsche Telekom AG (DE)",
    "AS3209": "Vodafone GmbH (DE)",
    "AS4766": "Korea Telecom (KR)",
    "AS7018": "AT&T Enterprises (US)",
    "AS701": "Verizon Business (US)",
    "AS12322": "Free SAS (FR)",
    "AS20115": "Charter Communications 1 (Spectrum; US)",
    "AS20001": "Charter Communications 2 (Spectrum; US)",
    "AS11427": "Charter Communications 3 (Spectrum; US)",
    "AS10796": "Charter Communications 4 (Spectrum; US)",
    "AS33363": "Charter Communications 5 (Spectrum; US)",
    "AS11351": "Charter Communications 6 (Spectrum; US)",
    "AS11426": "Charter Communications 7 (Spectrum; US)",
    "AS5650": "Frontier Communications of America (US)",
    "AS22773": "Cox Communications (US)",
    "AS1136": "KPN (NL)",
    "AS209": "CenturyLink Communications (Lumen; US)",
    "AS852": "TELUS Communications  (CA)",
    "AS16591": "Google Fiber (US)",
    "AS3303": "Swisscom (CH)",
    "AS2856": "British Telecommunications (UK)",
    "AS3215": "Orange (FR)",
    "AS5089": "Virgin Media (UK)",
    "AS577": "Bell (CA)",
    "AS3352": "Telefonica De Espana (ES)",
    "AS33491": "Comcast Cable Communications 1 (US)",
    "AS7015": "Comcast Cable Communications 2 (US)",
    "AS33650": "Comcast Cable Communications 3 (US)",
    "AS33651": "Comcast Cable Communications 4 (US)",
    "AS33652": "Comcast Cable Communications 5 (US)",
    "AS33657": "Comcast Cable Communications 6 (US)",
    "AS20214": "Comcast Cable Communications 7 (US)",
    "AS33668": "Comcast Cable Communications 8 (US)",
    "AS33490": "Comcast Cable Communications 9 (US)",
    "AS6730": "Sunrise GmbH (CH)",
    "AS6327": "Shaw Communications (CA)",
    "AS50266": "Odido Netherlands (NL)",
    "AS4764": "Aussie Broadband (AU)",
    "AS6128": "Cablevision Systems Corp. (US)",
    "AS7545": "TPG Telecom (AU)",
    "AS8473": "Bahnhof AB (SE)",
    "AS33915": "Vodafone Libertel (NL)",
    "AS20055": "Wholesail networks (US)",
    "AS812": "Rogers Communications Canada (CA)",
    "AS8881": "1&1 Versatel GmbH (DE)",
    "AS57269": "Digi Spain Telecom (ES)",
    "AS8708": "Digi Romania (RO)",
    "AS5410": "Bouygues Telecom (FR)",
    "AS1221": "Telstra Limited (AU)",
    "AS8151": "UNINET (MX)",
    "AS9318": "SK Broadband Co Ltd (KR)",
    "AS16019": "Vodafone Czech Republic (CZ)",
    "AS5378": "Vodafone Limited (UK)",
    "AS13030": "Init 7 (CH)",
    "AS28573": "Claro NXT Telecomunicacoes (BR)",
    "AS12874": "Fastweb SpA (IT)",
    "AS49981": "WorldStream B.V. (NL)",
    "AS6871": "Plusnet (UK)",
}
```
[/details]

To get a rough feeling, I used the number of reachable residential/ISP nodes on 2025-10-10 (v30.0 release) as a baseline. A sharp increase in residential node count after this date could indicate that this change worked.

![Change in residential node count since Bitcoin Core v30.0 release (sample consisting of the largest 58 residential ASNs)|690x342](upload://eOPiTZpx8e4vAxa3hhWm4QR1VFs.png)

Plotting the change in total residential node count (black), change in v30.0 or newer nodes (orange), and change in ≤ v29.x or other node (e.g. Knots) count (blue) shows a total increase of about +100 residential nodes since Bitcoin Core v30.0 release. The orange line shows the adoption of Bitcoin Core v30.0 (+800), while the blue line shows a decrease in users running ≤ v29 or others (about -700). 

While +100 residential nodes since Bitcoin Core v30.0 release is nice, this is far from the  sharp increase in residential nodes some hoped for. Additionally, this likely can't be attributed to `-natpmp` and rather follows a general trend. The plot shows that between August and the Bitcoin Core v30.0 release about +200 residential nodes joined the network in the observed ASNs. This might be due to the Core/Knots debate, the price rally during late 2025, more podcasts or tutorials explaining users how to run a node, or more users buying a plug-and-play node.

**My current conclusion is that enabling `-natpmp=1` by default didn't cause an increase in residential nodes**. 

Further work could inspect this separated by IPv4/IPv6, use the [KIT DSN network snapshots](https://www.dsn.kastel.kit.edu/bitcoin/data.html) to cross-check the numbers, or investigate how many not-seen-before IPs appear the first time with a v30.0 user-agent.

-------------------------

Antoine | 2026-04-28 17:04:59 UTC | #3

[quote="b10c, post:2, topic:122"]
While +100 residential nodes since Bitcoin Core v30.0 release is nice, this is far from the sharp increase in residential nodes some hoped for. Additionally, this likely can’t be attributed to `-natpmp` and rather follows a general trend.

[/quote]

I was expecting a mild increase due to the lack of NAT-PMP/PCP support in routers compared to UPnP. This is still lower than i would have expected, but it may be explained by how residential users are relatively slower to upgrade. It would be interesting to revisit in October, a year after the first `-natpmp=1` release.

-------------------------

deadmanoz | 2026-04-29 02:14:17 UTC | #4

[quote="b10c, post:1, topic:122"]
natpmp

[/quote]

Surprised that the effect is this small, but I do wonder:
(a) About the tail, e.g. for what I am familiar with (Australia), only about 1/3 of the more major ISP ASNs are in the list (3 of \~9). So how much is being missed due to the classification threshold?
(b) natpmp can’t help customers behind CGNAT, this seems to be increasingly common (again, maybe geographically biased understanding)

-------------------------

b10c | 2026-04-29 07:57:45 UTC | #5

re a) yes, there's a long tail. Maybe it makes sense to expand it to more ISPs. Maybe I can automate that somehow - doing it manually was very time consuming. I see that the ipinfo.io API offers a "type" field, but that's only returned in the paid version, which I don't have access too. Surely there are alternatives..

[quote="b10c, post:2, topic:122"]
Further work could [...] use the [KIT DSN network snapshots](https://www.dsn.kastel.kit.edu/bitcoin/data.html) to cross-check the numbers
[/quote]

I applied the same methodology to the KIT snapshots (with the same AS classifications).

![grafik|690x342](upload://xFxQsP17LQ5O2jPLrfFPluUSImU.png)

This shows a very similar growth of the residential network.

-------------------------

b10c | 2026-04-29 11:03:06 UTC | #6

[quote="b10c, post:5, topic:122"]
yes, there’s a long tail. Maybe it makes sense to expand it to more ISPs. Maybe I can automate that somehow - doing it manually was very time consuming. I see that the [ipinfo.io](http://ipinfo.io) API offers a “type” field, but that’s only returned in the paid version, which I don’t have access too. Surely there are alternatives..
[/quote]

I went ahead and fetched the ASN classification from the ipinfo.io website... Using all ASN classified as "isp" yields the following plots for the Bitnodes and KIT data. Since they are different data sources and the IP->ASN method is different for them (For Bitnodes we use ASMAP, KIT DSN data has an ASN field), they have a different number of ISPs.

Using Bitnodes data:
 
![Change in residential node count since Bitcoin Core v30.0 release (1410 residential ASNs; bitnodes data)|690x342](upload://gkU9s5D9UTETYLWXsIh89bQmCnn.png)

Bitnodes data suggests +200-250 residential nodes since v30.0 release at the moment.

Using KIT DSN data:

![Change in residential node count since Bitcoin Core v30.0 release (1311 residential ASNs; KIT DSN data)|690x342](upload://lSxVePhf5U9ULyElYwKDJUQTbgu.png)

KIT DSN data suggests +150-200 residential nodes since v30.0 release at the moment.

-------------------------

b10c | 2026-04-29 11:28:35 UTC | #7

As comparision, in ASNs classified as "hosting", there wasn't a big change in reachable node counts. There just happened to be a spike in reachable nodes around the Bitcoin Core v30.0 release. Note that the Bitnodes data does not contain any bitprojects "nodes" (https://bnoc.xyz/t/many-connections-to-bitproject-io-nodes/40).

![Change in hosted node count since Bitcoin Core v30.0 release (580 hosted ASNs; bitnodes data)|690x342](upload://kdH7zMMweDUDlcvgBXaZhA3If5W.png)

In total, there a more reachable nodes in ASNs classified as "residential" than "hosting":

![Total node count across 'hosting' and 'residential' ASNs (Bitnodes data)|690x355](upload://cifuzGEOLqS51iY9fyyR9KwG39B.png)

-------------------------

b10c | 2026-04-29 11:53:20 UTC | #8

Here's a top movers view on node count change per ASN:

![Top 25 gainers and losers in node count since 2025-07-10 (Bitnodes data)|556x500](upload://hxhNdYqWnNQpXlDzwOTC8IIfIx9.png)


And here over time:

![Gainers and loosers over time|690x491](upload://eg95S7nrfOtnido0POW0jTd8MpV.png)


The gains in AMAZON-02, Google Cloud Plattform spike up in early October 2025. Wiz K.K. (the mempool space ISP) loss around 2025-10-20 seem interesting, but could also be a data error in Bitodes data, and OVH losing nodes is interesting too. The OVH timing dropping in January and Feburary doesn't really match the https://blog.ovhcloud.com/pricing-evolution-of-public-cloud-bare-metal-and-vps-at-ovhcloud/ & https://us.ovhcloud.com/resources/blog/pricing-evolution-of-public-cloud-bare-metal-and-vps-at-ovhcloud/ price increase they annouced. Otherwise, this could have been a reason.

-------------------------

Emzy | 2026-05-08 15:31:46 UTC | #9

AFAIK mempool.space servers moved from the AS Wiz K.K. to another AS Mempool Space K.K.

-------------------------

mzumsande | 2026-05-12 15:08:32 UTC | #10

Another possible reason could be that many nodes behind residential ISPs are not online 24/7. They catch up with the blockchain every now and then, turn their node on when they need to transact, but are offline most of the time. I think most bitcoiners have a node like that, e.g. a pruned node on a personal laptop.

As a result, their IPs will be known to the network, they may even be reachable when they are online (but estimates of unreachable nodes based on addr might count them as an unreachable node), but sites such as bitnodes that only list nodes that are currently online won’t list them most of the time.

Maybe the number of non-reachable nodes online at a given time is smaller than various estimates would suggest.

-------------------------

