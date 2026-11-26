# DigitalOcean /Satoshi:24.0.1/ spy nodes connected during IBD

b10c | 2025-10-13 18:08:15 UTC | #1

While setting up a nodes for https://demo.peer.observer, I noticed on the [netinfo.html](https://demo.peer.observer/websocket/netinfo.html) page that I immediately get inbound connections for spy nodes. These connect even while during IBD.

on hal:

| id  | ip                                                | user agent                        | tag | connection type             | network  | transport | tx relay  | addr relay | received | sent | connected time | addr processed    |  addr rate limited | ping   | minping | feefilter         |
|------|---------------------------------------------------------------------|-----------------------------------------|:---:|---------------------|-------|----|-------|-------|--------|--------|-------|------|---|-------|-----|-----------|
| 219 | 46.101.92.98:33182                 | /Satoshi:24.0.1/ | spy | inbound | ipv4 | v1 | true | false | 0.0 MB | 0.0 MB | 3472s | 0 | 145 | 144 | - |
| 220 | [2a03:b0c0:1:d0::f1b:c001]:49122   | /Satoshi:24.0.1/ | spy | inbound | ipv6 | v1 | true | false | 0.0 MB | 0.0 MB | 3452s | 0 | 152 | 148 | - |
| 227 | [2a03:b0c0:3:d0::d3e:9001]:48470   | /Satoshi:24.0.1/ | spy | inbound | ipv6 | v1 | true | false | 0.0 MB | 0.0 MB | 2797s | 0 | 155 | 154 | - |
| 228 | 207.154.205.24:45798               | /Satoshi:24.0.1/ | spy | inbound | ipv4 | v1 | true | false | 0.0 MB | 0.0 MB | 2795s | 0 | 165 | 164 | - |
| 229 | 174.138.24.121:45734               | /Satoshi:24.0.1/ | spy | inbound | ipv4 | v1 | true | false | 0.0 MB | 0.0 MB | 2777s | 0 | 239 | 237 | - |
| 230 | [2400:6180:0:d0::108d:2001]:54518  | /Satoshi:24.0.1/ | spy | inbound | ipv6 | v1 | true | false | 0.0 MB | 0.0 MB | 2773s | 0 | 244 | 243 | - |
| 245 | [2604:a880:400:d0::e6a:6001]:49774 | /Satoshi:24.0.1/ | spy | inbound | ipv6 | v1 | true | false | 0.0 MB | 0.0 MB | 1230s | 0 | 79  | 78  | - |
| 246 | 24.144.98.209:55060                | /Satoshi:24.0.1/ | spy | inbound | ipv4 | v1 | true | false | 0.0 MB | 0.0 MB | 1227s | 0 | 78  | 78  | - |


on len:


| id  | ip                                                | user agent                        | tag | connection type             | network  | transport | tx relay  | addr relay | received | sent | connected time | addr processed    |  addr rate limited | ping   | minping | feefilter         |
|------|---------------------------------------------------------------------|-----------------------------------------|:---:|---------------------|-------|----|-------|-------|--------|--------|-------|------|---|-------|-----|-----------|
| 158 | 46.101.92.98:37552   | /Satoshi:24.0.1/ | spy | inbound | ipv4 | v1 | true | false | 0.0 MB | 0.0 MB | 3624s | 0 | 143 | 143 | - |
| 163 | 207.154.205.24:47044 | /Satoshi:24.0.1/ | spy | inbound | ipv4 | v1 | true | false | 0.0 MB | 0.0 MB | 2949s | 0 | 157 | 157 | - |
| 164 | 174.138.24.121:36286 | /Satoshi:24.0.1/ | spy | inbound | ipv4 | v1 | true | false | 0.0 MB | 0.0 MB | 2929s | 0 | 239 | 239 | - |
| 170 | 24.144.98.209:53702  | /Satoshi:24.0.1/ | spy | inbound | ipv4 | v1 | true | false | 0.0 MB | 0.0 MB | 1382s | 0 | 77  | 77  | - |


These seem to be the same IP addresses connected to both nodes.

-------------------------

