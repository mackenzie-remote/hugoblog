+++
title = "How To Get A New IP Address From Bell Aliant with OpenWrt"
date = "2024-04-06T16:03:07-03:00"
tags = ["tech"]
+++

## Introduction

When I moved to Canada I brought with me my old [TP-Link Archer C7 v2](https://openwrt.org/toh/tp-link/archer_c7) router. I brought it more so I didn't have to throw it out, and didn't expect I'd use it, as it was already pretty old by this point (I bought it in 2016, and this was 2021). I thought "maybe I'll just use whatever router my new ISP gives me".

Well, it turns out that the router that my new ISP gave me was pretty garbage, the unloved **Home Hub 3000** (hereafter referred to as HH3K). I tried for a long time to use it, but it was unreliable, and the WiFi wasn't even very good either.

So reluctantly I dug out the **Archer C7**, flashed the latest version of OpenWrt, and put the **HH3K** into Bridge mode.

The default bridge mode on the **HH3K** lumbers you with Double NAT (yuck, gross). There is an option to do Layer-2 bridging, but my experience with it is that it would work until there was a network or power outage, and it would not work again until an unlucky human disabled and reenabled bridge mode on the **HH3K**'s WebUI... Nope!

So I followed a guide for **Bypassing HH3K** online (can't remember which one), but it involves removing the SFP module from your **HH3K** and putting it in a **SFP to RJ45 Fiber Media Converter** (sold separately), then plugging the OpenWrt router's WAN port into the this device and getting a delicious WAN DHCP IP address.

## Get A Random IP Address with OpenWrt

I'm a bit of a privacy geek, and like most cable/fibre home internet connections you end up with a fairly static IP address. The only times I can remember my IP changing naturally is after extended power outages.

I had to experiment a bit to get this working, as Bell with almost always give you the same DHCP lease back no matter what you do, besides disconnecting your internet for the length of the DHCP lease (which is pretty long).

I found the simplest way to get a new DHCP address from Bell is to send a different `hostname` in the `DHCPDISCOVER` packet.

The complexity though is that you have ask a completely random number of times before Bell will give allocate you a different IP address. So I wrote a script that is designed to be run multiple times until you do get a new IP address.

Steps:

0. Check if the IP has already changed, if it has, it's a no-op.
1. Change the `Hostname` to a semi-random one.
2. Call `ifup wan` which takes the interface DOWN (which does a `DHCPRELEASE` on my old IP) then brings up back UP and sends a `DHCPDISCOVER` with the new hostname.
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
ORIGINAL_HOSTNAME="OpenWrt"
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
    uci set network.wan.hostname="${ORIGINAL_HOSTNAME}"
    uci commit network
    wan_ddns.sh ## this calls my Dynamic DNS update script
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

1. 81% of the time I get a new IP address overnight 🎉
2. 13% of the time I get a new IP address on the second day 🤷‍♀️
3. ~5% of the time it takes 2 to 5 days before I get a new IP address 🙈

The longest stretch has been 5 days without an IP change.

## Would You Recommend Doing This?

Hmm.. unless you care about your IP changing then definitely not.

I did scare myself once when my this script ran during an BellAliant outage... I thought I'd angered the DHCP gods as I was not getting a response to my `DHCPDISCOVER` packets, but it was an outage on their end. I do think that I caused myself to have a longer outage than most normal Bell users, as they would keep service until their DHCP lease had to be renewed naturally.

I tried to architect this in a way not to piss off or abuse my ToS on Bell, this seems pretty fair to me:

* I'm `DHCPRELEASE`ing my old IP before asking for a new one.
* (I'm sure there are way more unintentionally broken DHCP clients hammering Bell's DHCP servers).
* I could run this every minute, but I only call it a few times per-hour.
