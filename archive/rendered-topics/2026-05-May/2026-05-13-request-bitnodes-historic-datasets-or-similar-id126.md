# Request: Bitnodes historic datasets (or similar)

fjahr | 2026-05-13 09:34:57 UTC | #1

Bitnodes is dead. This is pretty bad timing because we were just about to work on a dashboard showing analysis of historic asmap files and we were planning to use their data for showing the impact of the files on the bitcoin network at that point in time.

I have seen the KIT historical data suggested as an alternative: https://www.dsn.kastel.kit.edu/bitcoin/snapshots/ The problem there is that they anonymize IPs, likely following German data protection laws. For our specific use-case this means their data isn’t allowing us to run all the analysis we would like to do. 

Is anyone aware of a mirror of the historic data from bitnodes? Or could someone make some backups available to us? Or is there an alternative that I haven't found yet? We just need the data set for a few select dates at which asmap files were produced within the last two years.

Thanks!

-------------------------

b10c | 2026-05-13 09:46:28 UTC | #2

You're in luck! I've been paying for the Bitnodes API for the last few months and been downloading and storing their snapshots. The Bitnodes API did only return the snapshots from roughly three three months back, so the earlierst I have is from July 10, 2025. The total set of snapshots I have is more than 200GB in size.

Can you share the dates you are looking for? I'm open to sharing e.g. a daily snapshot available to you and others asking for it. I'm not too sure about making the whole set publicly downloadable as of now.

I've also heard from at least one other person that had snapshots. I'll ask them to comment here, if they want.

(moderator note: I moved this into the Data category and made this a "Request" as per https://bnoc.xyz/t/about-the-data-category/10)

-------------------------

matthias | 2026-05-13 14:35:18 UTC | #3

If the snapshots from our monitoring at KIT would help you, I could make the non-anonymized files available to you. Just send me a message with the specific dates you are looking for (email address is at the bottom of https://www.dsn.kastel.kit.edu/bitcoin/ ).

-------------------------

CedArctic | 2026-05-13 19:35:22 UTC | #4

I also have a snapshot from June 26th 2025 I am happy to privately share.

-------------------------

