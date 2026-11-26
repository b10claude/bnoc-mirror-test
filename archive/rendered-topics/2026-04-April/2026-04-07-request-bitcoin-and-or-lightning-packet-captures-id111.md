# Request: Bitcoin and/or Lightning packet captures

cndolo | 2026-04-07 20:17:23 UTC | #1

Hi,

I’m currently working on a research project and looking to strengthen my dataset with more vantage points besides my own. We are interested in traffic analysis, and in particular (for now) detection and classification of encrypted network traffic.

Would anyone here be willing to provide TCP traces of a Bitcoin or Lightning node? In the case of Bitcoin, the node needs to have some V2 transport connections. For Lightning, it would need to be a node with some channels (not just P2P connections).

Here’s the command I’ve been using on my own servers: `tshark -i eth0 -f "tcp port 8333" -a filesize:1548576 -w /path/to/capture.pcap`. We then process the pcaps and extract various features related to size, timing and direction. For the latter, I’d need to know your nodes IP and listening port (if not the default).

Thanks.

-------------------------

jonhbit | 2026-04-07 18:57:26 UTC | #2

I may be able to help out here - is there any interest in capturing traffic from Tor that's being sent/received via the Tor daemon SOCKS5 proxy as well?

-------------------------

cndolo | 2026-04-07 20:04:12 UTC | #3

No Tor for now but if you can help out with regular LN traffic, that would be great. thanks.

-------------------------

b10c | 2026-04-07 20:19:27 UTC | #4

Welcome @cndolo!

Happy to record traffic for a while on the two https://demo.peer.observer nodes I'm running! Both of them have v2 and v1 transport peers as well as usually full inbound slots.

I just started a capture with the command you provided. I will figure out a way to get this to you.

Once you're done with the paper, feel free to post it in the research section (https://bnoc.xyz/c/research/7) or in this thread. I think you'll find a few interested readers here!

-------------------------

Razor | 2026-04-08 02:18:43 UTC | #5

Hi @cndolo,

I have captured traffic in the last month, from a pruned Bitcoin V2 node. This is part of a project similar to yours, but only focusing on Bitcoin V2 transport: https://github.com/RazorBest/bip324-traffic-analysis

I can provide you with the pcaps. Feel free to reach out.
[@razor2ii:matrix.org](https://matrix.to/#/@razor2ii:matrix.org)

-------------------------

b10c | 2026-04-09 11:35:02 UTC | #6

I shared captures from the demo nodes `len` and `hal` with @cndolo. Happy to share them with anyone interested - just ask - but not comfortable with publishing them here at the moment. I'll keep them around for a while, but probably not forever. They are about 1GB each compressed.

Here are some stats on them:

```
$ capinfos len.pcap
File name:           len.pcap
File type:           Wireshark/... - pcapng
File encapsulation:  Ethernet
File timestamp precision:  nanoseconds (9)
Packet size limit:   file hdr: (not set)
Number of packets:   5,229 k
File size:           1,548 MB
Data size:           1,372 MB
Capture duration:    17496.581138277 seconds
Earliest packet time: 2026-04-07 22:10:41.600974645
Latest packet time:   2026-04-08 03:02:18.182112922
Data byte rate:      78 kBps
Data bit rate:       627 kbps
Average packet size: 262.47 bytes
Average packet rate: 298 packets/s
SHA256:              a0284baadc4f46c6f595a3a265eee95193234824254c7cdced14b21df69d408f
SHA1:                b824d80e8f64ebd8aa310a6eea9c68f0d91253be
Strict time order:   False
Capture hardware:    AMD EPYC-Genoa Processor (with SSE4.2)
Capture oper-sys:    Linux 6.12.61
Capture application: Dumpcap (Wireshark) 4.6.3 (Git commit 648f69f3e168)
Number of interfaces in file: 1
Interface #0 info:
                     Name = enpXXX
                     Encapsulation = Ethernet (1 - ether)
                     Capture length = 262144
                     Time precision = nanoseconds (9)
                     Time ticks per second = 1000000000
                     Time resolution = 0x09
                     Filter string = tcp port 8333
                     Operating system = Linux 6.12.61
                     Number of stat entries = 1
                     Number of packets = 5229124
```

```
$ capinfos hal.pcap
File name:           bnoc-111-hal.pcap
File type:           Wireshark/... - pcapng
File encapsulation:  Ethernet
File timestamp precision:  nanoseconds (9)
Packet size limit:   file hdr: (not set)
Number of packets:   6,135 k
File size:           1,548 MB
Data size:           1,341 MB
Capture duration:    21734.006948974 seconds
Earliest packet time: 2026-04-07 22:12:06.589213013
Latest packet time:   2026-04-08 04:14:20.596161987
Data byte rate:      61 kBps
Data bit rate:       493 kbps
Average packet size: 218.72 bytes
Average packet rate: 282 packets/s
SHA256:              0b8f78e617f03c4d6f9376a7b6b970c0fabed8f2276564295af02c425fa3cb37
SHA1:                4d00fd877d29c3e6fd7c83032ed77102a798df2d
Strict time order:   False
Capture hardware:    AMD EPYC-Genoa Processor (with SSE4.2)
Capture oper-sys:    Linux 6.12.69
Capture application: Dumpcap (Wireshark) 4.6.3 (Git commit 648f69f3e168)
Number of interfaces in file: 1
Interface #0 info:
                     Name = enpXXX
                     Encapsulation = Ethernet (1 - ether)
                     Capture length = 262144
                     Time precision = nanoseconds (9)
                     Time ticks per second = 1000000000
                     Time resolution = 0x09
                     Filter string = tcp port 8333
                     Operating system = Linux 6.12.69
                     Number of stat entries = 1
                     Number of packets = 6135294
```

-------------------------

cndolo | 2026-04-09 14:40:42 UTC | #7

Thanks a lot. This will be very helpful for my research and will update when the paper is done.

-------------------------

b10c | 2026-05-26 13:38:01 UTC | #8

I went ahead and uploaded the packet captures publicly on the https://bitcoin-noc.github.io/datashare-website/ in the `2026-04-bitcoind-packet-captures` folder. Feel free to use these for research projects.

-------------------------

b10c | 2026-10-19 19:27:15 UTC | #9

[quote="cndolo, post:7, topic:111, full:true"]
Thanks a lot. This will be very helpful for my research and will update when the paper is done.
[/quote]

Paper is here: https://bnoc.xyz/t/follow-up-to-data-request-research-paper-on-passive-network-attack/188

-------------------------

