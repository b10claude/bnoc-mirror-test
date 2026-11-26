# F2Pool mines two blocks at height 956337

b10c | 2026-07-02 09:49:50 UTC | #1

Similar to https://bnoc.xyz/t/antpool-mines-two-blocks-at-height-925051/60 , F2Pool mined two forks at height 956337. This isn’t too special, as two ASICs or two nodes, or multiple Stratum servers aren’t unlikely. Still, it’s interesting to dive deeper into this and, if possible, compare the blocks.

![image|632x500](upload://uJHnScK2c5yxZPrcKLbvHuBlKDT.png)

-------------------------

b10c | 2026-07-02 13:01:44 UTC | #2

The blocks seem to have the same contents besides these differences in the coinbase:

```diff
@@ -1,14 +1,14 @@
 {
-  "txid": "5d938c39c1cd16cac8feae1eec86de553e617d96db7dadb6edde65b81cc928dc",
-  "hash": "e70c85897226f8b74d6a266c917ec0f6c91b3e5080a5be87b15a82d0795bf525",
+  "txid": "21256b2397fe3734de4f8295aa5259a56876c47613fa4e73033899a9fe6c9134",
+  "hash": "7617f3be024129dd9f1d2470a61af74189e7298b3a3d5e9e881ce51e5f91b8b5",
   "version": 1,
   "size": 535,
   "vsize": 508,
   "weight": 2032,
-  "locktime": 1077898580,
+  "locktime": 1079685856,
   "vin": [
     {
-      "coinbase": "03b1970e2cfabe6d6d2d5712e41100d88e6f5129bd69bcb100434f0a7554719ae21e9dea6cf55bac9310000000f09f909f092f4632506f6f6c2f64000000000000000000000000000000000000000000000000000000000000000000000005002c426e00",
+      "coinbase": "03b1970e2cfabe6d6d2d5712e41100d88e6f5129bd69bcb100434f0a7554719ae21e9dea6cf55bac9310000000f09f909f092f4632506f6f6c2f65000000000000000000000000000000000000000000000000000000000000000000000005009d8e0e00",
       "txinwitness": [
         "0000000000000000000000000000000000000000000000000000000000000000"
       ],
@@ -100,4 +100,3 @@
     }
   ]
 }
```

With the relevant changes from the header being:

```diff
 {
-  "hash": "0000000000000000000157a11e2f0d46474721b0753d076500a91695a59fea25",
+  "hash": "000000000000000000010cb999e87c6ba72be683a24d94aefa99574a19f63f2d",
   "height": 956337,
-  "version": 1073733632,
+  "version": 740425728,
-  "versionHex": "3fffe000",
+  "versionHex": "2c220000",
-  "merkleroot": "a5fbcf14dd84e023ff9bb2e372b98dcd463730cff9d18149326a6ef8660add43",
+  "merkleroot": "7692fe94b98a9f12c8a0b1ee0e497e46c691229fc38696d02f1891a8e8fd9cb6",
-  "time": 1782981823,
+  "time": 1782981814,
   "mediantime": 1782980765,
-  "nonce": 1482529440,
+  "nonce": 3806002134,
   "bits": "17021a42",
   "target": "000000000000000000021a420000000000000000000000000000000000000000",
   "difficulty": 133869853540305.4,
   "chainwork": "0000000000000000000000000000000000000001348d59e5ce33ac605b33eaee",
   "nTx": 5687,
   "previousblockhash": "000000000000000000015bdb19b0b3ee0da5328aef896312feeef2119e034755",
   "strippedsize": 830080,
   "size": 1507586,
   "weight": 3997826,
```

The interesting part here is that the winning block has header timestamp \`1782981823\` vs \`1782981814\` of the loosing block. The winning block timestamp is 9s after the loosing block. Likely due to a slightly older job being worked on.

-------------------------

b10c | 2026-07-02 13:28:23 UTC | #3

Adding the full block and header in https://github.com/bitcoin-data/stale-blocks/pull/111

-------------------------

sudocarlos | 2026-07-02 18:19:57 UTC | #4

[quote="b10c, post:2, topic:147"]
The interesting part here is that the winning block has header timestamp `1782981823` vs `1782981814` of the loosing block

[/quote]

couldnt it also be a result of using the timestamp to roll nonce? https://groups.google.com/g/bitcoindev/c/fCfbi8hy-AE

-------------------------

b10c | 2026-07-03 12:54:28 UTC | #6

On @boerst’s https://stratum.work/height/956337 , the last jobs with an F2Pool coinbase tag were broadcast at 

* F2Pool: `1782981814`
* ntminerPool: `1782981828`
* DogPool: `1782981828`

![image|690x113](upload://7SEtZVaTK35tDM5SpvRJPcsaBa3.png)

Both ntminerPool and DogPool have a slightly higher coinbase output value of 3.14003902 BTC as the winning and loosing blocks (‎3.13976509 BTC), so my guess is that they were indeed generated later.

The page also shows:

![image|690x456](upload://fcSULsEKYaWdeEeOW6Dw6bOEAw1.png)

Which indicates that big parts of the network were mining on the loosing block. Some pools switched to the winning (but 9s later header-timestamp) block:

* nthminerpool and DogPool after 800ms for very short time period.
* BitFuFu after 3.7s
* Poolin, Ultimus, Binance, CloverPool after about 7s

F2Pool themself never switched.

So the timestamp of the winning block might indeed have been rolled to 1782981823, while the loosing block didn’t roll. The loosing block was probably found about 800ms before the winning block. No idea why Antpool’s friends decided to switch, but Antpool not.

-------------------------

sudocarlos | 2026-07-03 13:08:45 UTC | #7

[quote="b10c, post:6, topic:147"]
On @boerst’s [Stratum Work](https://stratum.work/height/956337)
[/quote]

Is there a collection of sites like these? I keep discovering more through posts on these boards, but have never seen a single repository of project links.

-------------------------

m4ycon | 2026-07-06 20:37:35 UTC | #8

I used to keep a personal list for myself (and Vinteum’s discord), but I see that it would be better if I had it somewhere public as it can be useful to someone. Here is a gist where I’ve been aggregating some links that I found interesting through my bnoc readings: [Bitcoin datasource links](https://m4ycon.com/bitcoin-datasource-links). I still need to describe some of them. And you will probably find all of them here in BNOC (for more context).

-------------------------

b10c | 2026-07-07 11:07:45 UTC | #9

There’s also https://bitcoin-noc.github.io/map-of-bitcoin-monitoring/ (a bit out of date, updates welcome)

![image|690x462](upload://1CVmIV3tytg6fIhiUU59GCvfc0X.jpeg)

and a dedicated thread for it: https://bnoc.xyz/t/resources-monitoring-and-network-data/37

and jlopp maintains a page with links too: https://www.lopp.net/bitcoin-information.html

I think this needs a collaborative way of maintaining it. Maybe some kind of BNOC wiki?

-------------------------

