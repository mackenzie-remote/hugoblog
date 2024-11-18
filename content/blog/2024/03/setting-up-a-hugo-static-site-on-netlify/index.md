+++
title = "Hugo: Setting Up A Hugo Static Site on Netlify"
date = "2024-03-30"
tags = ["tech", "meta"]
+++

## Introduction

I followed [this guide on Hugo's website](https://gohugo.io/hosting-and-deployment/hosting-on-netlify/) and it was pretty painless.

I already had a GitHub Repository with my hugo project in it, and I already had a [Netlify](https://www.netlify.com/) account, so I just had to fill in the gaps.

## Issue with Hugo Version

The only issue I hit was my deploys were failing with a strange error:

```shell
build.command from netlify.toml                               
────────────────────────────────────────────────────────────────
​
$ hugo --gc --minify
Error: Unable to locate config file or config directory. Perhaps you need to create a new site.
       Run `hugo help new` for details.
Total in 0 ms
```

After some searching online for the error message I got it working by renaming `hugo.toml` to `config.toml`. After it deployed I wasn't very happy with the solution and kept reading, and eventually spotted in the Netlify deploy logs the problem, they were ignoring my `HUGO_VERSION = 0.124.1` in the `netlify.toml` file and defaulting to a much older version of Hugo (0.88 something), which must expect a different filename.

I then renamed the file back to `hugo.toml` and set the `HUGO_VERSION = 0.124.1` in the WebUI Environment, and this fixed it.

## Final Set-up

Then it was simply a case of picking a FQDN (in my case `blog.amen6.com`) and creating a DNS CNAME to point at my Netlify subdomain (`blog-amen6-com.netlify.app`) and Netlify handled the rest.

When I push changes to the `main` branch of my GitHub repository, Netlify will autodeploy the changes. This takes about a minute end-to-end.

Now I just have to write some words into this editor :)
