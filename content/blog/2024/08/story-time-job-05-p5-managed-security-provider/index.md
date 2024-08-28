+++
title = "Story Time: Job #5: Part 5: Managed Security Provider - Dying Days"
date = "2024-08-28T08:04:03-03:00"
tags = ["storytime", "job05"]
+++

This is the final part of a long series, [click here to see all the parts](/tags/job05/).

{{< custom-toc >}}

## Handing In Your Notice To Get Your Expenses Paid

One day I was in the office when Jay got into an argument with the MD over a train ticket expenses claim.

The backstory was that Jay had been to a tech conference down in London to drum up some business. The company had bought him two train tickets to get him there and back. Jay had missed his return train after hitting delays on the tube and had to buy another ticket, out of pocket, to get himself home.

I heard raised voices in the next-door office, and Jay stormed into our office looking extremely pissed off. He sat down at his computer and started rage-typing. A few minutes later I heard the laser printer fire up, watched Jay go and collect the piece of paper, scribble something on it, then storm back next-door before returning.

A few minutes later the MD stuck his head around the door and said something like "Jay, come on, be reasonable."

It didn't take a rocket scientist to figure out what had happened (and Jay later confirmed - The MD had told him "we're not paying that expense, it was your fault you missed the train, not ours."), that he'd had to hand his notice in to get them to pay.

## Doing My Bit For IPv4 Exhaustion

One thing I was proud of during my time at this company, was managing to do The Right Thing (for the Internet) by giving back our IPv4 `/20` netblock to RIPE.

You would think it would be pretty crazy for a company to give away for free something that, even back in 2009, you could see would be worth quite a lot of money, but at that moment it was a cost-sink for us, and we were in mega cost-saving mode.

Our company was a LIR with RIPE, which incurred us a not-insignificant annual fee of £1000/year or so. I can imagine in the happy times at the company, there were lots of things that they billed customers for that made the grand a year worth it, but by the time I was looking into it, we had precisely two things:

1. Our `/20` Netblock registration
2. One customer who we managed a netblock on behalf of.

The customer who we managed the netblock for was a huge UK company, one that used to give our **MSP** *a lot* of business, but by the time I joined that was the sole remaining service they paid us for. (Not for lack of trying, every one of our Sales people had tried, in vain, to reverse this decline).

We were trying to shed costs, and as we'd already decided to ditch our `/20`, this customer's services were actually making us a *loss*. 

So we decided to discontinue netblock hosting, they moved it to another LIR, and we were left with just our `/20` as the reason for our LIR fees.

So I proposed instead of moving this netblock to another LIR (and paying for the privilege) we should return the unneeded `/20` back to RIPE. The powers that be agreed to this, and I went ahead and transferred it back to RIPE.

I did a `WHOIS` lookup on the old netblock years later and saw that it had been reallocated to a Ukrainian ISP :ukraine: (who still have it today!)

## When A Planned Upgrade Leads To A Unplanned Trip To Hell

Jay had discovered that for most of our customers who had managed firewalls, our contracts with them obligated us to do several things that had been seriously neglected for years. One of those was keeping our customers managed firewalls up to date with the latest software versions.

We started reaching out to these customers, and most were fairly apathetic about the offer to upgrade their firewalls, and some needed outright cajoling to agree to it.

This customer, like most but not all, of our managed firewall customers had some kind of "out of band" modem attached to their firewalls, that allowed us to get delicious remote console access by dialing into their OoB modems.

