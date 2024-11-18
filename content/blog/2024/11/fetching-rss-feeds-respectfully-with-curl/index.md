+++
title = "Fetching RSS Feeds Respectfully With curl"
date = "2024-11-09"
tags = ["tech", "rss"]
+++

{{< custom-toc >}}

## Introduction

I am a member of the Church of RSS, though I'm quite a late convert (I missed the whole [Google Reader](https://en.wikipedia.org/wiki/Google_Reader) thing). I use my own self-written Golang tools to parse the RSS/Atom feed files and send myself the entries in an email. 

I haven't felt the need to do anything too fancy on the downloading the RSS feeds part, and use the venerable [`curl`](https://curl.se/) in a bash script.

I've tightened up this `curl` feed downloader in response to [various](https://rachelbythebay.com/w/2024/05/27/feed/) [blog](https://rachelbythebay.com/w/2024/06/11/fsr/) [posts](https://rachelbythebay.com/w/2024/06/28/fsr/) [by](https://rachelbythebay.com/w/2024/08/02/fs/) [Rachel By The Bay](https://rachelbythebay.com/w/) and [recent](https://utcc.utoronto.ca/~cks/space/blog/web/IfModSinceTimestampProblem) [posts](https://utcc.utoronto.ca/~cks/space/blog/web/FeedReadersLeaveTimestampsAlone) by [CKS](https://utcc.utoronto.ca/~cks/space/blog/) in the same vein.

## Conditional Requests?

Sending Conditional Requests to hundreds of web servers in `curl` is actually a little fiddly, so I thought I'd document how I go about it.

I have about 500 RSS feed URLs that I download, and I want to get as many `304 Not Modified` responses as possible - that's the "respectfully" part.

## Generate and Use a `curl` config

A naive way to use `curl` to download multiple URLs would be to call `curl` in a loop, once per URL. This is inefficient for you and the remote servers you're hitting, so don't do it that way.

Generate a **curl config** file and use that. This will use less of your own resources, by amortizing the start-up cost of the `curl` binary, and the only way to benefit from connection reuse (TCP/HTTP/HTTPS) which saves time, bandwidth and compute.

> The term `curl config` sounds like it would just be a way to configure some defaults in `curl` (and I believe it's used for that purpose), but it's also a way to pass a reeaaaaally long list of command-line arguments to `curl`.

I have a long text file called `truth.txt` which contains my RSS feed urls (and a feed name). My bash script generates a [`curl` config file](https://everything.curl.dev/cmdline/configfile.html) on the fly that tells `curl` what to download, where and how.

So we generated the `curl config` then call curl *once* with this argument `curl --config truth.curl`. 

This line in `truth.txt`...

```
tech.CitizenLab https://citizenlab.ca/feed/
```

...becomes this entry in `truth.curl`. Most of it is boilerplate, but the `etag-compare/save` and `time-cond` lines are dependent on whether the server sent us `Last-Modified` and/or `Etag` headers.

```
fail
compressed
max-time = 30
no-progress-meter
alt-svc = alt-svc-cache.txt
etag-compare = tech.CitizenLab.rss.etag
etag-save = tech.CitizenLab.rss.etag
output = tech.CitizenLab.rss.xml
time-cond = "Tue, 05 Nov 2024 15:00:35 GMT"
write-out = "%output{tech.CitizenLab.rss.lm}%header{last-modified}"
url = "https://citizenlab.ca/feed/"
next
```

### Last-Modified / If-Modified-Since

I used to follow the [recommendation in curl's documentation](https://everything.curl.dev/http/modify/conditionals.html#check-by-modification-date) on how to handle `Last-Modified` headers.

```bash
curl --remote-time --time-cond file.html --output file.html
  https://example.com/file.html
```

By using `--remote-time` the timestamp of the written RSS feed file will be set to the date in the server's `Last-Modified` header. The next request we would add the conditional request by sending that file's timestamp in the `If-Modified-Since` header.

The downside is that if the server *didn't* send us a `Last-Modified` header, the timestamp of the file will just be the last time we downloaded it, and we are [sending an arbitary Date and Time](https://utcc.utoronto.ca/~cks/space/blog/web/IfModSinceTimestampProblem) which actually reduces the number of 304s we get.

I have solved this issue by using the `curl` command-line argument called `write-out`. This tells `curl` to write the content of the server's `last-modified` response header to the file `tech.CitizenLab.rss.lm`.

```
write-out = "%output{tech.CitizenLab.rss.lm}%header{last-modified}"
```

Then in the bash script that generates the `curl` config, we set the `time-cond` parameter to the content of the `.lm` file (something like `Tue, 05 Nov 2024 15:00:35 GMT`) as long as the `.lm` file is not 0 bytes. We have to check for zero byte files, as if the server didn't send a `Last-Modified` header `curl` will write an empty file. Sending an empty value is not going to help us, and reduce our chances of getting a `304`. 


```bash
if [[ -s xml/$FILENAME.lm ]]; then
    echo "time-cond = \"$(cat xml/$FILENAME.lm)\"" >>$CURL_CONFIG_TMP
fi
```

### eTag / If-None-Match  

Similar to `Last-Modified` - I used to follow the [recommendation in curl's documentation](https://everything.curl.dev/http/modify/conditionals.html#check-by-modification-of-content) on how to handle `eTag` headers.

```bash
curl --etag-compare etag.txt --etag-save etag.txt \
  https://example.com/file -o output
```

But this again has the problem that if the server did not send an eTag header in it's reponse, we will write an empty file, and on the next invocation we will send a confusing `If-None-Match: ""` header on our request which reduces the number of 304s we receive.

So again, I add a check to our bash script that generates the `curl` config do only add `etag-compare` if the `.etag` file is non-empty.

```bash
if [[ -s xml/$FILENAME.etag ]]; then
    echo "etag-compare = $FILENAME.etag" >>$CURL_CONFIG_TMP
fi
echo "etag-save = $FILENAME.etag" >>$CURL_CONFIG_TMP
```

## Grab The Latest `curl` Version with HTTP/3 Support

I choose to use a newer version of `curl` than comes with my Ubuntu distro for two reasons:

1) To get the latest bugfixes and features
2) To get a binary with HTTP/3 support

You will never use HTTP/3 unless you also configure `curl`'s `alt-svc` directive, which allows it to remember the server's `alt-svc` headers which is how clients know that HTTP/3 is available.

I grab the binaries from the [Stunnel Project's "static curl" repository](https://github.com/stunnel/static-curl).

## Don't Call It From cron

I used to run this script in cron on the top of the hour (`0 * * * *`), but this fell foul of the [59/60 minute issue frequently mentioned by Rachel](https://rachelbythebay.com/w/2024/06/12/timing/), so I now run it from a user `systemd` `.service` which is triggered by a `.timer`. `systemd` timers are more flexible than cron so I can use something like the following:

```
# .config/systemd/user/feed_downloader.service
[Service]
Type=oneshot
ExecStart=%h/scripts/feed_downloader.sh

# .config/systemd/user/feed_downloader.timer
[Timer]
OnUnitInactiveSec=1hour
Unit=feed_downloader.service
Persistent=true
```

The magic in there is the `.timer` option `OnUnitInactiveSec=1hour` which means the script will be called 1 hour *after* the last run finished. This means we will always have 60 minutes or greater between requests. The downside to this is that your feeds will be pulled slightly less frequently (for me it works out 22 or 23 runs per 24 hours, rather than 24 using cron).

## Conclusion

That's it!
