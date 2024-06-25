+++
title = "How To Get A New Random IP Address From Bell Aliant with OpenWrt"
date = "2024-04-06T16:03:07-03:00"
slug = "how-to-get-a-new-random-ip-address-from-bell-aliant-openwrt"
tags = ["tech"]
+++

{{< custom-toc >}}

## Introduction

I'm a bit of a privacy geek, and it would be nice if I could have a non-static home IP address without using a sketchy VPN service.

With most cable/fibre home internet connections (BellAliant included) you end up with a fairly static IP address. The only times I can remember my IP changing naturally is after extended power outages.

This post documents my discovery and experience of scripting a way to semi-reliably get a new IP address on my BellAliant connection with my OpenWrt router.

## Set-Up

First this guide assumes that you have a bypassed your **Home Hub 3000** by putting it's SFP in a **SFP to RJ45 Fiber Media Converter** and have an RJ45 cable connected to the WAN port of your OpenWrt router. There are guides and YouTube videos online. The upshot is that you have an interface called `wan` that get's it's IP address via DHCP.

## Get A Random IP Address with OpenWrt

I had to experiment a bit to get this working, as Bell with almost always give you the same DHCP lease back no matter what you do, besides disconnecting your internet for the length of the DHCP lease (which is pretty long).

I found the simplest way to get a new DHCP address from Bell is to send a different `hostname` in the `DHCPDISCOVER` packet.

The complexity though is that you have ask a completely random number of times before Bell will allocate you a different IP address. So I wrote a script that is designed to be run multiple times until you do get a new IP address.

Steps:

0. Check if the IP has already changed, if it has, it's a no-op.
1. Change the `Hostname` to a semi-random one.
2. Call `ifup wan` which takes the interface DOWN (which does a `DHCPRELEASE` on my old IP) then brings it back UP and sends a `DHCPDISCOVER` with the new hostname.
3. Wait 30 seconds and check if the IP address changed or not.

The script is then run from `cron` several times an hour during the night. I only do it overnight as it will disrupt existing network connections briefly. The majority of the times we call it we don't get a new IP address, but we keep trying.

Here is the crontab:

```shell
5 2 * * * ifstatus wan | jsonfilter -e '@["ipv4-address"][0].address' >/tmp/wan_ip.txt
6,15,36,51 2-5 * * * /etc/config/wan_ip_changer.sh
```

and here is `wan_ip_changer.sh`

```shell
#!/bin/sh

OLD_IP="$(cat /tmp/wan_ip.txt)"
CURRENT_IP="$(ifstatus wan | jsonfilter -e '@["ipv4-address"][0].address')"
NEW_HOSTNAME="OpenWrt$(date +%d%H%M)"

if [[ "${OLD_IP}" == "${CURRENT_IP}" ]]; then
  echo "IP needs changing.. Setting hostname to $NEW_HOSTNAME"
  uci set network.wan.hostname="${NEW_HOSTNAME}"
  uci commit network
  sleep 1
  ifup wan
  sleep 30
  NEW_IP="$(ifstatus wan | jsonfilter -e '@["ipv4-address"][0].address')"
  if [[ "${OLD_IP}" == "${NEW_IP}" ]]; then
    echo -en "IP did NOT change ${OLD_IP}\n"
  else
    echo -en "IP CHANGED ${OLD_IP} to ${NEW_IP}\n"
    ## Good place to call your Dynamic DNS update script if you have one!
  fi
else
  echo "No-op"
fi
```

You can SSH into the OpenWrt box and check the `logger` output:-

```bash
root@OpenWrt:~# logread  | grep wan_ip
## edited to make this more readable..

02:06:01 IP needs changing.. Setting hostname to OpenWrt060206
02:06:32 IP did NOT change

02:15:01 IP needs changing.. Setting hostname to OpenWrt060215
02:15:32 IP did NOT change

02:36:01 IP needs changing.. Setting hostname to OpenWrt060236
02:36:32 IP did NOT change

02:51:01 IP needs changing.. Setting hostname to OpenWrt060251
02:51:32 IP CHANGED to 142.x.x.x

03:06:00 No-op

03:15:00 No-op

03:36:00 No-op
```

## How Often It Works

I kept a log on IP changes and I after crunching the data I can see that over the last 7 months that this has been running that:

1. 81% of the time I get a new IP address overnight :tada:
2. 13% of the time I get a new IP address on the second day :woman_shrugging:
3. ~5% of the time it takes 2 to 5 days before I get a new IP address :see_no_evil:

The longest stretch has been 5 days without an IP change.

## Would You Recommend Doing This?

Hmm.. unless you care about your IP changing then definitely not.

I did scare myself once when my this script ran during an BellAliant outage... I thought I'd angered the DHCP gods as I was not getting a response to my `DHCPDISCOVER` packets, but it was an outage on their end. I do think that I caused myself to have a longer outage than most normal Bell users, as they would keep service until their DHCP lease had to be renewed naturally.

I tried to architect this in a way not to piss off or abuse my ToS on Bell, this seems pretty fair to me:

* I could run this every minute, but I only call it a few times per-hour.
* I'm `DHCPRELEASE`ing my old IP before asking for a new one.
* .. and I'm sure there are way more unintentionally broken DHCP clients hammering Bell's DHCP servers 24/7.
