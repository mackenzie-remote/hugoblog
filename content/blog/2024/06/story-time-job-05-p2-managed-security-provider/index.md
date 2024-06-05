+++
title = "Story Time: Job #5: Part 2: Managed Security Provider - Email Is On Fire"
date = "2024-06-05T12:59:08-03:00"
tags = ["storytime"]
+++

March 2008 – Oct 2009

## Introduction

As I said in the [last part](/blog/2024/05/story-time-job-05-p1-managed-security-provider/):

> It appeared to have been frozen in time. Almost all the Unix servers were running ancient versions of *Solaris* (versions 8 or 9 - 2000 or 2002 vintage - and this was 2008) on anemic SPARC hardware. I don't think anybody dared touch it, as nobody understood how it worked.

Our email set-up was the biggest fire we had to put out.

## Email Is On Fire

Our `mx` servers would regularly die whenever they got a spike of incoming spam. They were running a configuration of `sendmail` that would fork a new sendmail process for each incoming SMTP connection they received, and each process used up some memory, and they were running close to the memory limit on a *good day*.

The spikes would spawn more sendmail processes than the paltry memory on the box had, so it would use swap memory, which was glacially slow, which would slow down the box, and the load would increase, and eventually the box would become completely unresponsive and need an unhappy operator to connect to the console and try and restart the services (*excruciatingly slowly*... a load average in triple or quadruple figures wasn't uncommon).

It didn't matter that we had two `mx` boxes, as if one box became unresponsive, the load would shift to the one remaining responsive box, which would then also fall into a death spiral.

We generally only found out that both `mx` boxes were dead when we didn't get any monitoring alerts for a while (alerts were routed via the `mx` servers... which wouldn't alert us if they were on fire..) or a colleague wondered why that hadn't received an email they were expecting.

Even more amusingly, we would sometimes only find out that the `mx` boxes had an issue, but recovered on their own, when we would get a glut of delayed **ALERT** messages. :laughing:

## Gnarliest Mail Outage

One day though we had an outage and our usual fixes did nothing to restore service.. As soon as we rebooted the `mx` boxes, they would death spiral again..

I managed to get a glimpse of the mail logs on one of the unresponsive boxes and saw a huge amount of emails for `@travelcustomer.domain`.

This was another weird thing about our email set-up. It couldn't cope with *just our* email volume, but for some reason we had a paying customer that relied on this tire fire too, who paid us for a "[Backup MX](https://en.wikipedia.org/wiki/MX_record#%22Backup%22_MX)" service.

Our customer's MX records were set-up like this:

```log
10 mail.travelcustomer.domain # primary MX - where email goes normally
99 backupmx.msp.domain        # backup MX - us
```

So the theory was that as the customer's main MX would almost always be up, we would get next to no emails for them. 

But, in practice, we would get a constant stream of spam emails for `@travelcustomer.domain`, that we would then have to forward to `mail.travelcustomer.domain`, which was probably online the whole time... just that spammers exploited dummies like us who still thought that *backup MXes* was a good idea. They rightly assumed that the *backup MX* probably had less anti-spam defenses than the *primary MX* (again, correct!)

I checked the MX records for `travelcustomer.domain` during this outage and they had changed:

```log
10 abcef.messagelabs.com.travelcustomer.domain # messed up primary
99 backupmx.msp.domain                         # backup MX - us
```

They were evidently trying to move their incoming MX to Messagelabs, but had actually messed up the DNS change, and their new *primary* MX didn't resolve... so our *backup MX* was now the only working MX... So we had been receiving every *legit* and every *spam* email for them (many times our usual load), and then to add salt to the wound, as the *primary MX* was still down, we couldn't even deliver their emails and they filled up our mail queue.

I got in touch with the customer and asked them to fix their MX records, which they said they would, but I had no idea how I was going to resurect our mx servers. The DNS change had a long TTL so even after they fixed the DNS change, it was still going to be cached for a while, and even if we stemmed the bleeding the MXes had so many emails stuck in the queue that it would never clear down.

Sendmail stores it's emails in a spool folder - so I stopped Sendmail and tried to look at the files on disk:

```bash
$ cd /var/spool/mail
$ ls
Killed
```

Oh no, I couldn't even *list* the mails without running out of memory.. :see_no_evil:

In the end we tried everything we could, but every minute we were futzing around, was another minute we were completely dead for incoming/outgoing emails, and we had no real route out of this mess.

So we got the call from management to.. **NUKE EVERYTHING IN THE MAIL QUEUE**. We gave the Travel Customer a call to let them know, they asked if we could.. y'know... go through those emails and just delete the spam and forward the rest to them? We told them we couldn't even get into the queue to count the emails in there, let alone manually classify them one-by-one.

So, we nuked every single email in the queue, and restarted the boxes, and the Priority 1 problem of email became a Priority 0.

## The Not Fit For Purpose Email Set-Up

This was the email infrastructure we had to support ~10 users:

```
┌─────┐            ┌─────┐                                      
│ mx1 │            │ mx2 │        # Solaris 8 - Running Sendmail
└─┬───┘            └──┬──┘                                      
  │    ┌──────────┐   │                                         
  └────► antispam ◄───┘           # Commercial Windows Anti-Spam
       └─────┬────┘                                             
             │                                                  
       ┌─────▼─────┐                                            
       │ms exchange│              # Microsoft Exchange 2003     
       └───────────┘                                            
```

Downsides of this set-up:
* 4 servers to support 10 users seems a bit excessive, especially as it required 4 commercial licences
    * 2x Microsoft Windows
    * 1x Microsoft Exchange
    * 1x Commercial Anti-Spam subscription
