+++
title = "Hugo: Enabling Full Text RSS Feed"
date = "2024-03-31T19:04:08-03:00"
tags = ["tech"]
+++

Blogs about blogging software... such a cliché I know!

For some reason Hugo defaults to outputting just the summary in the RSS feed, and annoyingly there isn't a built-in way to enable it.

Here is how I did it:

1. Downloaded the [upstream rss.xml](https://raw.githubusercontent.com/gohugoio/hugo/master/tpl/tplimpl/embedded/templates/_default/rss.xml) to `layouts/_default` path in this Hugo repository.
2. Modified it to change `.Summary` with `.Content` in the `<item>` loop.

```diff
-    <description>{{ .Summary | transform.XMLEscape | safeHTML }}</description>
+    <description>{{ .Content | transform.XMLEscape | safeHTML }}</description>
```

3. Build, push etc.
