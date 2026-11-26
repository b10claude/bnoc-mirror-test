# Setting up a BNOC wiki?

b10c | 2026-07-07 11:28:48 UTC | #1

I’ve been thinking about a BNOC wiki for all sorts of topics. One idea was to have a sort of [llm-wiki](https://www.mindstudio.ai/blog/andrej-karpathy-llm-wiki-knowledge-base-claude-code) style wiki feed with resources, links and ideas from this forum and others. Opening this for discussion here.

I also thought about a manual wiki, but this will probably be out-date and stale at some point.

-------------------------

m4ycon | 2026-07-07 18:09:35 UTC | #2

ACK! I totally support this, and agree that a manual way of doing it would be very bad to maintain.

Brainstorming some ideas:

I see that it is possible to get information in a json format from this website ([here](https://bnoc.xyz/posts.json) and [here](https://bnoc.xyz/latest.json)). I think a repository in [bitcoin-noc github](https://github.com/bitcoin-noc) could have a cron job running an action. When it sees an update, we could feed the data through an llm, so then it could make a commit from it (or a PR?).

Your reference talks about how can we organize folders/files to serve an llm as context. However, I also see that an interesting format would be the [Map of Bitcoin Monitoring](https://bitcoin-noc.github.io/map-of-bitcoin-monitoring/), this organization of graph, it seems a task that a llm would handle well – no need to be that visual but a category/subcategory like sounds good. I think this would be better for human reading, maybe also for llms (?).

Regarding content on this wiki, I think initially would be good to just gather links and give them some brief context (like I poorly did [here](https://m4ycon.com/bitcoin-datasource-links) haha). Maybe at some moment, summaries from posts and references for similar ones.

-------------------------

b10c | 2026-07-10 07:31:34 UTC | #3

Apparently, Discourse has a wiki mode. So instead of separating the wiki and the forum, we could have a wiki section here: https://meta.discourse.org/t/editing-and-creating-wiki-posts/30801

-------------------------