* Nobody wanted to learn Exchange. (and it would need upgrading at some point..)
* The MX servers were running on anemic, ancient, underpowered Solaris boxes.
* The MX servers did not have a valid list of email addresses, so `invalid@ourdomain` emails would be accepted on the `mx`, relayed through `antispam` to `ms exchange`, get a `550 Invalid user`, which would add even more stress to the already stressed `mx` boxes that now had a jammed full queue of undeliverable `Non-Delivery Reports` clogging their outgoing email queue for the next 5 days.
* The Anti-Spam set-up was terrible.

## Idea #1 - How About We Pay Google $500 a Year To Host Our Email?

It looked like it would take a lot of effort to improve our current email set-up, and I made the suggestion that we pay Google to host it for us. This idea was rejected by the *Managing Director*, to paraphrase:

> "It's $500 per year to pay Google to host our email, but it's free for us to get you to do it."

So that was that.

## Idea #2 - How About We Pay One Full-Time Employee To Have A Go At This Whole Email Thing Instead?

So, I got the task of understanding and improving our email set-up, on a shoestring budget. I didn't know very much at all about email, and certainly had no idea about the reasoning or idea behind our current email set-up, but my first thought was to port our existing Sendmail config to a more modern OS running a suitably specced machine would be a safe first step.

I expensed the O'Reilly Sendmail book, and when it arrived in the office I was shocked at the size of it. It was 1300 pages and over *two inches thick*. My first reaction was:

> NOPE! NOPE! NOPE!

I read enough of to find out that Sendmail had two different types of configuration, the old, deprecated method, and the *new method*. If you used the *new method* it would be a cleaner, more readable config, that would generate the *old method* files, that you definitely did not touch!

I checked our `mx1` server and found, of course, we used the *old method*... better yet at the top of the file was:

```sendmail
# COPYRIGHT (C) 1996 [COMPANY FOUNDER'S NAME]
```

Followed by the utter gibberish config that ancient Sendmail used, that made [perl golf](https://thospel.home.xs4all.nl/golf/midigolf1.html) code look readable:

```
# etherhost.uucp is treated as etherhost.$m for now.
# This allows them to be addressed from uucp as foo!sun!etherhost!user.
R$*<@$%y.uucp>$*        $#ether $@$2 $:$1<@$2>$3      user@etherhost.uucp

# Explicitly specified names in our domain -- that we've never heard of
R$*<@$*.LOCAL>$*        $#error $:Never heard of host $2 in domain $m

# Clean up addresses for external use -- kills LOCAL, route-addr ,=>: 
R$*                     $:$>9 $1               Then continue...

# resolve UUCP-style names
R<@$-.uucp>:$+          $#uucp  $@$1 $:$2      @host.uucp:...
R$+<@$-.uucp>           $#uucp  $@$2 $:$1      user@host.uucp

# Pass other valid names up the ladder to our forwarder
#R$*<@$*.$=T>$*         $#$M    $@$R $:$1<@$2.$3>$4    user@domain.known

# Replace following with above to only forward "known" top-level domains
R$*<@$*.$+>$*           $#$M    $@$R $:$1<@$2.$3>$4    user@any.domain
```

I quietly put the Sendmail book on the office bookshelf and expensed the O'Reilly Postfix book, and this clocked in at a very lightweight 300 pages.

## OpenBSD (and me) to the Rescue!

I have no memory of how I found a spare, functional x86 server, but I managed to find one. I was a big fan of [OpenBSD](https://www.openbsd.org), at that time I was using it for my home servers, so I set-up OpenBSD and [spamd](https://www.openbsd.org/spamd/) in Greylisting mode in front of the Sendmail boxes. This cut down on 99% of the spam connection, and stemmed the bleeding.

Now I had breathing room I could follow what emails we had coming in, and realised that the hand-written 1996-vintage Sendmail config was pretty much just "accept anything @msp.domain and forward it to $commercial-anti-spam-box". So, I configured [Postfix](https://www.postfix.org/) on the same box (you would have to get past `spamd`'s greylisting first before connecting to `Postfix`), and even added a script to sync the valid email addresses from Exchange.

I found that we had a decade-plus of ex-employees email addresses getting spam, I created an alias on my personal work email address for each of the most popular addresses, and anything that reached me was not-quite-spam, likely companies and services that the ex-employee had signed up to. So I would check those emails and unsubscribe from them. After a while that inbox dwindled to zero, and I added those email addresses to the `spamtrap` list - if you tried to email a `spamtrap` email address, your IP would be added to the `blacklist`.

We then added monitoring so every minute we sent a test email in the MX and made sure it appeared in the test Exchange mailbox, so we could tell end-to-end that every box in the set-up was working.

The :fire:s were finally out :upside_down_face:

After all this effort, one of our employees (who owned the most-spammed email address in the company) came over to our side of the office one morning and asked me *"Is email down?"*... I looked at the monitoring dashboard, and all looked happy so I replied *"No, looks healthy, why do you ask?"*... *"Well, I've not received any spam this morning and that usually means that email is down."*.. :laughing:

## Conclusion

I spent a huge portion of my day for over a year just reading through the email logs, looking for false positives, false negatives, weaking this, adjusting that...

I learned so much, and it was amazing for my personal and professional knowledge. My next 6 years of jobs touched email in some way - eventually that knowledge became less relevant for work (everyone eventually moved to Google/Microsoft)

The knowledge made me make the crazy decision back in 2012 to register my own domain and run my own email server... and I still do - 12 years and counting!

Thank you, short-sighted *Managing Director*! :tada:
