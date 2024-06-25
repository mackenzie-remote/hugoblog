+++
title = "Story Time: Job #0: University and Placement Year"
date = "2024-04-09T20:58:15-03:00"
tags = ["storytime"]
+++

{{< custom-toc >}}

## Introduction

I have been working in tech for over twenty years :older_man:, and the last 4 have been fully remote. I prefer a lot of things about WFH vs In-Office, but one thing that I've realised I'm missing from `#officelife` is that I can no longer ~~bore~~ recount lessons, tell amusing anecdotes, cry into my beer over disasters etc etc.

So this is the first, of hopefully many, stories!

This covers ~1999 to mid-2003.

## Backstory

I went to University on a Computer Networking degree for a planned 4 years, three in University, one "in industry" (aka a placement year, I guess an "internship" might be a way to describe it too). The placement year was optional and I was promised a placement in :fr: France (I studied French at College and really wanted to spend some time in France). As the end of my second year approached I had not heard anything about this French placement, and eventually at the 11th hour I was told that it wasn't happening. This was annoying to say the least!

Plan B? Plan B was either skip the (optional) placement year and go straight into my 3rd and final year, or see what other scraps I could pick up... The University encouraged me to go to some placement interviews, none of them sounded useful to me but I went along (they said it would be good interview practice if nothing else). I must've done something right as I landed a placement.

## My Placement Year (2001/02)

I ended up working for a consulting company that had a big contract working on-site for the local water company. The consulting company would recruit a bunch of students from the _Engineering School_ of my University, but they also hired me, even though I was in the _Computing and Mathematics School_ :woman_shrugging:.

It was based in Washington... no, not that one, this one [Washington, Tyne & Wear](https://en.wikipedia.org/wiki/Washington,_Tyne_and_Wear).

I didn't understand why I got offered the job, as I knew nothing about the Engineering background they presumably needed. My hiring manager confessed to me that as they beholden to the water company's IT Helpdesk, which they found weren't very helpful, they found it was easier to hire a couple of students from the Computing school and make them their own part-time Shadow Helpdesk... :woman_facepalming:

I didn't learn a great deal that was relevant to my degree, I mainly churned out reports, crunching a bit of data, but following a template/script.. I did a little bit of coding, in the loosest, Shadow IT sense of the word, think VBScript, Excel macros etc (yuck!). But one thing I did learn from being on the "other side of the fence" was a real appreciation for my future-customers - that-is the unlucky **End Users**..

The computers we worked on were old, slow running Windows NT 4.0 (which was not EOL.. but not far off), semi-locked down and constantly low on memory. I didn't even have Internet Access (and this was very pre-smartphones, Nokia 3210s were still current!). We couldn't change our Internet Explorer Proxy settings, but I could at least view them, so I compared my proxy settings to a colleague's computer who did have access.

Their proxy hostname was set to something like `nwlprx01.internal`, mine was set to `notallowed`. I thought about how to get around this and came up with a sneaky idea, the `notallowed` hostname did not resolve.. but the legit proxy did, and I could get it's IP address (`ping nwlprx01.internal`).. I then created a `HOSTS` file entry (which I had permission to modify for some reason) and added a line pointing `notallowed` at the legit proxy's IP address ... and it worked! :grin::partying_face:

Even then, the internet access was provided by a wet noodle, and *Internet Explorer Ancient Edition* on 64MB of RAM meant I could barely read anything, but I do remember seeing my first image of 9/11 (a tiny thumbnail of the twin towers on fire) this way on the BBC News website, before seeing the full horrorshow video footage on TV news when I got home from work that day.

It was very dull but I learnt how to survive in an office at least, with zero pressure. The first time I saw [The Office UK](https://en.wikipedia.org/wiki/The_Office_(British_TV_series)) on TV it really nailed the terminal dullness of office life. Think the long shots of a photocopier chugging along, or people staring into space at their desks.. :sleeping::zzz:

## Final Year Of University (2002/03)

The final year of University was a bit strange. My group of friends from my first year had pretty much all graduated. I found a room in a student house (of 6 - 4 strangers and one acquaintance who I came to loathe after living with them). The house was a mad one, nobody cleaned, paid utility bills or slept. (Well, I tried to). It was chaotic and even then I could tell it was a *Type II* experience. I would get funny stories from it, but would not enjoying living through it.

Doing a placement year I think helped me get a good result for my University degree though. The majority of the people I knew from the 1st and 2nd year had already graduated when I returned for my final year. So the people in my final year who I did know, the minority of us, were either those people like me who did a year in industry, and those who had failed and resat the 1st or 2nd year. I ended up teaming up with two other placement students, and we seemed to be the smarter and more "switched on" people on the course. Our group work exercises got great marks. I think having an extra year to mature helped. Also working for a year gave me an appreciation student life.

I also picked an interesting topic for my Final Dissertation, which was worth a big chunk of marks towards my final result. I chose the topic of Denial of Service Attacks. I was lucky that this era of the internet brought many fun and live hacks, worms and DDoS attacks. So I had plenty to write about. My tutors told me that the people reviewing dissertations liked pictures, so I inserted plenty of screenshots. Thinking old hacking tools with :skull: and crossbones!

I had learned how to put in the effort at the right time, and ended up getting a great result, one of only three people in my class who got the highest mark.
