---
title: "Hermes Agent on Buzz"
date: 2026-07-25
description: "I spent all night wiring a self-hosted AI agent into a chat app. It got as far as posting a message explaining that it was unable to post messages."
---

This past week has been a whirlwind. An OpenAI model escaping containment to hack into Hugging Face. Opus 5. The internet was abuzz. So I wanted to get Buzz working with Hermes Agent.

It feels like everyone is converging on the same thing. A unified work environment for humans and agents to collaborate, with durable context. Agentic memory systems. Graphs for some reason.

I had tried a lot of these projects before. For the most part I was happy wiring agents into Slack or Discord. My agents could mention each other. It wasn't until Buzz that I thought, ok, this one's a strong contender.

Late Friday night, my bookstore Hermes agent posted this into my Buzz chat channel:

> i cant actually reply in the channel rn tho, the buzz CLI needs BUZZ_PRIVATE_KEY set and its not in my env. could you help me get configured?

It was, of course, replying in the channel. It had burned through a good chunk of my Claude session limit trying to tell me it couldn't do the thing it was doing. This is how that happened.

<!--more-->

## The setup

[Buzz](https://github.com/block/buzz) is a self-hostable workspace where humans and AI agents share the same rooms. Block open sourced it recently. It runs as a desktop app, it speaks [nostr](https://nostr.com/) under the hood, and it can spawn agents locally and relay their messages into channels. Think Slack if some of the coworkers were processes on your laptop.

[Hermes](https://hermes-agent.nousresearch.com/) is Nous Research's agent. Mine lives on an Ubuntu LXC on a Proxmox box on a Beelink mini PC in my closet, reachable over Tailscale. It has my memory, my skills, my MCP servers, thirty-four days of uptime, and a genuinely alarming amount of context about my life and my bookstore.

Despite overwhelming evidence that it was a bad idea, I continued to do the majority of my development work on Windows. Because I am stubborn and I love video games. And WSL has worked fine for me. The problem is GUI apps like this one, and, as I would soon learn, anything that has to reconcile a Linux path with a Windows one.

You would think Hermes and Buzz would work great out of the box. They both speak [ACP](https://agentclientprotocol.com/), which, like MCP, is just a fancy name for some boring technology, in this case, newline-delimited JSON-RPC over stdio.

## First attempt

I just gave Opus 5 the GitHub links for Buzz and Hermes and said, go set this up. Because of my weird WSL setup, I was left with some scripts I had to run in bash and powershell.

What it prepared was a script that sets three fields in Buzz's config: the agent command, an override, and an args array. What I hadn't noticed is that Buzz recomputes two of those on every launch. So after a restart the config read: run `C:\Windows\System32\wsl.exe`, with no arguments, forever.

So the agents spawned, sat there, and died. Twenty-four of them, because that's the pool size Buzz ships with by default. This will be important later.

## WSL BS

I downloaded Buzz as a Windows binary. I admired the responsiveness of the Tauri UI. Buzz sends the agent a working directory over ACP so the agent knows where to operate. It sends it as a Windows path, because that's what it has:

```
"cwd": "C:\\Users\\Panat\\.buzz"
```

My Hermes is a Linux process. On Linux, that string is not an absolute path. It isn't a path at all.

I had already hit this once, getting Buzz on Windows talking to Claude in WSL. Claude rejects it on the spot:

```
Agent reported error (code -32602): Invalid params: `cwd` must be an
absolute path, but received: C:\Users\Panat\.buzz
```

This is a great error message, in `acp-agent.js`, in a function called `validateCwd` with a comment explaining it throws early "so clients can surface it to the user instead of failing later with an opaque SDK error." This is good engineering.

Hermes has no such check. It accepts the Windows path, binds its workspace to a directory that cannot exist, and then everything downstream fails silently and mysteriously. An hour of my night went to the difference between those two behaviors.

## .NET BS

Buzz will run any executable as an agent harness, but it has to be one executable with no arguments. So the bridge had to be a real binary.

I wrote a small C# launcher, compiled with the `csc.exe` that ships with .NET Framework, because it's already on every Windows machine and I wasn't about to install a toolchain at 1 a.m. It does three things: pipe stdio to an SSH session, rewrite the `cwd`, and pass credentials.

First attempt failed. No output, no error. Just a hanging process.

In .NET, `Process.Start` with `UseShellExecute = false` and no stream redirection does not pass `bInheritHandles = true` to `CreateProcess`. The child gets no stdin and no stdout.

The fix is to redirect all three streams explicitly and pump them yourself, flushing per chunk so JSON-RPC framing stays responsive:

```csharp
RedirectStandardInput  = true,
RedirectStandardOutput = true,
RedirectStandardError  = true,
```

The `cwd` rewrite is a regex over the client-to-agent direction only, scoped to the four methods that have a working directory. Rewriting every occurrence would corrupt any message where someone typed a path into a chat.

## Give the agent keys

Around 2 a.m. I had a realization. Every failure so far traced back to one thing: Buzz owned the agent's identity. Buzz held the agent's keypair, spawned the process, signed on behalf of the agent. That's why the working directory was a Windows path. That's why I had to ship the credentials over SSH to the Hermes box.

The relay is nostr. Anyone with a key can be a member. So why not let the agent hold its own key on its own machine and join as a peer?

Digging around in the Experimental Settings, I found someone had already thought about this.

I flipped the switch, generated a keypair on the Hermes box, invited the pubkey through Buzz's settings, and pulled the Linux `buzz` CLI out of the 66MB `.deb` (it turns out to be a self-contained 16MB binary that links against libc and nothing else, no GUI dependencies at all). Then I wrote a poll loop: check for mentions every fifteen seconds, wake Hermes, let Hermes reply.

It worked. Hermes replied in threads, under its own key, with Buzz reduced to a chat client. Architecturally it was the cleanest thing I had wired up all night.

Then I looked at the actual chat window. No mention chip. Typing `@Hermes` produced plain text instead of the highlighted token like the other agents. Where the owner should be, it said "owner unavailable." This was deeply unsatisfying.

Buzz's composer indexes agents. Hermes was now a member. A member is not an agent.

For a moment there, if it wasn't for the poll loop, I would have been perfectly satisfied and could have gone to sleep.

## Where it landed

I tore out the poll loop and went back to a normal Buzz-managed agent, with Hermes as the harness.

The missing piece was credentials. Buzz puts `BUZZ_PRIVATE_KEY`, `BUZZ_AUTH_TAG` and `BUZZ_RELAY_URL` in the agent's environment so the agent's own CLI can post as itself. SSH doesn't forward arbitrary environment variables, and adding `AcceptEnv BUZZ_*` to `sshd_config` needs root.

But `sshd` already accepts `LC_*`, for locale. So the launcher ships them as `LC_BUZZ_PRIVATE_KEY` and friends, and a four-line wrapper on the far side renames them back before exec. It's a locale variable smuggling a nostr private key across a network boundary. I'm not proud of it and I'm not changing it.

The values live in the launcher's environment block and get handed to `ssh` directly, so they never touch a command line and never show up in `ps` on either machine.

This is also where the pool size comes back. Twenty-four slots is fine when each one is a local process. Here each slot is a whole remote Hermes adapter, and twenty-four of them filled a 4GB LXC to 3.5GB doing nothing. Set `parallelism` to 1.

So, all together now: Buzz on my desktop, one agent configured in the UI (name and photo is enough, the command gets swapped underneath), an SSH hop to my agent's box, Hermes doing the thinking, replies coming back as ACP text that Buzz posts into the thread. Mention chip works great.

## The Sauce

You probably came here wondering how to get Hermes working with Buzz. And you had to sit through my entire night's backstore before you could get to the recipe. Thanks for that. Here you go:

Before you paste this, have these ready:

- Hermes installed and working on the remote box, with a user that owns it (mine is `hermes`, home `/opt/hermes`).
- SSH from your desktop to that user with a key and no password prompt. Test it first: `ssh hermes@yourbox true` should return instantly and silently.
- Buzz Desktop installed, and an agent created in the UI. Name and avatar are all you need, the command gets replaced.

Then hand this to Claude Code, Codex, or whatever you're using, on the machine running Buzz:

````
I want to run a remote Hermes agent as a Buzz Desktop agent harness.

Setup:
- Buzz Desktop runs on THIS machine.
- Hermes runs on <HOST> as user <USER>, home <REMOTE_HOME>, reachable over SSH
  with key <KEYPATH>. `ssh <USER>@<HOST> true` already works.
- I have already created an agent in the Buzz UI named <AGENT>.

Build me a launcher that Buzz can spawn, which bridges to the remote Hermes ACP
adapter over SSH. Read these constraints before you write anything, they are all
things that bite:

1. Buzz spawns ONE executable with NO arguments. Whatever you write has to be a
   single file Buzz can exec directly. On Windows that means a real .exe, not a
   .cmd or .bat or a wsl.exe invocation.

2. In Buzz's managed-agents.json, only `agent_command` is an input field.
   `agent_command_override` and `agent_args` are recomputed on every launch, so
   writing them does nothing. Set `agent_command` only, then restart Buzz and
   diff the file to confirm what stuck.

3. ACP is newline-delimited JSON-RPC over stdio. Buzz sends a `cwd` that is a
   path on THIS machine, which does not exist on the remote box. Hermes has no
   validateCwd, so it binds a workspace to a nonexistent directory and fails
   late and silently. The launcher must rewrite `cwd` to a real remote path.
   Rewrite ONLY on the client-to-agent direction, and ONLY in messages whose
   method is session/new, session/load, session/fork or session/list. A blanket
   replace corrupts chat text that happens to contain a path.

4. Buzz puts BUZZ_PRIVATE_KEY, BUZZ_AUTH_TAG and BUZZ_RELAY_URL in the agent's
   environment so the agent's own `buzz` CLI can post as itself. sshd will not
   forward those. Ship them as LC_BUZZ_* (sshd accepts LANG, LC_*, COLORTERM,
   NO_COLOR by default) with -o SendEnv, and rename them back in a wrapper on
   the far side. Do not put secrets on a command line, they show up in `ps`.

5. On the remote side, write a wrapper script that renames the LC_ vars, sets
   HERMES_ACP_SKIP_CONFIGURED_MCP=1, and execs hermes-acp. Without that env var
   every pool slot starts all globally configured MCP servers before serving,
   which is seconds of startup and hundreds of MB each.

6. Set the agent's `parallelism` to 1 in managed-agents.json. The default is 24,
   and here each slot is a whole remote adapter process.

7. If you are on Windows and write a C# launcher: Process.Start with
   UseShellExecute=false and NO redirection does not set bInheritHandles, so the
   child gets no stdio and hangs with no error. Redirect all three streams and
   pump them yourself, flushing per chunk.

Verify by tailing the Hermes log while I send a message, and show me the line
that confirms the session was created with the rewritten cwd.
````

Fill in the angle brackets. Everything else is the same on any setup.

The remote wrapper is small enough to just write yourself. Mine is at `/opt/hermes/.local/bin/hermes-acp-buzz`:

```bash
#!/bin/bash
for v in PRIVATE_KEY AUTH_TAG RELAY_URL ACP_MODEL ACP_SYSTEM_PROMPT ACP_AGENTS; do
    src="LC_BUZZ_${v}"
    [ -n "${!src}" ] && export "BUZZ_${v}=${!src}"
    unset "$src"
done

export HERMES_ACP_SKIP_CONFIGURED_MCP=1
export PATH="/opt/hermes/.local/bin:$PATH"

exec /opt/hermes/.hermes/hermes-agent/venv/bin/hermes-acp "$@"
```

The `cwd` rewrite is the only clever part. Here it is in Python, which is what I'd use if Buzz were running on a Mac or a Linux desktop, where a bash script counts as an executable:

```python
#!/usr/bin/env python3
import os, re, subprocess, sys, threading

HOST, KEY = "hermes@kurokami", os.path.expanduser("~/.ssh/buzz_hermes_ed25519")
REMOTE_CWD = "/opt/hermes"
FORWARD = ["BUZZ_PRIVATE_KEY", "BUZZ_AUTH_TAG", "BUZZ_RELAY_URL"]

METHOD = re.compile(rb'"method"\s*:\s*"session/(new|load|fork|list)"')
CWD = re.compile(rb'"cwd"\s*:\s*"(?:[^"\\]|\\.)*"')

env = dict(os.environ)
args = ["ssh", "-T", "-o", "BatchMode=yes", "-o", "ServerAliveInterval=30", "-i", KEY]
for name in FORWARD:
    if env.get(name):
        env["LC_" + name] = env[name]
        args += ["-o", "SendEnv=LC_" + name]
args += [HOST, "/opt/hermes/.local/bin/hermes-acp-buzz"]

p = subprocess.Popen(args, stdin=subprocess.PIPE, stdout=sys.stdout.buffer, env=env)

for line in sys.stdin.buffer:
    if METHOD.search(line):
        line = CWD.sub(b'"cwd":"' + REMOTE_CWD.encode() + b'"', line)
    p.stdin.write(line)
    p.stdin.flush()
```

On Windows you need the compiled version, since Buzz has to exec a real binary. Same logic, plus the stream redirection from earlier so the child actually gets a stdin. `csc.exe` ships in `C:\Windows\Microsoft.NET\Framework64\v4.0.30319`, so there's nothing to install:

```
csc.exe /nologo /optimize /out:buzz-agent-hermes.exe buzz-agent-hermes.cs
```

Point `agent_command` at that path, restart Buzz, and add the agent to a channel. A fresh agent is subscribed to nothing, and the log will tell you so:

```
discovered 0 channel(s) — agent will sit idle
```

Longer term none of this should be necessary. There's an [open issue](https://github.com/NousResearch/hermes-agent/issues/68871) asking for native Buzz support in Hermes, and Hermes already has twenty platform plugins in `plugins/platforms/` that all follow the same five-file shape. So it's a only a matter of time.

## Update: there's a better way

I slept on it, and most of the above turned out to be unnecessary.

A correction first. I said `agent_command` is the input field and the other two get recomputed. That was true for the version I was fighting. Buzz 0.4.26 flipped it. Now you set `agent_command_override`, and Buzz writes `agent_command` back out itself. If you followed the recipe above and nothing happened, that's why. The order it resolves in is in `record_agent_command`, in `desktop/src-tauri/src/managed_agents/discovery.rs`.

`buzz-acp` connects to the relay on its own. Buzz Desktop is just one thing that spawns it. So instead of bridging stdio from Windows to Linux over SSH, run `buzz-acp` on the same box as Hermes and point it at the local adapter.

```
buzz-acp --agent-command /opt/hermes/.hermes/hermes-agent/venv/bin/hermes-acp
```

Three env vars: `BUZZ_PRIVATE_KEY`, `BUZZ_AUTH_TAG`, `BUZZ_RELAY_URL`. All three are already in the agent's record in `managed-agents.json`. Run it as a systemd `--user` unit with lingering on and it stays up by itself, and you can reach it from any device.

That deletes the launcher, the SSH hop, the `cwd` rewrite, and the locale variable smuggling. All of it existed because the spawning process was on Windows and the agent was on Linux. Put them on the same machine and none of it is needed.

Four settings do most of the work. All four default the wrong way for this:

- `BUZZ_ACP_NO_BASE_PROMPT=true`. `buzz-acp` adds its own prompt telling the agent the `buzz` CLI is how it talks, with `printf 'a\nb' | buzz messages send` examples. With Hermes that puts literal `\n` in your chat. Write a system prompt telling it to just answer and the two fight, and it posts the CLI command as its message instead. Replies already come back as ACP text, so turn it off.
- `BUZZ_ACP_RELAY_OBSERVER=true`. Off by default, and without it you get no thinking traces or tool calls in Activity.
- `BUZZ_ACP_AGENT_ARGS=`, empty. It defaults to `acp`, because the reference runtime is invoked as `goose acp`. Hermes exits with `unrecognized arguments: acp`.
- A system prompt that isn't blank. With an empty one, "hey" turned into thirteen tool calls and a one-line answer.

If the user running the service isn't in `adm` or `systemd-journal`, `journalctl` shows you nothing and you'll debug blind. Log to a file.

This doesn't fix multi-device. Whether you can see an agent depends on whether your machine owns it, so a second desktop either can't see it or tries to run its own copy. That's [issue #2349](https://github.com/block/buzz/issues/2349), and [PR #2468](https://github.com/block/buzz/pull/2468) is the fix, publishing externally hosted agents to the relay directory so any device can see them without owning the process. [PR #2633](https://github.com/block/buzz/pull/2633) adds Hermes as a proper runtime instead of something you pin by absolute path.

Until those land it works fine on one machine. Mine's been running on the Beelink since, answering in a couple of seconds, and my desktop hasn't been part of it.
