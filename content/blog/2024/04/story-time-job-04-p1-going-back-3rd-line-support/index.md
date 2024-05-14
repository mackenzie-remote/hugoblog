+++
title = "Story Time: Job #4: Part 1: Going Back! 3rd Line Support"
date = "2024-05-01T20:02:10-03:00"
tags = ["storytime"]
+++

June 2006 – Sept 2007 (15 months)

## Going Back

I went back! To quote the end of [Story Time: My First Tech Job](/blog/2024/04/story-time-first-tech-job/)

> In this role I quickly realised that I wanted to get a promotion out of 1st line support (ie **off the phones**) and into 2nd or 3rd line support. This I was told was not possible, as it was a case of **dead persons shoes**.

I was not happy [at my previous job, doing Server Stuff on a Mega Project](/blog/2024/04/story-time-job-03-p1-big-nhs-project/), as in practice I didn't actually *do* anything except get more stupid.

But, I heard through the grapevine that the person who was working the 3rd Line Desktop Support role was leaving and that they were hiring his replacement..

I had to interview and I was successful. I later found out that the person who had replaced me when I quit had also interviewed for the role. They said it was close, but they gave me the job, in part, because I had more "real world experience". 

> Moral of the story: Companies like to talk about *"Loyalty"* being important, but in practice your loyalty is not rewarded!

## Desktop Management at Scale is Harder Than Server Management at Scale 

I was responsible for around 1000 Windows machines (a mix of laptops and desktops), distributed across about 40 offices dotted around the UK. All the IT was centralised in Halifax, West Yorkshire, where I was based. The networking was dial-up or early ADSL, and the branch offices had very measly WAN links to Halifax.

