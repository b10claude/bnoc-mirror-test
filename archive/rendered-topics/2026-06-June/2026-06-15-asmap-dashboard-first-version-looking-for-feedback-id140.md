# ASmap dashboard: first version, looking for feedback

jorisstrakeljahn | 2026-06-15 12:21:22 UTC | #1

Hi,

I’d like to share the first version of a dashboard I’ve been building as a Summer of Bitcoin project, mentored by fjahr and jurraca.

A quick thank you to @b10c and @matthias / the KIT DSN group for providing the historical node data. It lets me compare the asmap-data files against the actual Bitcoin network, so the analysis isn’t based on the asmap-data files alone.

The first version is live here: https://jorisstrakeljahn.github.io/asmap-dashboard/

It shows the bitcoin-core/asmap-data history: drift between builds, per-release entry counts, a diff explorer, and a Network tab that scores each ASmap build against observed nodes.

Since it’s still early, I’d really value some feedback:

* Do the metrics make sense and feel useful?
* Is anything confusing or unclear?
* Is a metric or view missing that you’d want to see?
* Any bugs you run into?

Thanks!

-------------------------

sudocarlos | 2026-06-16 04:23:19 UTC | #2

very nice. only nit based on mobile is that the legends that appear when tapping on the graph hides the graph and the spot the legend references. display the legend below the graph and draw a vertical point to represent the spot instead

-------------------------

jorisstrakeljahn | 2026-06-16 08:12:13 UTC | #3

Good catch, thanks. Mobile is the part I’ve tested least and you’re right, that’s not good. I will look into the cleanest way to fix it

-------------------------

b10c | 2026-06-20 08:16:54 UTC | #4

Cool! Some feedback: A possible UX improvement could be to move parts of the ⓘ texts below the title. Currently, these charts feel optimized for recurring visitors who know what to look for and know what each chart shows (and if that’s the goal, then it’s probably fine). However, people who want to explore and learn about ASMap might have a harder time understanding the charts. 

![image|690x282](upload://sQ3FjE3zLJooF0BXLRIGASHjMjX.png)

Having a one-line description of what the chart shows and then more information below might better for “new“ visitors. Maybe something like this:

![image|690x308](upload://Ac2zgQzAbJNFS4mo1hX0XLOOuov.png)

Where the extra information is presented in a 

[details="About the decay curve"]
Lorem ipsum

[/details]

If it’s not too much text, it makes sense to always show it.

-------------------------

jorisstrakeljahn | 2026-06-25 14:24:47 UTC | #5

Thanks, great point! New version is live:

Charts now show an always-visible one-line explanation under the title, so it should be quicker to understand what you’re looking at (think that helps a lot). I also improved the mobile/touch layout so the legend no longer covers the chart.

-------------------------

