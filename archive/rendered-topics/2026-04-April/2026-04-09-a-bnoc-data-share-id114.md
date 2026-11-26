# A BNOC data share?

b10c | 2026-04-09 21:33:04 UTC | #1

I've been thinking about a good solution for a Bitcoin data share where we can upload and share e.g. multiple TB of historical debug logs (https://bnoc.xyz/t/offer-detailed-bitcoin-core-node-debug-logs-2024/36; potentially automated uploads each night) and ad-hoc  data collection results like the one requested in https://bnoc.xyz/t/request-bitcoin-and-or-lightning-packet-captures/111.

Requirements:
- 10+ TB of space
- no server/disk maintaince required for me
- good connectivty
- ideally, cheap or free :)
- ideally, some data redundancy - but it's a share, not a backup.

Happy to hear ideas.

-------------------------

b10c | 2026-04-10 09:46:21 UTC | #2

One thing that catched my attention was Google offering 100TB of Google Drive storage for non-profits. 

https://www.google.com/intl/en/nonprofits/offerings/workspace/

I spoke to someone from a Bitcoin non-profit and they mentioned it would be an option to use this Google Drive space for something like this.

I'm not sure how I feel about giving even more data to Google. However, XORing/encrypting the files with a well-known secret might be enough for it to be automatically ingested into the depth of Google..


I'm not sure how easy it is to download files via e.g. `wget` from Google Drive...

-------------------------

GuiSchet | 2026-04-13 19:12:16 UTC | #3

Maybe self-hosted S3 options worth considering: [garage](https://garagehq.deuxfleurs.fr) or [seaweedFS](https://github.com/seaweedfs/seaweedfs).
Community members can contribute storage nodes to the cluster. (it’s something longterm…)

This sidesteps Google Drive’s privacy concerns and stays open-source.

-------------------------

jonhbit | 2026-04-14 15:12:22 UTC | #4

[quote="b10c, post:2, topic:114"]
I’m not sure how easy it is to download files via e.g. `wget` from Google Drive…
[/quote]

It seems like rclone has Google Drive support:

https://rclone.org/drive/

But my read of the docs is that that's mostly for a single user (I've used it successfully that way). Not sure how it could be used for people to download from a public / shared folder though; a quick web search suggests its possible?

-------------------------

b10c | 2026-04-14 19:30:27 UTC | #5

There also seems to be https://github.com/wkentaro/gdown.

-------------------------

b10c | 2026-05-08 15:35:29 UTC | #6

[Brink.dev](https://brink.dev) was so kind a set up a "Shared Drive" thing using their Google Drive subscription (thanks Brink!). We probably have about 10 TB or so there. I have yet to test this, but will do so the next time I need to share some data. Happy to provide **write access** if someone needs it to share files, but likely only to trusted people, since I obviously don't want to get Brink into problems with Google by hosting random, suspicous files.

Here's a public debug log from one of the demo peer-observer logs for testing: https://drive.google.com/file/d/16H_30cM33plIImIQhGT_e8gDYtz3pl-D/view

There's now also a static, non-Google file viewer here: https://bitcoin-noc.github.io/datashare-website/

-------------------------

b10c | 2026-07-09 18:57:13 UTC | #7

The read-only version of the data share is now also reachable via [data.bnoc.xyz](https://data.bnoc.xyz)

-------------------------

