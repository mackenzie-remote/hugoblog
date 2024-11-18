+++
title = "Story Time: Job #3 Part 1: Big NHS Project: I Escaped The Helpdesk!"
date = "2024-04-20"
tags = ["storytime"]
+++

This covers March 2005 – May 2006.

{{< custom-toc >}}

**Good news**: I managed to [Escape The Damn Helpdesk](/blog/2024/04/story-time-2nd-job-hotel-helpdesk/)!

**Bad news**: It looked impressive on paper, but I definitely lost skills rather than gained them.

I finally got my break, and chance to escape the shackles of the Helpdesk headset. This job was as a Windows Server Admin for a [Huge Mega NHS Project](https://en.wikipedia.org/wiki/NHS_Connecting_for_Health#Impact_on_IT_providers), working for a Huge Mega Corporation!

## The Hidden Interview Within The Interview

This project went from zero to over a thousand people basically overnight. They were hiring, hiring, hiring, interviewing, interviewing, interviewing.

I later got told by someone who'd done a **lot** of interviews (but not mine.. thankfully?) and had made a game to make the task more interesting.

Typically candidates would wait in reception with a temporary swipe card. The interviewer would go upstairs to reception, then walk them downstairs and help them through the revolving man-trap door (test #1), stop to make a hot drink from the fancy coffee machine (test #2) and then have the real interview in a meeting room (not a test?!).

The revolving man-trap door was there to stop tailgating, I've only ever seen those type of doors at __Serious Data Centers__, and it was temperamental. I would get an angry beep from it at least a couple of times a day when I worked there. Very easy to mess up by:-

1. You stepped in but it didn't read your card.
2. It read your card but didn't notice you standing in it.
3. You moved too fast.
4. You moved too slow.
5. The person on the *opposite side* to you messed it up, but you both sufferred angry beeps.
6. You jumped inside the same (small) segment as the person ahead of you.

I have to say I'd been dinged by #1 through #5.. but never #6. Apparently one interview candidate did this, and had to awkwardly shuffle behind their interviewer.. and did *NOT* get the job. :flushed:

## Shift Work

This role was on a 24/7 shift team, 4 days on (2x12 hour days, 2x12 hour nights), 4 days off. This was the first (and last) shift role I'd ever worked.

It wasn't *that* bad, as long as you could arrange your life around your shifts. As your week was 8 days long, you would slowly phase in and out of the regular 7-day week that the rest of the universe used. Some days you get weekends off, some days you're working the weekend.

I thought I would give it a go, the basic salary wasn't much more than my basic salary at my last Helpdesk job, but doing the shift work gave you a **20%** on-call bonus :moneybag:, which made the difference.

It meant working "holidays" and I worked New Year's Eve 2006 ... celebrating the New Year watching the fireworks go off from behind the floor-to-ceiling glass windows in our dark office. I thought to myself "this will be the last NYE I work" (and it has been.)

## 24/7 Ops

There were 4 shift teams, and we sat in the same part of the office and hot-desked. It was a Microsoft shop, and for some reason there was no internal domain in the office, so every person had their own desktop (with it's own local user account). This meant that our shift desks had a pile of at least *FOUR* desktop PCs stacked up. Most desks had *FIVE* as there was a shared monitoring-only PC. No KVM either, just good old fashioned scrambling under the desk trying to jam the keyboard / mouse / video cable into the "right" PC.

You main desktop PC had the left monitor, and your monitoring PC had the right monitor. This arrangement worked fine.

## Blinkenlights

The managers decided though that they needed bigger and bigger screens, mainly I think so they could look important when VIPs visited our office. They first got two beefy desktops and each connected to four flatscreen monitors. Nobody on the Ops teams actually used them, so if there was a power cut or a Windows Update that rebooted those PCs, there would then be 8 screens of a Windows CTRL+ALT+DEL logon prompts.

One time our manager got mad that we weren't using them, and told us to put "something" on there, we did have some reference material (spreadsheets), but the PCs didn't have Microsoft Office installed, and nobody knew the Administrator password, so I had the idea to take screenshots of the spreadsheets then copy over the JPGs and up open the JPGs. The manager was then happy, but was confused why he couldn't "drill down" on them :joy:

But eight screens were not enough.. I came in one day to find *three* new overhead projectors had been installed, displaying a cinema-sized projection of coloured dots. Nobody except the managers looked at them, though. Sometimes I would see people walking past the projectors, and notice something :red_circle:.. then scanning over to us to see if we'd spotted it :eyes:.

After a couple of weeks the projector outputs started to become blotchy and blurred, it turns out they had bought consumer-grade projectors that were not designed to be run `24/7` and had started dying...

Management replaced them with even more expensive ones :woman_shrugging:

## What Were You Monitoring, Tho?

Two different Awful Applications, one for GP Surgeries, and one for Hospitals.

The GP Surgery software ran on three servers, Citrix Front-End, Middleware and Database. The software we surmised was originally designed to be run on a Windows Desktop PC, under someone's desk. Now it was running 24/7 in a Datacentre on a Real Server.

Each application we monitored had strict SLAs (service level agreements) and we had a monitoring tool that would simulate an end-to-end GUI logon, and then click through various menus, before logging out again. The SLAs were down to each action (eg, opening a patient's info, 500ms - doing a search against the patient database, 750ms).

It then displayed a different coloured dot to summarise: :green_circle: :yellow_circle: :red_circle: :white_circle:.

The worst one was.... the grey circle. Red meant "worked, but slow", grey meant "didn't work".

We found that each of the GP Surgery instances' *Middleware* box would crap out after about 10 days of uptime. The software was opaque to us, but in Task Manager we could determine it had [Visual Basic 5 and 6](https://en.wikipedia.org/wiki/Visual_Basic_(classic)#History) DLLs loaded (`MSCOMCTL.OCX` and `COMCTL32.OCX`..).

We had surmised that the issue was a file handle leak in the software, once Windows got close to the system-wide file handle limit, baaaad things would start to happen. System tasks would fail that should never fail, files couldn't be opened. We learned that as soon as you started to see a "wobble" and that the box had been up for close to 10 days, you should reboot it immediately, and your reward for fixing production was... having to file a *Retrospective Change Control* asking permission for doing the thing you had just done.

We asked our change management team if we could schedule reboots for all of the Middleware boxes until the provider fixed the bug, maybe every 7 days to be safe. We were denied the request, as they said it would increase the downtime minutes, and they preferred we waited until it was *just about* to die, before rebooting it. (Ignoring that if we scheduled it, we could do it when the GPs were not using the system... the random 10 day crap-out could occur during the GPs working day..:woman_shrugging:)

## That Time They Accidentally Bricked Everything

There were a couple of thousand servers, and most were managed using a configuration management tool that would set all the required configuration.

As is often the case, configuration management is a double-edged sword, if you make a manual change, the software will undo it. You should add your manual changes to configuration management... or cheat and disable the "enforcement" mode. That's the state that production was in, and it seems it had been in that state for a long time, as one routine change got rolled out that didn't have the "don't enforce" option set on it.

This change rolled out... and started to enforce changes after a year of non-enforcement and what must've been lots of manual deployents.. This bricked production completely.

The first thing that alerted me to the fact that my usually sleepy Sunday morning shift was going to be slightly different than usual was when I drove up to the underground car park ramp... and the car park was full (.. on a Sunday?!)

When I got into the office, it was full of the day-shift folks, senior people, management, and everyone was looking panicked and tired. People I usually only saw in sharp suits were in their scruffy clothes, looking like they'd been roused out of bed in the middle of the night (which they had!)

I got the story from the other shift who were on their way out. The person rolling out The Change had escalated and it had kept escalating as more and more senior people got called in to help.

They couldn't roll it back because the original settings weren't in source control. They had to rely upon the senior people's memory to try fix some of the changes... and this was stuff like the *logon domain*, so nobody could even log onto a single server until the emergency break-glass credentials were found and the original logon domain was reconfigured.

..It was a quiet shift for us at least :joy:

## Night Shifts: The Art Of Killing Time

The Night Shift (7pm - 7am) was loong. It was looong and boooring. You would have nothing to do until about 2am, aside from monitoring. It became an art of killing time. I would save up my internet reading all week, otherwise I'd "run out of internet" over the night shifts. I had a coworker who bought the most expensive Gaming Laptop money could buy, so he could play World of Warcraft in the (many) quiet hours.

It was spooky too. The office had motion-sensor controlled lights, and it seated a few hundred people during the working day, but during the night shift there would only be half a dozen of us at most. Our desks were at the far end of the office, so unless someone had stretched their legs recently, you were sat in a small island of light in a bigger sea of darkness.

We had nothing to do until 2am most nights. Part of our job was to roll out *Change Controls*, and if they were meant to be run Out of Hours, they almost always picked 2am as the time.

## Okay, I've waited 7 Hours..

Time to use a small part of our brains...

We'd print the Change Control documents out ahead of time, staple them, skim through them and then put them to one side. When it was "go time", we'd work through them. This was a Windows shop, so it was things like:-

1. Remote Desktop to `tppr1cxmf01a061`
2. Stop service `iSoft Something`
3. Open the file `C:\Program Files\iSoft\Config\app.ini`
4. Change something
5. Delete the file `thisfile.dat`
6. Reboot the server
7. Do the same on servers 2, 3, and 4...

You would sometimes hit an error, or discover a discrepancy in the Change Control, and if you couldn't reasonably guess a way to fix it, would jump to the Change Owner section - to call the person who wrote the change to ask what to do.

Once, I had hit a dead-end on a Change Control I was rolling out, spoke to my Team Leader, and we realised we would have to call the Change Owner to figure out what to do. I dialled the phone number, waited... and heard a desk phone on the other side of the office start ringing... I let it ring for a bit... no answer... I hung up.. and the desk phone on the other side of the office stopped ringing too.. :woman_facepalming:

Your next step would be to go to the *Rollback* plan. The problem was that the *Rollout* steps were pretty slap-dash, the *Rollback* steps got even less attention. There were three outcomes:-

1. It would say *Do The Steps in the "Rollout Plan" but **In Reverse***...
* How do I **un-Reboot** this server? :thinking:
* How do I **un-Delete** this thing you didn't ask me to backup? :thinking:

2. It would be a Rollback Plan from an unrelated Change Control, probably they'd used their last Change Control as a template, had updated most of it, but neglected to update the Rollback Plan, thus it was nonsense.
3. An actual working Rollback Plan (Rare).

:woman_facepalming:

## Continued

Here in [Part 2](/blog/2024/04/story-time-job-03-p2-big-nhs-project/)
