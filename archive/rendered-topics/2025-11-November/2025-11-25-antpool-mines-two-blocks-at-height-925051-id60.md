# AntPool mines two blocks at height 925051

b10c | 2025-11-25 10:25:08 UTC | #1

At height 925051, AntPool mined two blocks. The stale block and header for `0000000000000000000199dc74f0c7d25adc618618ee00db80884b347253c264` can be found [here](https://github.com/bitcoin-data/stale-blocks/commit/0dd72148e1f3793b18fe9313e1a55bdf3456bc86). 


![image|689x489](upload://nfnLQt0dd6YkBmhgEHDYlkni0S3.png)


The blocks are fairly similar in size and transaction count. Their header timestamps match.  

![image|690x342](upload://2UPexaLr7vrArFWlIsqshtLiXo3.png)

![image|690x482](upload://g4qOXNLMNwwzlMOe8JSZop6pD1U.png)


Possibly, the templates for the two blocks were generated in different pool regions (e.g. US and EU) and two miners happened to find a valid nonce for them.

-------------------------

b10c | 2025-11-25 10:42:04 UTC | #2

```bash
$ diff stale-coinbase-925051.json winning-coinbase-925051.json
2,4c2,4
<   "in_active_chain": false,
<   "txid": "d90685cda3a9b089b0a3d6767e97a2a3f0bff97bbcd4bfb3961f6f8f838024af",
<   "hash": "ddc4800437f12adb71ba57564f9d087ae3c32e85452daa5b4fd55b116494b23c",
---
>   "in_active_chain": true,
>   "txid": "ee69df9fd46383c0270f10b1099fb2be7181d3c25598fba953d63c4ff7cae164",
>   "hash": "cb5becf903406b5c6168daa0bfa7770853b057456784e2b917a62071d6cb9c0b",
6,8c6,8
<   "size": 472,
<   "vsize": 445,
<   "weight": 1780,
---
>   "size": 474,
>   "vsize": 447,
>   "weight": 1788,
12c12
<       "coinbase": "037b1d0e1a4d696e656420627920416e74506f6f6c20ed006c02d60b80b001fabe6d6dcce60713ceeff291c999b9556fb739bf1ed548ef7e6600e6642b428d06a68d96100000000000000000009e9918d8000000000000",
---
>       "coinbase": "037b1d0e1c4d696e656420627920416e74506f6f6c393730d2006302d60b312d02fabe6d6d5e131ec1ab2db5482bd3d4c83653a2e4b3a9f0223930e7f12982fc307be93c3610000000000000000000fa7b0f00000000000000",
32c32
<       "value": 3.14547253,
---
>       "value": 3.14549260,
46,48c46,48
<         "asm": "OP_RETURN aa21a9ed700851f2aac740fc073b644b1af2084edf40d19e58a0cc4a66e621f82e28ea85",
<         "desc": "raw(6a24aa21a9ed700851f2aac740fc073b644b1af2084edf40d19e58a0cc4a66e621f82e28ea85)#4a5r87p9",
<         "hex": "6a24aa21a9ed700851f2aac740fc073b644b1af2084edf40d19e58a0cc4a66e621f82e28ea85",
---
>         "asm": "OP_RETURN aa21a9ed915f1259d09a324ddc1552b8e1730279e9f0c8302bd2d85e487aceb52836cb2a",
>         "desc": "raw(6a24aa21a9ed915f1259d09a324ddc1552b8e1730279e9f0c8302bd2d85e487aceb52836cb2a)#g9gn7u7y",
>         "hex": "6a24aa21a9ed915f1259d09a324ddc1552b8e1730279e9f0c8302bd2d85e487aceb52836cb2a",
56,58c56,58
<         "asm": "OP_RETURN 434f524501a37cf4faa0758b26dca666f3e36d42fa15cc01064e3ecda72cb7961caa4b541b1e322bcfe0b5a030",
<         "desc": "raw(6a2d434f524501a37cf4faa0758b26dca666f3e36d42fa15cc01064e3ecda72cb7961caa4b541b1e322bcfe0b5a030)#djrqagdj",
<         "hex": "6a2d434f524501a37cf4faa0758b26dca666f3e36d42fa15cc01064e3ecda72cb7961caa4b541b1e322bcfe0b5a030",
---
>         "asm": "OP_RETURN 434f52450142fdeae88682a965939fee9b7b2bd5b99694ff644e3ecda72cb7961caa4b541b1e322bcfe0b5a030",
>         "desc": "raw(6a2d434f52450142fdeae88682a965939fee9b7b2bd5b99694ff644e3ecda72cb7961caa4b541b1e322bcfe0b5a030)#genhdn6c",
>         "hex": "6a2d434f52450142fdeae88682a965939fee9b7b2bd5b99694ff644e3ecda72cb7961caa4b541b1e322bcfe0b5a030",
93,95c93,97
<   "hex": "010000000001010000000000000000000000000000000000000000000000000000000000000000ffffffff57037b1d0e1a4d696e656420627920416e74506f6f6c20ed006c02d60b80b001fabe6d6dcce60713ceeff291c999b9556fb739bf1ed548ef7e6600e6642b428d06a68d96100000000000000000009e9918d8000000000000ffffffff07220200000000000017a91442402a28dd61f2718a4b27ae72a4791d5bbdade787359cbf120000000017a9145249bdf2c131d43995cff42e8feee293f79297a8870000000000000000266a24aa21a9ed700851f2aac740fc073b644b1af2084edf40d19e58a0cc4a66e621f82e28ea8500000000000000002f6a2d434f524501a37cf4faa0758b26dca666f3e36d42fa15cc01064e3ecda72cb7961caa4b541b1e322bcfe0b5a0300000000000000000146a12455853415401000d130f0e0e0b041f1200130000000000000000296a27737973c358d62a6390f7cf4475c4c09496140a8e4c7dcfc3e558a300ef7bc72ce783d3aaad200000000000000000002b6a2952534b424c4f434b3a86499abc17e3b29a49658ba3335e54c353242303aa457af95a50b917007dc5950120000000000000000000000000000000000000000000000000000000000000000000000000",
<   "blockhash": "0000000000000000000199dc74f0c7d25adc618618ee00db80884b347253c264",
<   "confirmations": 0
---
>   "hex": "010000000001010000000000000000000000000000000000000000000000000000000000000000ffffffff59037b1d0e1c4d696e656420627920416e74506f6f6c393730d2006302d60b312d02fabe6d6d5e131ec1ab2db5482bd3d4c83653a2e4b3a9f0223930e7f12982fc307be93c3610000000000000000000fa7b0f00000000000000ffffffff07220200000000000017a91442402a28dd61f2718a4b27ae72a4791d5bbdade7870ca4bf120000000017a9145249bdf2c131d43995cff42e8feee293f79297a8870000000000000000266a24aa21a9ed915f1259d09a324ddc1552b8e1730279e9f0c8302bd2d85e487aceb52836cb2a00000000000000002f6a2d434f52450142fdeae88682a965939fee9b7b2bd5b99694ff644e3ecda72cb7961caa4b541b1e322bcfe0b5a0300000000000000000146a12455853415401000d130f0e0e0b041f1200130000000000000000296a27737973c358d62a6390f7cf4475c4c09496140a8e4c7dcfc3e558a300ef7bc72ce783d3aaad200000000000000000002b6a2952534b424c4f434b3a86499abc17e3b29a49658ba3335e54c353242303aa457af95a50b917007dc5950120000000000000000000000000000000000000000000000000000000000000000000000000",
>   "blockhash": "000000000000000000001a9d946d1c41cae21fb89a227b51371d32dcbad2f40d",
>   "confirmations": 57,
>   "time": 1764021928,
>   "blocktime": 1764021928
```

-------------------------

Antoine | 2025-12-04 15:09:24 UTC | #3

[quote="b10c, post:1, topic:60"]
Possibly, the templates for the two blocks were generated in different pool regions (e.g. US and EU) and two miners happened to find a valid nonce for them.

[/quote]

Or they run different full nodes of different versions from which to serve block templates. This would also explain the “internal discrepancies” we’ve previously noticed: a pool sometimes mining ephemeral anchors and sometimes not, sometimes mining large opreturns and sometimes not.

[ViaBTC](https://bnoc.xyz/t/viabtc-mining-pool-mines-multiple-blocks-at-same-height/48?u=antoine), and now Antpool. Is this a new practice, or are we just observing this behaviour now?

-------------------------

b10c | 2026-07-02 09:50:55 UTC | #4

[quote="Antoine, post:3, topic:60"]
or are we just observing this behaviour now?

[/quote]

happened again for F2Pool this time: https://bnoc.xyz/t/f2pool-mines-two-blocks-at-height-956337/147

-------------------------

