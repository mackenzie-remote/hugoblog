+++
title = "Email Me Your Comments"
date = "2024-04-01"
tags = ["tech", "meta"]
+++

I have added a (semi)-random incoming `mailto:` link at the bottom of every post. This is a very basic way to allow readers to contact me. I've shyed away from putting any of my email addresses online due to spambots harvesting them.

I host my own email and have managed to do so for over ten years without having to resort to any content-based spam filtering (eg, SpamAssassin, rspamd), and this has only worked due to me handing out tagged email addresses to all and sundry. I have a denylist of previously valid email addresses that have started receiving spam, and I will be addding any of the blog-reply emails to the denylist as needed.

This method was inspired by [a blog post by Kev Quirk](https://kevquirk.com/ban-the-spam) about how he handles this.

I've not *quite* got this working as I want, but it's close enough. This method is generic enough that it should work if I move to another static site hosting provider.

0. Pregenerate a list of semi-random email address in the form `blog-reply-abcdef@invalid` and allowlist those on my mail server.
1. Add a new site param to `hugo.toml` called `contactEmail` (defaults to blank).
2. Copy the existing theme from `layouts/_default/single.html` and append this to the end:

```golang
{{ $subjectEscaped := replace .Title " " "-" | urlquery }}
I love getting emails - please email me about this post <a href="mailto:{{ .Site.Params.contactEmail }}?subject=Reply%20to:%20{{ $subjectEscaped }}">here</a>
```

3. Set a valid email address from step 0 in the environment variable `HUGO_PARAMS_contactEmail` (this is configured on Netlify)
4. Deploy the site.

This means I can have an email address for incoming comments, and when I start getting spam emails to it, I can disable that address and rotate in a new one.

I have a permanent email address that I will use to reply back to any of the incoming emails, so even when I disable one of the public ones people who have got a reply from me can still keep emailing me.

If you want to get in touch, see the link at the bottom of this post!
