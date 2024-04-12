+++
title = "Internal Network Numbering: the Good the Bad and the Ugly"
date = "2024-04-11T08:13:51-03:00"
tags = ["tech"]
+++

## Introduction

This is kind of a `#storytime` post, but also not. It's a retrospective of the Good, the Bad, and the Ugly choices I've seen over my twenty years of work, in regards to how companies choose to use and abuse their internal network numbering.

It should be fairly simple, but it's one of those choices that can come back to bite you if you choose wrong (even if you *do* follow [RFC 1918](https://datatracker.ietf.org/doc/html/rfc1918#section-3)).

```
3. Private Address Space

   The Internet Assigned Numbers Authority (IANA) has reserved the
   following three blocks of the IP address space for private internets:

     10.0.0.0        -   10.255.255.255  (10/8 prefix)
     172.16.0.0      -   172.31.255.255  (172.16/12 prefix)
     192.168.0.0     -   192.168.255.255 (192.168/16 prefix)
```

It's fairly easy to see that you can pick any subnet in the wide address space of the official [RFC 1918](https://datatracker.ietf.org/doc/html/rfc1918) ranges. I mean subnetting isn't hard either, right?

What could go wrong??

## The Good

Good rules of thumb:

* I usually pick the `10` space (most room == largest collision space == lowest risk)
* Something high (`>128`) in the second octet, ie `10.177`
* Limit to no more than a `/16`. (even 16 million IPs will run out very quick if you get greedy with the allocation sizes).
* Allocate based on [CIDR subnet boundaries](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing), not human-pleasing numbers:
    * :x: `10.177.220.0` (a nice human round number) 
    * :white_check_mark: `10.177.224.0` (a nice CIDR round number)

## The (Mundane) Bad

The thing that I found most often though was that everyone seemed to gravitate towards picking the same ranges. Then, if/when your company got bought or merged with another company, you would often find that you had overlapping internal ranges and one side either had to renumber (arg) or worse have some weird double-internal-NAT madness.

* :warning: Actually legit `RFC1918` space?
> :woman_shrugging: Yeah `192.186.1.0/24`, looks about right I think?
* :warning: Not the first `RFC1918` range you saw/thought of?
> :woman_shrugging: I saw `10.0.0.0/8` and thought yeah, that'll do..
* :warning: Not stupidly oversized 
> :woman_shrugging: I might need `65534` servers on this LAN, one day, ya never know?

**AWFUL** examples (just don't :no_good_woman:)

* `10.0.0.0`
* `10.1.0.0`
* `192.168.0.0`
* `192.168.1.0`
* `172.16.0.0`

I had a job where my predecessors had chosen `192.168.1.0/24` as the Datacentre's LAN range. Users working from home on a VPN could then never access those servers and the IT Support guys would have to talk them through reconfiguring their home routers to change their local subnet to something else :cry:. (like, what's the workaround when I'm not able to renumber the LAN?!)

## The (Creative) Bad - IP Squatting

When I started [my first proper tech job](/blog/2024/04/story-time-first-tech-job/) I was surprised to see that the company was using unknown-to-me internal network numbering. (The guys on the *Network Team* must know what they're doing... right?)

```
101.0.0.0/8     # Main office
102.0.0.0/8     # Office 2
103.0.0.0/8     # Office 3
...snip...
122.0.0.0/8     # Office 22
123.0.0.0/8     # Office 23
124.0.0.0/8     # Office 24
```

Each "site" at the company (ie, an office) had their own `/8` allocated. Did this company own ~10% of the usable IPv4 address space..? :thinking: (No, it turns out they were just IP squatting :woman_facepalming:).

This didn't cause them too many issues, this was back in the early 2000s, [pre-IPv4 exhaustion](https://en.wikipedia.org/wiki/IPv4_address_exhaustion#Exhaustion_dates_and_impact) so there were still lots of unallocated IPv4 `/8` netblocks.

> It was even fairly common practice in the way-back-when to use [BOGON filtering](https://en.wikipedia.org/wiki/Bogon_filtering) to block unallocated IP ranges on your firewall to stop "badness". The value of doing this, if there ever was any real value, flipped very fast into "harmful" teritory as the IPv4 space got rapidly handed out. You could have all the downsides of zero real benefits, and all the upsides of blocking legitimate traffic by failing to keep your (ever shortening) BOGON list up-to-date!

> My job at the **Managed Security Provider** ran their own BIND Authoritive DNS servers and we discovered an ancient BOGON blocking list deep in it's `named.conf` after some kind internet stranger kindly asked us "Why can't I resolve your zones?"

Towards the end of my time at the company, they (the Network team) had realised the madness, started to get more and more Helpdesk tickets for end-users unable to access websites that happened to use the squatted network space that were unreachable and started the painful process of renumbering All The Things.

They renumbered the branch offices `102.0.0.0/8` - `124.0.0.0/8` became `10.102.0.0/16` through `10.124.0.0/16`. The final boss `101.0.0.0/8` subnet outlasted my tenure there, as that one was much harder to renumber as it hosted all the critical services (think Active Directory Domain Controllers, DNS servers etc) that were hardcoded in losts of dusty places.

## The Ugly - Being Too Clever

I worked for a **Managed Security Provider**, that used an internal network range I'd never seen used before.

```shell
169.254.32.0/24 # VLAN 32 - Servers
169.254.39.0/24 # VLAN 39 - Clients
```

The range was familar to me as the network range your OS will give you an IP address in if it doesn't get a DHCP response. This was usually caused by a network issue (you can't reach the DHCP server) or less likely that the network is fine, but the DHCP server is dead.

I thought *"Oh, that's clever"*, they chose these ranges to side-step the "site-to-site VPN" both sides have picked the same `10.0.0.0/24` range problem entirely.

It must've worked fine when they thought of this idea, but as time progressed the *clever* idea started to become a headache..

In Windows XP and above, Microsoft added functionality that automatically created a *local* network route for the `169.254.0.0/16` subnet. This meant that any connection attempts to **ANY** IP in that range would never reach your Default Gateway (which you generally wanted), but would **ALWAYS** attempt to broadcast and connect on the local subnet.

The upshot was that our Windows users would never be able to check their email (as the email server was hosted in the `169.254.32.0/24` network), and other things :no_entry:. Even those of you who have never had the pleasure of IT Support can guess that it's a safe assumption that *Users Want Their Email*.

Never fear though, we had a workaround!

* Windows XP :warning: `route delete 169.254.0.0` (run from the Startup folder in a `.LNK`)
* Windows Vista :warning: `route -p add 169.254.32.0 mask 255.255.255.0 169.254.39.1`
    * The user had to manually run this once after every logon, due to `UAC` blocking this unless the user right-clicked the link we put on their desktop.

I remember being annoyed by this, until I read [the RFC](https://datatracker.ietf.org/doc/html/rfc3927#section-1.6) and found this pretty clear **SHOULD NOT** about exactly what we were doing.

```
1.6.  Alternate Use Prohibition

   Note that addresses in the 169.254/16 prefix SHOULD NOT be configured
   manually or by a DHCP server.
```

:tipping_hand_woman: **Counterpoint**: The *clever* person probably made this decision in the late 1990s before the RFC was published. It seems like `ZEROCONF` was one of those retrospective standards. (Counter-**counterpoint**: It still fails the **don't be too clever** test though!)

But it was actually Steve Jobs who put the final nail in the coffin of this *clever* idea. With the introduction of an important ~~toy~~ business communication device.. *drumroll* ... the **iPhone** :iphone:... Apple had implemented the same thing that Microsoft had, but our workaround was now umpossible.. *how do you run a shell command on one of those again?!*

So, unspeakable internal-NAT horrors were the "fix" to the *clever* set-up chosen to avoid internal-NAT horrors!  :clap: :clap: :clap: :clap: :clap:

## Postscript - What About IPv6?

I have yet to work in a company (accurate as of 2024) that has given a moment's thought to IPv6.

Any servers or clients that enable it by default, will have it enabled by default, but nothing will be aware of or make use of any link-local IPv6 address they may have configured.

Or if they have given it a moments notice then they have gone the other way:

> "Someone, somewhere has had a bad time with IPv6 and tried to disable it somewhere.. Usually only partially and then have forgotten about it again."
