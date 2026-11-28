# An observation on ports

naiyoma | 2026-11-28 09:27:22 UTC | #1

Since around October, watching the  addresses my node receives, I've noticed a few distinct, non-standard ports that keep showing up.

## **The ports**

### **:58333**

\- I've received **30,561 distinct addresses** on this port, scattered across many /16s. I never see them announce themselves, every one reaches me second-hand, gossiped by roughly **2,300 of my ordinary peers**.

\- A uniform, pruned fleet: almost all carry the same service flags,

**3081** = NET + WITNESS + LIMITED+ V2.

\- By AS they skew to **residential ISPs** the single biggest is **Starlink (AS14593), around 21%**, followed by Comcast, Deutsche Telekom and the like. Almost no cloud hosting.

### **:39388**

\- **9,100 distinct addresses**, reaching me the same way gossiped by my peers, never announcing themselves again a uniform pruned fleet,

**3080** = WITNESS + LIMITED + V2, the same as :58333 but **without NET**.

\- By AS these are the **opposite** of :58333: they cluster on **cloud/VPS hosting** (Cogent, Lunanode, Hetzner, DigitalOcean).

### **Behaviour**

from log history, I tried connecting to these addresses over 2,500 times, 

1,255 to :58333, 1,249 to:39388,  and not one connection ever succeeded. Every attempt timed out, was refused, or otherwise failed.

-------------------------

