+++
title = "No Shorts Please! Hidden YouTube RSS Feed URLs"
date = "2025-01-08"
tags = ["rss","tech",]
+++

{{< custom-toc >}}

## Introduction

I consume quite a lot of content from YouTube, via their RSS feeds, and this was working fine until they added *Shorts*. I struggled to find a way to get the shorts out of my feed, eventually settling on scraping the YouTube API to query the video, and filtering out any that had a duration that was less than 61 seconds.

I accepted the odd false positive of a genuine regular video being less than a minute, it worked and it seemed like the least worst option.

Then around October 2024, I started to notice shorts reappearing in my mailboxes, and discovered that YouTube had *increased* the maximum length of a short to a whopping 3 minutes. The false positives for assuming all 3 minute or less videos were shorts was too much, so I went back to the drawing board to see if I could find a better workaround.. and surprisingly I found a much easier (but seemingly undocumented) way.

## Playlist IDs

### All Videos

This is the one you can find using "view source" on the "Videos" page of a channel.

```html
<link
   rel="alternate"
   type="application/rss+xml"
   title="RSS"
   href="https://www.youtube.com/feeds/videos.xml?channel_id=UCabcdefgh">
```

### No Shorts

If you replace `channel_id` with `playlist_id` and replace the leading `UC` prefix from `UCabcdefgh` with `UULF` you can get the RSS feed without shorts.

```diff
-https://www.youtube.com/feeds/videos.xml?channel_id=UCabcdefgh`
+https://www.youtube.com/feeds/videos.xml?playlist_id=UULFabcdefgh`
```

Voilà! No more #shorts!

## Credit

My source for this was a Stack Overflow post entitled [YouTube channel and playlist ID prefixes](https://stackoverflow.com/questions/19795987/youtube-channel-and-playlist-id-prefixes/77816885#77816885) by user [Krateng](https://stackoverflow.com/users/6651341/krateng).

That link has the following additional playlist IDs:

```
    UU - all public uploads (videos + shorts + live streams)
    UULF - all public videos
    UUMO - all member videos (alternative UUMF)
    UULV - all live streams
    UUSH - all shorts
    UULP - popular videos
    UUPV - popular live streams
    UUPS - popular shorts
    UUMV - member live streams
    UUMS - member shorts
```

## Undocumented

Notice how this is completely undocumented by Google? I wonder why... :thinking:
