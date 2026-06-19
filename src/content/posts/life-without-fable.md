---
title: "Life Without Fable"
date: 2026-06-19
draft: false
description: "Yesterday I tried GLM-5.2 on a refactor and burned through forty dollars before I worked out what I was doing wrong. A journal entry about finding a cheap provider and getting it into three coding agents that don't support it yet."
---

Yesterday I wanted to refactor the check-in kiosk for my silly membership loyalty platform for my bookstore. I had planned to use Fable to deal with it, but we all know how that ended. Z.ai's GLM-5.2 had been generating a lot of buzz so I wanted to try it out on what I believe to be a big one-shot task I'd normally hand to Fable. By the end of the day I'd burned through over $40 of tokens trying to find a decent provider for GLM-5.2 and get set up to code with it. Here's how it went.

<!--more-->

GLM-5.2 is the first open-weights model to [cross 80% on Terminal Bench](https://z.ai/blog/glm-5.2), and is competitive with Opus 4.8 and GPT 5.5 on [long-horizon benchmarks](https://huggingface.co/blog/zai-org/glm-52-blog). As a lazy developer, I just want to plan a task with a coding agent, and leave it unattended so I can go for a walk or play video games (after beating 007 First Light, I'm now playing Path of Exile 2). I've been doing this with great success using Claude Code, even before they released auto mode, or loops, or `/goal`, or workflow, or whatever buzzword the industry cooks up to get you to burn more tokens.

My coding workflow is relatively simple:

1. plan from my Obsidian vault
2. start working
3. use Graphite to open stacked PRs
4. request Copilot review
5. address review and reply to comments
6. I come back after grinding Magic the Gathering: Arena and review the stack
7. If I need to, I'll deploy the stack locally or on staging and test it E2E myself
8. Merge the whole stack via Graphite
9. Write a journal entry in my Obsidian vault
10. Start another game of Magic and repeat the loop

So now I have to see how transferrable this is to other coding agents. I had set up [OpenCode](https://opencode.ai/) a while back as a backup when Claude was down. Then when pi came out, I moved over to that. I use Moonshot Kimi K2.6, served via OpenRouter with BYOK scoped to only Fireworks and Together.ai. I'm pretty happy with Kimi K2.6 but supposedly GLM-5.2 is on another level. As an aside, the Hermes Agent that runs my entire bookstore's backoffice uses GLM-5.1 + Kimi K2.6.

Searching for a way to use GLM-5.2 brought me back to OpenCode which supports GMI Cloud out of the box. As one does, I picked GMI Cloud by going on [Artificial Analysis](https://artificialanalysis.ai/models/glm-5-2/providers) and looking for the fastest and cheapest provider. At the time GMI was #1 on output speed (166.3 t/s) and price ($0.72/1M tokens). Apparently the price is wrong because the model card on GMI has it as input $0.979, output $3.08, cache read $0.182, per 1M tokens. Still orders of magnitude cheaper than Opus.

"Out of the box" oversells it a bit. OpenCode knows GMI as a provider, but the GLM-5.2 model isn't in its catalog, so you have to configure it:

```jsonc
// ~/.config/opencode/opencode.jsonc
{
  "provider": {
    "gmicloud": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "GMI Cloud",
      "options": { "baseURL": "https://api.gmi-serving.com/v1" },
      "models": {
        "zai-org/GLM-5.2-FP8": {
          "cost": { "input": 0.979, "output": 3.08, "cache_read": 0.182 },
          "limit": { "context": 1048576, "output": 131072 }
        }
      }
    }
  }
}
```

Then I pointed it at my refactor plan and let it rip.

About halfway through the 10-step refactor plan, I ran out of credits. This was concerning because I had only loaded GMI with $20, and I was hoping it would last a month. I was also periodically getting rate limited before hitting the spending cap because I was in the lowest tier. So I added $30 to bring me to the next tier and keep going. Coding with AI feels like gambling with real money in exchange for work I can't even be sure is any good.

I thought maybe I messed up caching somewhere. But I was too lazy to look into it because this was just a small experiment. I ended up spending about $42 in total for this session, including one round of Copilot reviews. I actually pulled in Opus at one point to evaluate the entire stack of 10 PRs, and had it send back some surgical fixes for some P0/P1 bugs.

I was impressed with it. The refactor worked. Cleaned up a lot of dead code. Added some nice new features I didn't think about. But the cost was still concerning. I found a Reddit post titled ["I burned through 19M tokens of GLM-5.2 for under $3."](https://www.reddit.com/r/opencodeCLI/comments/1u8l3qb/i_burned_through_19m_tokens_of_glm52_for_under_3/) Nineteen million tokens, under three dollars. I'd just spent $42 to do a fraction of that. So now I know it was entirely my own skill issue.

## Neuralwatt, and getting it into pi

OP of the post sang praises for [Neuralwatt](https://portal.neuralwatt.com/auth/register?ref=NW-PANAT-JWVC), which serves the same family of open models and prices cached input at a quarter of the fresh rate. Neuralwatt provides energy-based pricing as an alternative to token-based pricing, which is way cheaper for broke solo devs like me.

Feeling good about it, I decided to get Neuralwatt working in pi. Pi has a clean extension system, so a provider is a small TypeScript file that registers itself at startup. I had Claude Code Opus write this extension and it one-shotted it. One file dropped in `~/.pi/agent/extensions/`:

```ts
// ~/.pi/agent/extensions/neuralwatt.ts
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerProvider("neuralwatt", {
    baseUrl: "https://api.neuralwatt.com/v1",
    apiKey: "$NEURALWATT_API_KEY",
    api: "openai-completions",
    models: [
      {
        id: "glm-5.2",
        name: "GLM-5.2 (NeuralWatt)",
        reasoning: true,
        input: ["text"],
        contextWindow: 1048560,
        cost: { input: 1.45, output: 4.5, cacheRead: 0.3625, cacheWrite: 0 },
        thinkingLevelMap: { off: null, minimal: "minimal", low: "minimal", medium: "high", high: "high", xhigh: "max" },
      },
    ],
  });
}
```

Pi is cool, but if I were to use it as a daily driver with GLM-5.2, I needed more.

## The omp rabbit hole

[Oh-my-pi](https://omp.sh/) (omp) is a heavily modified fork of pi, batteries included like Oh My Zsh for zsh. A setting that lives in a TypeScript extension in pi lives in a YAML file with a different schema in omp, so naturally I had Claude Code port it over. Neither pi nor omp ships Neuralwatt, so each one wants the model defined.

I wanted Neuralwatt's real context limit and price, so I read their `/v1/models` endpoint directly.

Then the trap. Omp turns off reasoning for that whole family of models, on the theory that Zhipu and Z.ai models don't support the standard knob for it. Neuralwatt's GLM-5.2 does. The fix is two lines:

```yaml
# ~/.omp/agent/models.yml
providers:
  neuralwatt:
    baseUrl: https://api.neuralwatt.com/v1
    apiKey: NEURALWATT_API_KEY   # env var name, resolved at runtime
    api: openai-completions
    models:
      - id: glm-5.2
        contextWindow: 1048560
        cost: { input: 1.45, output: 4.5, cacheRead: 0.3625 }
        compat:
          # omp defaults reasoning_effort OFF for Zhipu/Z.ai models.
          supportsReasoningEffort: true
          reasoningEffortMap: { xhigh: max, high: high, minimal: minimal }
```

## Plumbing and metering

People use Codex and Claude Code because it's so easy to set up. You sign up for an account and it works. But if you're resource-constrained like me and my silly bookstore operation, you gotta find ways to save money. I didn't want to sit around and wait for OpenCode or pi to natively support Neuralwatt and GLM-5.2.

Every day software engineering feels closer to working in a kitchen. Mise en place. Set up your stations, know your ingredients, taste as you go. You don't turn on the oven, leave the house, and hope for the best. But you can get a [WiFi-connected sous-vide machine](https://anovaculinary.com/products/anova-precision-cooker-3) and remotely monitor your ribeye while going for a walk. Before Claude Code supported remote sessions, I was already using [Termius](https://termius.com/index.html) on my phone to SSH onto my hosts via Tailscale.

A lot of this chaos is temporary. Open-weight models keep getting more and more impressive. Are they likely distilled from frontier models? Without a doubt. But don't frontier labs also distill from the entirety of human knowledge? For the benefit of humanity, I want open models to succeed. But I am still uneasy about high-capability open models falling into the hands of bad actors. Presumably this is the entire worldview of Anthropic.

For now, GLM-5.2 runs through Neuralwatt, the bill is so negligible I can ignore it like my Netflix subscription, and I'm back to losing at Magic while a stack of PRs builds itself in the background. I still read every line before it merges. Every kitchen needs a chef.
