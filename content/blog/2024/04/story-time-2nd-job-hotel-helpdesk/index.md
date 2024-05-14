+++
title = "Story Time: Job #2: Helpdesk for a Hotel"
date = "2024-04-15T17:25:33-03:00"
tags = ["storytime"]
+++

This covers around September 2004 – March 2005.

## Introduction

This job was a mistake. I knew it was a big mistake after the first week. I only stayed 6 months. Even bad jobs teach you something. This job taught me.. How Not To Do Things.. I guess.

I thought [my last helpdesk job](/blog/2024/04/story-time-first-tech-job/) was bad, this one was much worse.

## How Bad?

It felt like a step down, it was more chaotic, more cynical and their on-call looked like hell on earth (more like a nightshift). They were the Helpdesk for a chain of hotels in the UK. Their **Critical Application** ran some proprietary full-screen MS-DOS looking application that relied upon [Novell Netware](https://en.wikipedia.org/wiki/NetWare) (yes, Novell Netware..).

The **Critical Application** would run it's reconcilliation/batch processes overnight, and invariably at least a handful would fail in some (usually horrible) way, screwing up their database (something like IBM DB2) in the process. The engineer would have to do all kinds of surgery on it, all at like, 4am, all under the gun to get this completed before the night was over and morning rolled around. It was a major disaster if the system was not up and working by the morning (queues of angry customers not able to check-in to their rooms).

I knew this because the on-call engineer would email a report each morning just before they crashed out asleep. I would read these emails in the cold light of the morning and the metadata told the story - I would look at the times of each call, 11pm.. 12am, 1am.. (ooh lucky, 3 hour gap here), 4am, 4:30am.. There was rarely a night where the engineer got more than a couple of consecutive hours of sleep...

No, no, no, nope! No thank you! :no_good_woman:

## Ship Your Hardware To Leeds For No Reason

The company had two IT Offices, one in Leeds, where I worked, and another down in London. Both offices picked up any work for any hotel, we had one telephone number, support email address, ticketing system etc.

The one exception though was a rule that said if hardware had to be returned to IT, it would be shipped to the geographically closest office, in this case it was something similar to the old reliable [North of the Watford Gap](https://en.wikipedia.org/wiki/Watford_Gap_services#Location) expression though. Northern hotel - ship to Leeds, Southern hotel - ship to London.

This created a bit of a perverse incentive for a lazy Helpdesk engineer, say if you were in the London office and got a phone call from a user in a Northern hotel, you could say *"Oh, yeah, this sounds like a hardware problem - have you got a pen handy, let me give you the address to ship it back to us to look at"*... then you have effectively made it Someone in the Leeds Office's Problem now! :smirk:

I signed for a delivery once, it was a huge and very heavy box, with an ancient full-sized Dell desktop PC in it. It had a note inside (good!) that said it was being shipped on the advice of the Helpdesk, so we could upgrade it to Windows XP... It was running Windows 95 (this was 2004/05 remember). It had a Pentium 133 processor and 32MB of RAM. There was no way in hell it was every going to run Windows XP :woman_facepalming:.

So, I asked my boss what to do with it, and he thought for a moment, shrugged and said *"Run a defrag and ship it back to them?"*

So I ran the classic [Windows 95 Defrag](https://www.youtube.com/watch?v=jFbkujZ0OuI), and shipped the thing back. It must've cost more than the value of the PC to ship it up and down the country... :woman_shrugging:

## Taking Over A Botnet (..On Our LAN)

The company had Windows desktops on a LAN, at one point we found a worm spreading internally on our LAN. It spread internally using what I'm guessing was [MS04-011](https://en.wikipedia.org/wiki/Sasser_(computer_worm)), and would infect machines, then end up scanning our internal network for more to infect.

I have no idea how this happened, my memory is fuzzy, but I found that this worm used a channel on a public IRC server for it's Command & Control connection. I'd found a similar thing when I was writing my dissertation at University, accidentally infecting myself with a botnet that was inserted into some cracked/keygen'd software (sorry!) and only being saved from infection by ZoneAlarm personal firewall popping up to ask if I wanted to Allow or Deny the very shady sounding `syscfg32.exe` from connecting to an IRC server.

So we added the botnet's IRC server DNS record to our internal DNS to resolve to a local machine I'd installed an IRC server on. As soon as we added the DNS record we started getting bots joining.. Helpfully they had their IRC nicks set to their Windows hostnames.

```log
*** 16:15:51 Joins: [XP]LDSWRKS1051 (~LDSWRKS1051@172.17.144.24)
*** 16:18:08 Joins: [XP]LDSWRKS0071 (~LDSWRKS0071@172.17.165.179)
```

At this point you could type `.help` to get a list of commands, and use the functions that the botnet owner could, like scanning, packet flooding, running a keylogger, downloading and running an EXE, reporting system information free memory/disk space, (I don't remember if it also had the classic "Eject CD Tray" option or not :laughing: - this was in the script kiddie pre-professionalisation era).

We used it to discover the infected machines, and run the built-in `.uninstall` command.

For the time it was a pretty good remote-access product, it was free and lightweight (the `.exe` was less than 100kB in size), better in some ways than the licensed, commercial Enterprise Software we were forced to use! :expressionless:

## More Like The UN-helpful Desk!

The hotels that the company had were fairly big ones, with hundreds of rooms, but at some point they decided it was a good idea to buy up some smaller boutique hotels and have them as a side-brand. This experiment hadn't worked, and they were in the process of untanging / selling them off.

This impacted us because the small hotels had been integrated into our network, so our PCs, WAN, Telephony, user accounts, and relied upon our Helpdesk. The company had announced that after the small hotels were sold, that we would still continue to be their Helpdesk, but they would have to pay a nominal amount (££) for every ticket they logged with us.

As this date approached, I noticed that we seemed to be giving lower and lower priority to the tickets currently open by the small hotels... (not that we gave **any** tickets a very high priority) and I spoke to one user who had called to chase one of his tickets as the sale deadline approached, and jokingly asked if we were ignoring the tickets until the sale. I laughed and said, I'm sure we're not doing that.

Well, it turned we **were** doing exactly that :woman_shrugging:. I came in the morning of the sale day, and my team leader had __mass-closed every single ticket__ from the small hotels with the same boilerplate message along the lines of

> :tipping_hand_woman: "As you are no longer part of **$HOTEL_CHAIN**, please provide us with payment information to reopen this issue."

## Stealth Interview Mode

I was desperately trying to find another job, and I managed to get an interview for a huge company doing *Server Stuff*. I arranged the interview for lunchtime, the interview location was only 10 minutes walk from my Hotel's office, so that day I came into work extremely overdressed (for me!) in a suit and tie. I knew this would raise eyebrows, and some tricky questions, so I calmly hung up my suit jacket, removed my tie, and put a jumper over my shirt in a different section of the office.

When I went out for lunch I made sure nobody saw me put the suit and tie on, and went to my interview.

I ended up getting the job too, which was a huge relief.

## What Did You Learn From This Job?

One thing that stressed me out on Helpdesk the most was dealing with sales callers, recruitment agencies etc.. any kind of person calling who wasn't an actual user. They would sometimes get our internal Helpdesk number and cold-call directly, or a "helpful" user would transfer them to us. They saw us as a gatekeeper and would try anything to bypass us and get a name, or a number of someone important above us.

I would not have any option but to be firm with them, to argue with them, but there was nothing much I could do. You couldn't hang up on them, because they could just call you straight back! You had to argue and fight with them, and they didn't give up without a fight.

This job had an answer for it though. They had a dedicated extension with a voicemail box that the support manager had recorded a long message on:

> "Thank you for calling, we have already preferred suppliers for recruitment and purchasing, and we are not looking to add new suppliers at this moment. We do not respond to surveys as a matter of policy. If you wish to leave a message, please leave it after the tone. If we are interested, **we** will call **you back**. BEEP"

I smiled everytime I got a sales call from then on, because you could say in very polite voice "Yes, no problem, let me transfer you right away.." :wink: :sparkles:.
