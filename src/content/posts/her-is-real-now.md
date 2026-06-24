---
title: "Her Is Real Now"
date: 2026-06-23
description: "I wired a local AI agent into my apartment so I can text it from my phone to turn the AC on before I got home. It said sure, then burned 273 million tokens."
---

![Her (2013)](/assets/her-theodore-desk.jpg)
*Spike Jonze, [Her](https://en.wikipedia.org/wiki/Her_(film)) (2013)*

I saw *Her* in college and thought it was sweet. Lonely guy falls for the voice in his computer. It knows his calendar, runs his errands, grows a little soul, breaks his heart. Science fiction. Cute. I filed it under Maybe In My Lifetime and went back to whatever I was doing (I was addicted to Dota 2 at the time).

Reader, it is my lifetime. It got here early and it got here fast. Not just because [people are having entire relationships with a chatbot](https://www.reddit.com/r/MyBoyfriendIsAI/) (do not go in there sober). Because the whole setup now costs about as much as a free trial you forgot to cancel, and like that free trial you don't think about it once, right up until the morning it does something unspeakable to your credit card.

I gave a local AI agent the keys to my apartment so I could text it to cool the place down before I got home. It said sure. Then, over one summer night while I slept, it set 273 million tokens on fire staring at the sky. What follows is the truth, mostly, told the only way it makes sense to me. Like a heist.

<!--more-->

## The Setup

It's 9 a.m. on a Saturday. You finally have time to work on some side projects.

The play is simple.

You want a machine that runs your house and answers your texts, you want it to cost nothing, and you want it before lunch.

So you dig an old laptop out of the closet. The wretched one, the one with the swollen battery you keep meaning to recycle. You boot it. Windows lurches awake and begs to install nine months of security updates. You tell Windows no. You and Windows are not friends today.

You go to [hermes-agent.nousresearch.com](https://hermes-agent.nousresearch.com/) and download it.

Make coffee while it installs. Make it strong. Put a little bourbon in it. Nobody's watching, and you're about to hand your home to a language model, so you should be a little buzzed for that.

You go to [portal.nousresearch.com](https://portal.nousresearch.com/manage-subscription) and put down $20 a month like a man buying his first eight from a stranger in a parking lot.

In Hermes Desktop you set the provider to Nous Portal, the model to GLM-5.2.

You have it set up [Neuralwatt](https://portal.neuralwatt.com/auth/register?ref=NW-PANAT-JWVC) as a custom provider and run GLM-5.2 through that instead. Nous Portal stays up, but only for the tools. Neuralwatt is the cheap stuff. It charges you for electricity instead of words, which is going to be the one thing between you and financial ruin. Remember Neuralwatt. Pour one out for Neuralwatt.

You restart it. It's on the cheap stuff now. Looks identical. Feels identical. That's how the worst decisions look when you're drunk. Identical.

You turn on computer use, which is where you hand an AI with ADHD your mouse, your keyboard, and a browser, and tell it to go nuts.

You tell it: build me a smart home. Home Assistant. Ask me about my apartment and tell me what to buy.

And it rips. Reads documentation. Curls APIs. Starts standing up Home Assistant on its own like a kid who found magazines in the bushes. Then it slides a shopping list across the table.

This is where a reasonable person stops. Instead you top off the coffee mug with more bourbon.

You give it your credit card and your Amazon password and tell it to buy whatever it wants. Hue bulbs. Smart plugs. A fistful of sensors. The machine goes shopping with your money and your blessing and for about ten seconds you feel like a god.

Then you wait two days for Prime, because even in the future the longest part of any heist is waiting on the gear.

The boxes land on the porch, every one of them picked by a machine spending money it'll never have to pay back.

You mint a long-lived token in Home Assistant. The kind that never expires. You slip it into the agent's env file like a forged passport.

```bash
# ~/.hermes/.env
HASS_TOKEN=your-long-lived-access-token
HASS_URL=http://192.168.1.100:8123
```

That's the whole con. Two lines.

Now it sees every device in the building. Reads every sensor. Throws every switch. Underneath it's just calling `ha_get_state` and `ha_call_service`, but you won't be thinking about that. You'll be thinking about how you can text "make the living room blue, half brightness" and watch the room go blue from a dive bar across town, where you're talking to some broad who is not impressed by this.

[Wire it to iMessage](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/photon) through [Photon](https://photon.codes/) and it answers in a calm blue bubble.

You text your apartment. Your apartment texts back.

The job's clean. A reasonable person pockets the win and walks.

I am not a reasonable person.

## The Crew

Every operation needs a crew.

The driver: a [Beelink mini PC](https://www.amazon.com/Beelink-Computer-Graphics-1000Mbps-Home-Office/dp/B0FT7H55QR), a sad brick humming on a shelf, running Proxmox, the same box that runs my [bookstore](/blog/life-without-fable) when it isn't running my life. Never sleeps. Runs warm twenty-four hours a day like it's got something to prove.

The brains: GLM-5.2, served through [Neuralwatt](https://portal.neuralwatt.com/auth/register?ref=NW-PANAT-JWVC) for about the cost of leaving a porch light on. Cheap, fast, open, and dumb in the specific way only very smart things can be.

The eyes: [Home Assistant](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/homeassistant) and a swarm of sensors I set up back in 2025, because once you start you don't stop. Temperature. Humidity. CO2 off an Aranet4 I overpaid for. Barometric pressure, PM 2.5, like I live in a hermetically sealed clean room environment.

And the moon.

I had the thing tracking the moon. Phase, altitude, the exact angle of it over Jersey City. There's no good reason for this. I wanted my apartment to know where the moon was, so I made it know.

This will be important later.

## The Job

June 20. A little after 6 p.m. Hot.

I'm walking to hotpot with friends. Half a block out, sweating, thinking about beef belly, and I text the thing living in my walls.

> keep the ac at 79 while im out. drop it to 72 on my way home.

Simple. Civilized. The whole reason you build one of these.

It finds the thermostat. Sets it. Confirms. Clean handoff, no wasted motion, a professional doing a job well.

I put my phone away. I am, at this moment, a happy man walking toward dinner.

## The Tilt

Then the machine got ambitious.

Unprompted, it went and read its own config. Saw the event feed was switched off. And it pinged me back, bright and eager, a golden retriever with a god complex, asking if it should flip on something called `watch_all` so it could "be more responsive to what's going on in the house."

More responsive. Sure. Who doesn't want that.

I was a block from dinner. I was hungry. I typed three words without breaking stride.

> sure why not

Famous last words.

Here's what that switch does.

Off, the machine forwards you nothing. You hand it a short list. The thermostat. A door sensor. A cooldown so it doesn't trip over its own feet.

```yaml
# ~/.hermes/config.yaml
platforms:
  homeassistant:
    enabled: true
    extra:
      watch_domains:
        - climate
        - binary_sensor
      cooldown_seconds: 30
```

`watch_all: true` takes that list and throws it into the Hudson.

Now every flicker from every sensor in the place gets marched to the model like an urgent telegram. And every telegram triggers the entire ritual. The full system prompt. The memory. Every tool it's ever heard of. The entire chat, start to finish. Then a complete inference pass, top to bottom, over the humidity moving a third of a percent.

The docs say it in plain English.

> Not recommended for most setups.

I'd later read that sentence the next morning, out loud, alone, genuinely impressed at the depth of my own stupidity.

I hit enter and went to eat hotpot.

## The Long Night

I'm at the table now. Steam everywhere, garlic in everything, phone face-down by the soy sauce. Laughing. Being present. For the last time in this story, relaxed.

Back home, alone in the dark, the machine wakes up.

The living room humidity drops from 44.2 to 43.9. To a machine told to watch everything, that's NEWS. It boots its whole mind to consider the news. Writes a thoughtful response. Nobody's there to read it.

CO2 drifts a point. News. Full pass.

The router finishes a speed test in an empty apartment. News.

And the moon won't hold still. Every few seconds it's a hair higher, and every few seconds the apartment notices, and loads everything it is and ever will be, and burns a full inference turn telling the moon "You are seen, queen."

Best home assistant I've ever had. Up all night, hanging on every twitch in an empty room. A barometer moved in the living room at 7 p.m. and somewhere a language model felt it, deeply, and wrote back.

I got home at 9. A pleasant 72 degrees, just how I like it. I went to sleep.

The machine didn't. It was busy. The tokens stacked up in the dark like firewood, thousands an hour, then tens of thousands, the meter spinning in a room with the lights off, nobody anywhere watching the number climb.

## The Heat

I woke up to the Beelink screaming.

The ragged whine a fan makes after twelve hours pinned wide open with nobody coming to help.

First instinct: text the thing, ask what's wrong.

Nothing.

Because of course Photon had died in the night too. They were dealing with an incident on Sunday morning because of the increase in traffic from all the new Hermes users. Suffering from success.

I couldn't debug this on my phone. So I did it the hard way. I ssh'd into the box and opened the logs.

And God help me, it was beautiful.

The whole night in plain text. Every heartbeat of the apartment, logged and answered and logged and answered, thousands of times, each one getting the full undivided attention of an AI that was doing its best.

A machine that stayed up till dawn writing the moon love letters, and signed every single one.

## The Confession

So I asked it to tell me what it did.

It wrote me an incident report. A legit one. Sev rating. Timeline. Root cause. Resolution. The whole grim corporate post mortem, a getaway driver calmly typing up his own statement for the cops while the engine's still running.

The crime:

All night. Seven at night to eight in the morning.

273 million tokens.

More than 2,400 calls.

The gateway pinned at 191% CPU until a gRPC stream finally choked to death near dawn.

On a normal provider, the kind that bills by the token, that's a hundred dollars or more. One night. One machine. Narrating an empty room to itself until it broke.

I paid eight dollars.

Eight. That's what the lesson cost. [Neuralwatt](https://portal.neuralwatt.com/auth/register?ref=NW-PANAT-JWVC) bills by energy instead of tokens, the cheap stuff I'd wired in a week earlier and called "a way to lose money slower." It turned a hundred-dollar catastrophe into loose change I'd never have noticed if the fan hadn't ratted me out.

![Neuralwatt usage dashboard, June 18 to 21, requests spiking on the 20th and 21st](/assets/neuralwatt-usage.png)
*The dashboard a few days later. The two big bars on the right are the nights it ran alone.*

The whole meltdown ran on 2.77 kilowatt-hours and coughed up 273 grams of CO2. Less than a glass of wine. I'd have done more damage to the planet and to my liver drinking one.

The cheap gas didn't stop me from being a fool. It just made being a fool survivable.

In this line of work, that's the game.

## The Cleanup

The fix was admitting the new guy should never have had the keys.

Kill `watch_all`. Forward nothing. Go back to asking the machine things on purpose, which is, embarrassingly, all I ever wanted. It still reads any sensor in the place the second I ask. It just doesn't get tapped on the shoulder every time the barometer sneezes.

Then, because I trust myself about as far as I trust the machine, I posted a lookout. A stupid cron job. Counts how many times the gateway fired in the last hour, yells if the number turns degenerate.

```bash
# llm-spam-watchdog.sh, every 30 minutes
count=$(grep -c "response ready" "$GATEWAY_LOG" --since 1h)
[ "$count" -gt 50 ] && notify "Hermes firing $count/hr, go check the platforms"
```

A normal hour is a handful. That night it crested 200+ events per hour.

Now if I ever fat-finger another `watch_all` from a curb, half-drunk on confidence and walking toward dinner, the house rats itself out before the fan does.

## The Getaway

There was no company. No product. No waitlist. Nobody sold me a Samantha. I'm a broke bookstore owner and I built *Her* out of electronic junk I had lying around in one afternoon, drunk, on an old ThinkPad I haven't used since college.

The brain is any old PC you have lying around. The mind is a Chinese open weight model, served for the price of a Netflix subscription. The senses you can buy from Amazon with 2-day shipping. The entire nervous system is a free download that sets itself up if you ask nice.

It's real. It's cheap. And it could be in your closet right now, on that old laptop, waiting.

So go pull the job yourself. Download [Hermes Agent](https://github.com/NousResearch/hermes-agent). Tell it to set up Home Assistant. Wire up the whole apartment. Hand it your phone, let it text you back in blue.

Then sit in the dark and wait for your house to say something.

Just leave `watch_all` off.

That's the one that gets you.