We used this access infrequently, usually when we got `customer-fw is DOWN` alerts, as it allowed us to narrow down the cause of the fault (if we could dial into their firewall and get console access, it usually pointed to a network outage, if we couldn't dial up to the console, it was probably a power outage).

The console access also allowed us to do *remote* upgrades over this console connection, where we completely wiped the firewall and restored it from an FTP server on the LAN. (The pricier CheckPoint hardware had this feature built into the BIOS).

For these upgrades we needed the customer to give us an FTP server on their LAN, to which we would upload the latest CheckPoint firmware ahead of the upgrade, and was also used to upload a backup of their firewall config (which we would take right before the upgrade started).

I had a planned upgrade for one customer, and I had gone through the plan with Jay, we had everything documented, and had tested on spare hardware in our lab.

I would be starting the upgrade at zero-dark-thirty in the morning, and Jay told me to call him if I hit any issues. So, I went to sleep that night, and set an alarm to wake me up at 3am to do the upgrade.

I went into the spare room, dialled into the work VPN, dialled into the console of the customer, ran a final backup and uploaded the precious backup archive to the FTP server. We would need this backup file as the firewall would be reset to factory defaults during the firmware upgrade.

Things were going smoothly, if not speedily, (it was an older, lower spec model), the new firmware version downloaded from the FTP server fine, and I sat and watched it install the firmware, then it booted into the new version and gave me a root terminal prompt.

I just had to run one command to download and install the config backup, then I could reboot the firewall, send a success email and go back to my nice warm bed...

```shell
customer-fw# upgrade_import ftp://192.168.1.55/export.tgz
Downloading [===========================================] 100%
Extracting export.tgz
Error: Unknown variable Architecture
Failed to import.
```

I had a sinking feeling, I'd never seen this error before, so I called Jay.

> ..ring ring.. ..ring ring..  ..ring ring..  ..ring ring..

> "The number you have dialed is not answering. Please leave a message after the tone..."

Oh fffffffffffuuuuuu....

At this point I was past the point of no return... *so far* past the point of no return.

I searched the error message on our internal ticketing system: *nothing*... Google search... *nothing*...

I sat at my desk in my spare room, tired, so tired, and so screwed. I could hear birds tweeting outside as dawn was breaking.

I was tempted just to shut my work laptop, pretend this was a bad dream, and go back to bed. (I could get another job right?)

But I didn't, I tried to calm myself down and think about what I could do to dig myself out of this hole..

I had never thought much about this `upgrade_import` process, but I thought I would try poking about in the backup tarball. I downloaded it to the firewall and extracted it. It was a mess of files and directories, I had no idea what any of them were, but I ran a `grep Architecture *` to search for the string in the error message, and it showed a match in one of the small files in the root of the extracted backup. I opened that file with `vi` and saw that it seemed to be metadata about the backup archive.

I had another `export` file on my laptop from a different customer, so I extracted this and then opened that metadata file and compared it to the broken one, I saw the values were different, so I tweaked the value on the customer side, repacked the directory into a `.tgz` and re-ran the `upgrade_import`.. and :tada: it worked!

I was flooded with a sense of relief, the import chugged along, there were some `WARNINGs` [^fn1] but it completed and when it rebooted I could see it was up and running.

I sent my email, by this time it was full on daylight outside, and crawled back into bed to try and tried to get some sleep, the adrenaline subsiding slowly..

## Can You Pinpoint The Moment You Knew We Were Doomed?

I foreshadowed it way back in [Part 1](/content/blog/2024/05/story-time-job-05-p1-managed-security-provider/) - *The Quest For A Competent Sales Person*.

The MD fired **The Sales Guy Who Was Actually Good**.

That was it.

Not one of those decision that seemed good at the time, but hindsight told you it was bad... This was a glaringly bad decision at the time, and that glaringly obviously bad decision was still bad when the company inevitably crashed into the ground.

## Suddenly I'm The Only Engineer Left :sassy_woman:

Our team was 4 or 5 people at one point, then the longest serving employee left, then the great student left, and it was just myself, Jay and our junior engineer.

Then they fired our junior engineer, which just left me and Jay.

I could see the writing on the wall, the company was going to go bust fairly soon. I had been working to find another job for months, and I knew the company was doomed, but this was during the 2008/09 financial crisis, and there were no jobs  available (or at least no jobs that I wanted).

Then one day Jay told me he had got a job at one of our competitors, and would be gone at the end of the month.

## Using My Leverage

I had been a pretty timid employee thus far in my career, but I did get my teeth out at this point.

I had a meeting with the MD and I told him if he wanted me to do Jay's job, they would need to give a payrise. I told them I was not asking to be bumped up to Jay's salary, but I could not be expected to stay on my Engineers' salary. The MD fobbed me off, and we left the meeting without an agreement.

A few days later, I got called in for a follow-up meeting with the MD and he told me he had reconsidered their position, and said I could have a reasonable salary bump, and he put the payrise document in front of me to sign.

I signed it, and the MD signed it, the only annoyance was that it was not to kick in for a month and a half. That date would either coincidentally, or perhaps deliberately turn out to be *after* the company went bust.

## Cisco Certified

I wanted to get a CCNA (Cisco Certified Network Associate) certification to try and buff up my CV, and the company agreed to this, as long as I would do the exam preparation off my own back (and my own dime). I spent a couple of months practicing and preparing.

I had a handy test-bench with all the long-in-the-tooth Cisco gear we had pulled out of Telehouse North when we migrated out of that DC. I ended up with two routers and two switches all interconnected so I could experiment with all the switching and routing protocols that would be on the exam. No virtual Cisco devices for me, the real, old and noisy :hear_no_evil: hardware (downstairs on our test bench in the server room) served some purpose.

When I was ready to book the exam, I doubled checked with one of the directors of the company, and he said it was fine, and offered to pay for it on his work credit card. I turned this down as I didn't want there to be any weirdness with the names, addresses etc on the certificate, so I used my own card and put in the expense for the exam.

I passed the CCNA on the first attempt! :tada:

## The End

We all got called into the MD's office one Wednesday afternoon for an unscheduled meeting, the few remaining people left at the company by this point.

They told us that if they didn't find a buyer for the company, that the company would go into liquidation and none of us would be paid our monthly pay checks.. 

This was only *two days* before payday! :rage:

We all walked out that day.

I was a little bit dazed as I walked back to my desk after this news, and sat down at my (locked) PC.

I entered my password to unlock it and there was the terminal prompt blinking at me. It was on one of the new DCs servers I was finishing off configuring. The culmination of over a year of work.

I sat and stared at this prompt and thought:

> "Well, what was the point of all that then?" [^fn2]

I turned off my PC and called my partner to let them know the bad news. She was in the third trimester of her pregnancy with our first child, and this couldn't have come at a worse time. She was upset and panicking.

The company went into liquidation two days later on the Friday. :skull_and_crossbones:

I spent the rest of the week frantically filling in paperwork to apply for money from the government. I scanned in all my contracts, expenses owed, unpaid leave and on-call owed.

I got paid about half of what I was owed pretty quickly (a couple of weeks) from the the government, but realised that I was probably not going to see any more than that (and I didn't). It made me replay the conversation with the director about my Cisco exam expense in my head and wonder..

## The Brief Afterlife

I was called by the Liquidators who were trying to see if they could sell **MSP** as an *Ongoing Concern*, they asked if I'd be willing to keep things ticking over by answering the phones, emails, support tickets and monitoring while they tried to find a buyer. I picked a "day rate" number out of the air, which they agreed to, and for about a week or so I kept the virtual lights on.

I had an meeting / interview with a local company who was sniffing around the corpse of **MSP**. I was honest with them and said that they would need more than just me, but also would need a Pre-Sales Engineer, and a decent Sales person too, as well. Follow up questions about how realistic it would be to try tempt our Pre-Sales Engineer (who I think joined the same company that Jay jumped ship to), and **The Sales Guy Who Was Actually Good** (I said I didn't know if he'd be interested in coming back after how he'd been treated).

At this point I think they realised it was probably not worth it, and nothing came of it.

After that week was up, the Liquidators said they couldn't afford to keep paying me and that it didn't look like anyone would buy the *Ongoing Concern* and it was time to move on to breaking apart what little company assets remained instead.

That was that..

## Conclusion

I didn't plan on going down with the proverbial ship, but that's what happened.

Was it pleasant? No, not at all, but in hindsight I would say it was at least interesting (the *other* kind of interesting).

Did I regret joining the company in the first place? **No!** This was such an amazing learning experience and the start of my proper Linux Systems Administrator career. I learnt to stick up for myself and started to find my voice rather than being a timid and passive employee.

.. and as you can see, I got stories out of it (and believe it or not I've actually left out a few as well!)

Thanks for reading, stay tuned for the next [#storytime](/tags/storytime/) post - where we'll be moving on from this place at last!


[^fn1]: Which I got bollocked for, some users were not imported so some VPN users couldn't connect :woman_shrugging:

    It taught me that the saying *"No Good Deed Goes Unpunished"* is painfully true at times..

[^fn2]: I still think about this to this day.

    I was chatting to someone who worked for a house building company about a newly finished housing estate he worked on. He had confessed to me, visibly looking around to make sure nobody was listening, and lowered his voice, conspiratorially to tell me
    > "Those houses in that estate... I doubt they'll even last 100 years..."

    I laughed so hard at that. Imagine working in an industry where something you made could conceivably last longer than 100 years??
    
    Our tech infrastructure might not live 100 weeks before the next person comes in and decides "This sucks, I'm rebuilding it slightly differently" or even worse, tarnish it with the **legacy** brush..

    
