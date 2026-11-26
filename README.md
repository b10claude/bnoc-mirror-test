# discourse-mirror

A self-updating archive of a Discourse forum, and a static mirror of it.

Every night a GitHub Actions run fetches the posts made since the last run,
commits them to this repository, and publishes a browsable HTML mirror to
GitHub Pages. The posts, their metadata and every image uploaded to the forum
are stored here as plain files, so the archive outlives both the forum and
GitHub.

The fetching and rendering are done by
[discourse-archive](https://github.com/0xB10C/discourse-archive); this
repository holds the data, the schedule and the configuration.

## Setting one up

1. Click **Use this template** to make a repository for the forum you want to
   mirror. One repository per forum.
2. Edit [`config.env`](config.env) and commit it. Only `DISCOURSE_URL` is
   required:

   ```sh
   DISCOURSE_URL=https://delvingbitcoin.org
   ```

3. In **Settings → Pages**, set **Source** to **GitHub Actions**. Without this
   the archive still syncs, but publishing the mirror fails.
4. In **Actions → sync**, choose **Run workflow**. The first run archives the
   forum from scratch, so give it time: a few thousand posts and their images
   take tens of minutes, mostly spent waiting politely between requests.

After that it runs itself, nightly at 03:41 UTC.

For a forum large enough that the first run might not finish inside a job's
six hours, do that first archive on your own machine with `make sync` and
commit it. Every run after that only fetches what is new, which is quick.

## What a nightly run does

1. **Fetches new posts, with their images.** The archiver asks for the posts
   created since the last sync, plus a day of overlap so edits are picked up,
   and saves each one as JSON. Every image a post references is downloaded as
   the post is saved, and the mirror serves its own copy, so the pages keep
   their illustrations once the forum is gone. This is on by default; turn it
   off with `ARCHIVE_IMAGES=` in `config.env` if you only want the text.
2. **Repairs what is missing.** Two backfill passes fetch any topic metadata
   or image that is absent from the archive. They cost nothing when the archive
   is complete, and they fix up after a run that failed halfway.
3. **Commits whatever changed**, with a message like
   `sync: 12 new posts, 1 edited post, 4 new uploads`.
4. **Renders and publishes the mirror** to GitHub Pages: a page per topic, plus
   listings by latest activity, by category, by tag and by views.

On the day of the month set by `FULL_SYNC_DAY` the first step walks every post
on the forum instead of only the recent ones. This repairs gaps that an
incremental sync cannot see, such as a topic that was unlisted when it was
first synced and made public later. It is also what you get from **Run
workflow** with *full sync* ticked.

It costs almost nothing in the repository. A re-fetched post comes back
byte-for-byte identical, so git has nothing to record for it. What does change
are the counters the forum keeps, a post's incoming links or a topic's views
and likes, so a full sync commits the handful of files whose numbers have
moved and leaves the rest alone.

A run that fails partway still commits what it fetched and still republishes
the mirror, so a bad night costs you a day of posts rather than the archive.

## What is in here

```
archive/
├── categories.json          the forum's category list
├── posts/<month>/*.json     one file per post, the API response as-is
├── topics/<month>/*.json    per-topic metadata: category, tags, participants
├── rendered-topics/*.md     each topic as the markdown it was written in
├── uploads/<sha1>.<ext>     every image uploaded to the forum, once each
└── .metadata.json           how far the last sync got
LAST_SYNC                    when the last run finished
config.env                   the settings for this mirror
```

The rendered site is not committed. It is built from `archive/` on every run
and published straight to Pages, so there is one copy of everything.

### How big this gets

The archive is roughly the size of the forum's text plus its images. For a
forum of 4,300 posts that is about 110 MB, nearly all of it images.

It grows steadily rather than repeatedly: posts are small, and an upload is
stored under the hash of its contents, so it is written once and never
rewritten. Git handles that well. A busy forum adds tens of megabytes a year.
GitHub starts asking questions above 1 GB, which is years away for most
forums, and a fresh clone is the only thing that ever pays for the history.

## Running it yourself

The `Makefile` runs the same steps the workflow does, reading the same
`config.env`. It needs Python 3.11 or newer and git.

```sh
% make sync        # fetch new posts, then repair anything missing
% make full-sync   # re-fetch every post
% make serve       # render the mirror and serve it on localhost:8000
```

`make` keeps its own checkout of the archiver in `.archiver/`, at the ref
`config.env` pins.

Committing a local sync is up to you; the nightly run will fetch the same posts
if you don't.

## When something goes wrong

**The nightly run stopped happening.** GitHub disables scheduled workflows in
repositories with no activity for 60 days. The nightly commit of `LAST_SYNC`
normally counts as activity, which is why it is committed even on a night with
no new posts. If the schedule is disabled anyway, GitHub shows a banner on the
Actions tab with a button to re-enable it.

**A run failed.** Look at which step. A failure while fetching usually means
the forum rate-limited the runner or was down; the archiver retries with
growing delays before giving up, and the next night carries on where it
stopped. Nothing is lost, because the archive is only ever added to.

**An image loads from the forum instead of the mirror.** Avatars, emoji and
images hosted elsewhere are linked, not archived; only what was uploaded to
the forum is copied here. A post's own image doing this means the archive does
not have it yet, which the next run fixes.

**The mirror is missing images, or a topic shows a gap warning.** Run the
workflow by hand with *full sync* ticked. Anything still missing afterwards was
deleted or moderated away on the forum, which no amount of re-fetching brings
back.

**Pages publishes nothing.** Check that **Settings → Pages → Source** is
**GitHub Actions**.

## Mirroring more than one forum

Make one repository per forum, each from this template, each with its own
`config.env`. They are independent: separate schedules, separate archives,
separate Pages sites.

```sh
DISCOURSE_URL=https://delvingbitcoin.org
DISCOURSE_URL=https://bnoc.xyz
```

## A note on being a good guest

A sync makes a few hundred requests to a forum that is probably hosted on
someone's budget. The archiver waits between requests and backs off when it is
refused; please leave those delays alone, keep to one run a night, and do not
point several repositories at the same forum.
