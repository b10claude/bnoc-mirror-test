# Request: Transaction relay dataset

seed-cat | 2026-11-25 19:20:30 UTC | #1

Wondering if anyone has historical transaction relay data?  I would like to compare different relay policies, e.g. increasing the sat/byte to RBF.  Ideally I would have:

* When a transaction was first seen in the mempool
* Txid alone is okay, but would be good to have raw transaction data in case the tx did not confirm

Ideal time period would cover recent years.

-------------------------

b10c | 2026-11-25 19:12:35 UTC | #2

Can you specify a bit more what you are looking for? Are you looking for timestamps when a node received a transaction? Do you need the full transaction, or are txids enough? Are you interested in per-node data (and if so why?) or is "at this timestamp some node in the network saw a transaction first" enough? What would an ideal dataset look like for you and what would you use it for? This usually helps the people with data to know if their data might be a good fit.

Feel free to update the OP with this.

-------------------------

