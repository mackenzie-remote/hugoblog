+++
title = "Goodbye Netlify: Self Hosting a Hugo Blog With Caddy"
date = "2024-05-09T19:20:30-03:00"
tags = ["meta","tech",]
+++

## Blogging About My Blog Set-Up (Part 2)

I've previously blogged [about hosting this blog on Netlify](/blog/2024/03/setting-up-a-hugo-static-site-on-netlify/). That was working perfectly fine, I had no issues with Netlify (and still use them for various projects! :heart:) but I'm a sysadmin at heart, and I got the urge to tinker and self-host it, so here we go!

## Build Step - Makefile

I know `make` is either too-old or too-trendy, but I'm using a `Makefile` as the tool to build the site. It's fine I guess. It's in the [root of the git repo](https://github.com/mackenzie-remote/hugoblog/blob/main/Makefile) and the relevant bits are:

```Makefile
HUGO_PARAMS_contactEmail ?= $(error Please set HUGO_PARAMS_contactEmail)

FINDFILES=find public/ -type f \( -name '*.html' -o -name '*.js' -o -name '*.css' -o -name '*.txt' -o -name '*.xml' -o -name '*.svg' \)
.PHONY: compress
compress:
  ${FINDFILES} -exec gzip -v -k -f --best {} \;
  ${FINDFILES} -exec brotli -v -k -f --best {} \;

.PHONY: gitpull
gitpull:
  git pull

.PHONY: hugo
hugo:
  echo using contactEmail - ${HUGO_PARAMS_contactEmail}
  hugo --gc --minify

.PHONY: build
build: gitpull hugo compress
```

To deploy the site we run checkout the git repo on the server, cd into it and `make build` which will:

0. Error if we haven't set `HUGO_PARAMS_contactEmail` - see [Email Me Your Comments](/blog/2024/04/email-me-your-comments/) for the logic behind that.
1. `git pull` to update our git repo (remember, we've probably been invoked by a webhook telling us something has changed it git!)
2. `hugo` build to the `public/` dir.
3. Create `.gz` and `.br` and versions of the compressible static assets alongside the uncompressed versions in `public/`. eg:
```shell
public
├── index.html
├── index.html.br
└── index.html.gz
```

## GitHub Webhook Support

The old workflow for pushing updates to my blog on Netlify was to push to the `main` branch of the GitHub repo, which would trigger a redeploy of the changes. I could change the git-based deployment, now I've ditched Netlify (I could just `rsync -av public/ blog:/var/lib/blog/hugoblog/public/`), but where's the fun in that? Let's try self-host the webhook stuff!

I wanted to use [snare](https://tratt.net/laurie/src/snare/), but the rust binary that I compiled on my initial test server didn't work, and I didn't feel like debugging it, so I looked at alternatives and eventually chose the imaginatively named(!) [webhook](https://github.com/adnanh/webhook).

This runs as a `.service` as the same user as a blog, and I have a (secret) path in Caddy that only I and GitHub know. I could use a shared-secret so the path would not need to be secret, but it felt unnecessary.

> Bad things *could* happen if someone guessed my secret /path, but as I'm not using any of the (potentially malicious) inputs POSTed to the webhook, the worst case scenario would be a DoS vector by making me rebuild the blog as fast as they could POST :woman_shrugging: (and this blog is self-hosted on a single low-spec box, so there are much easier ways to DoS me!)

Caddy snippet:

```caddy
	handle /$webhook_secret/* {
		reverse_proxy http://127.0.0.1:9000
	}
```

Here is the relevant part of the `.service`:

```
ExecStart=/usr/local/bin/webhook -ip 127.0.0.1 -debug -urlprefix $webhook_secret -hooks /etc/webhook.conf
```

and the `webhook.conf` (this was the most fiddly to get right)

```json
[{
    "id": "blogrebuild",
    "execute-command": "/usr/bin/make",
    "pass-arguments-to-command": [
      {
        "source": "string",
        "name": "build"
      }
    ],
    "pass-environment-to-command": [
      {
        "envname": "HUGO_PARAMS_contactEmail",
        "source": "string",
        "name": "$current-mailto-email"
      }
    ],
    "command-working-directory": "/var/lib/blog/hugoblog/",
    "trigger-rule": {
      "and": [
        {
          "match": {
            "type": "value",
            "value": "refs/heads/main",
            "parameter": {
              "source": "payload",
              "name": "ref"
              }}}]}}]
```

There is a one-off setting in the GitHub repository to add the secret webhook URL as above. Now whenever a push is made, webhook will get a POST, and if it's to `main` it will trigger a `make build`.

I tested using `curl`:

```
curl -v https://blog.amen6.com/$webhook_secret/blogrebuild -H "Content-Type: application/json" -X POST -d '{"ref": "refs/heads/main"}'
```

and I can follow the output from `webhook` using `journalctl -fu webhook` (which is why I added `-debug` in the `ExecStart`)

## Caddy

Last but not least.. something to serve the damn website!

> I've chosen [Caddy](https://caddyserver.com/) mainly as a way to learn a bit more about it. My go-to web server has been the venerable [Nginx](https://en.wikipedia.org/wiki/Nginx#History) for the past decade, but it seems to be getting long in the tooth, and it's now owned by **F5, Inc** (which gives me flashbacks to past jobs where "put an F5-loadbalancer in front of it" was the knee-jerk answer to any problem..), **and** one of it's core developers has [fired shots at the corporate owners](https://www.phoronix.com/news/Nginx-Forked-To-Freenginx) of Nginx and forked the project.

### Performance

So.. the website is pretty performant already, being a static site with an extremely minimal theme, but I've made sure to optimise it as best I can. Here is the base `Caddyfile`.

```Caddy
https://blog.amen6.com {
	header {
		Strict-Transport-Security max-age=31536000;
	}
	@cachedFiles {
		path *.css *.js *.woff2 *.png *.ico *.jpg *.svg
	}
	header @cachedFiles Cache-Control "public, max-age=31536000, immutable"

	tls {
		key_type p256
		issuer acme {
			dir https://acme-v02.api.letsencrypt.org/directory
			disable_http_challenge
			preferred_chains smallest
		}
	}
	handle {
		root * /var/lib/blog/hugoblog/public
		file_server {
			precompressed br gzip
		}
	}
}
```

1. The directory `/var/lib/blog/hugoblog/` contains a `git clone` of my GitHub repo, but only the `public/` subdir is served to the internet.
2. `tls` block uses the smallest SSL certificate type (ecdsa/p256) and shortest chain that Let's Encrypt offer. These mean the handshake is smaller, therefore quicker, at the cost of not supporting non-modern browsers.
3. Set 1-year `Cache-Control` headers on static assets.
4. Serve `precompressed br gzip` copies of my compressible static assets to save CPU cycles / time.

Et Voila! You are reading this website courtesy of the above. It's not got a CDN, or a WAF, it's a single box. (Mastodon please don't give me a [hug of death](https://news.itsfoss.com/mastodon-link-problem/)!)