We used [Microsoft SMS](https://en.wikipedia.org/wiki/Microsoft_Configuration_Manager#History) to remotely manage machines, and had tried to move away from the manual method of distributing software (which was a Helpdesk person using VNC to remotely control the machine, then installing software using point and click).

The idea was you would add the user to a group in AD - say `SMS - Microsoft Office OneNote` and the next time their machine plugged into the LAN, it would automatically download and install the software in the background.

I inherited what was a fairly uneaten sandwich of a project, my predecessors had done the easy stuff, the things that were easy to distribute, or were new software. They didn't do too much thinking about the older in-situ machines that had been in the field for multiple years and had legacy versions on them.

I leaned heavily on `.BAT` files, and Windows Scripting Host scripts, and learned way more than I ever thought I would about `.MSI` files, Regedit, InstallShield and many other cursed software installers.

The thing that made it so hard was that even if you pushed something out, even if it was 99% successful, with 1000 machines you would caused 10 problems... and those 10 problems would probably be oddball users like the *CEO* or an *Angry Road Warrior*.

Even worse you could break someone's laptop with an update, and would not be able to jump on and fix it... as they'd left site. You would "push" a fix, but could never predict when the machine would next pop up on the LAN (if at all) and install it.

I was in the same room as the Helpdesk, so after I'd pushed out an update on SMS, I'd tune into their telephone chatter... sometimes I'd get a sinking feeling as I saw the *incoming call* numbers rising, and hearing keywords spoken that sounded eerily similar to the thing I'd just pushed out. :see_no_evil:

> I tip my hat to those doing 3rd line desktop support - at least if you break a server, it has the decency to stay still (and doesn't result in an angry user calling to yell at you for breaking __their__ computer).

## 99% Redundant Network Connections

The company's IT was all based in an office in a small town on top of a hill, near Halifax. All the company's critical IT services were dependent on the power and network connectivity of this small office. The company had UPS systems and backup diesel generators, so power was taken care of.

Networking was another story. There was a single WAN connection from this small village, down the hill to Halifax. 

The company had paid for a second line to be laid, at great expense, as miles of road had to be dug up to lay a new network cable going the *other* way down the hill. Our short lunch breaks were delayed for months by the road works, temporary traffic lights :vertical_traffic_light: and traffic cones.

But after all that work was completed we finally had resilency again fibre cuts.

One day though, we completely lost all network connectivity.

Both main and backup fibres went dark. We were dead the world. :x:

*This Shouldn't Happen!*

The network team got on the phone to the network provider... and someone on the Helpdesk pointed out the window at the contractors (from the water company), who had just started making a racket with a JCB digger...

The two fibres left our building side-by-side, crossed under the road to the street cabinet then branched off on different paths. Guess where the contractors had managed to dig?

The only 10 meters out of 6 miles of cable that wasn't redundant! Bullseye! :star:

## When Typing Your Password Incorrectly Gives You A Sinking Feeling

The Network Guy was a "bit of a character". He didn't get on at all with the Director of IT, nor the Manager of the Infrastructure Team.

One day they decided to get him fired, and had been gathering evidence against him to get him dismissed from his job. He fought back against the dismissal and prevailed, returning to his job. He was off work for a few weeks while this was grinding on, and when he came back we got the full story.

He said he came into work one day, as usual, as he was usually the first one in the office, he turned on the lights, disabled the alarm, got a coffee and sat down at his computer.

> CTRL+ALT+DEL, password, ENTER

Muscle memory, even if you're half-asleep you can do this on auto-pilot.

:no_entry_sign: *beep* an error message

thinking he's typed the password wrong, he tries again..

> password, ENTER

:no_entry_sign: *beep* again..

This time he checks CAPSLOCK and types it very carefully..

> p a s s w o r d, ENTER

:no_entry_sign: *beep* a third time.. This time he actually reads the error message and his heart sinks..

> **Your account has been disabled. Please contact your systems administrator.**

He said from that moment onwards, anytime he *did* actually just typo his password, he would get a sinking feeling and his heart rate would go up until he'd read the error message and it wasn't history repeating...

## Hurt Feelings...

I was on the Network/Support Team, and I liked my manager. There was a bit of a siloed team mentality in the IT Department but I got friendly with Jay from the Infrastructure Team, who was one of two System Engineers in that team. The *Security* stuff in that role was only a fraction of the responsibilities, but Jay had decided to just... __Only Do Security__ and he seemed to be getting away with it :woman_shrugging:.

I had an interest in *Security* too, and would talk to Jay and cross the divide between our teams. He'd be trying to do whizz-bang security stuff, and I loved reminding him while he was doing this clever security stuff, it was mostly theatre as my team didn't patch our Windows machines, so we had over a thousand unpatched Windows machines teeming with all kinds of nasty stuff. :see_no_evil: (I did get patching started towards the end of my time on the team, I just inherited a mess!)

The company had *Check Point* firewalls that were managed by a **Managed Security Provider**, and Jay got to know them inside-out, and eventually seemed to know them better than they did...

..which led to Jay being poached to head up the Consulting/Support team at **Managed Security Provider**.

Jay knew that the Manager of the Infrastructure Team (who I will call *David*) would **NOT** like this at all, and knew that David's first instinct would be to ditch the **Managed Security Provider** like a jilted lover.

Jay worked out a offer to sweeten the deal and perhaps save a customer (think, Gold Service, "I know your network inside out, this is nothing personal and will work out for both companies", "I can do things out of the bounds of the service contract, to provide continuity while you're looking for my replacement"..)

Alas, David decided on the spot to reject this offer and immediately began ringing around other companies to cut ties with **Managed Security Provider** as fast as he could.

## ...and a Possible Promotion?

Before applying for Jay's old job I weighed up the pros and cons of the move. The saying "be careful what you wish for.." came to mind.

Pros:
* More money
* Get away from Desktop stuff
* Get to do more Server stuff (Linux, Unix, Security, Email, Windows AD, server room management..)

Cons:
* David would be my manager (..and he had a very poor reputation)
* Their On-Call was awful (and Christmas/New Years was coming up)

On balance I thought it was worth a shot, so I applied for Jay's old job, and hoped I could cope with David.

I did hedge my bets though and booked my Christmas/New Years holidays in case they wanted to throw me on the on-call rota over Christmas so soon after joining the team.

..and I got it!
