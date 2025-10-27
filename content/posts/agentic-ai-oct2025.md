---
title: "Thoughts on agentic AI coding as of Oct 2025"
date: 2025-10-27
draft: false
summary: Reflections on sandboxing, parallel agents, human review, and credential management for AI-assisted coding.
---

# Sandboxed, reviewed parallel agents make sense

For coding and software engineering, I've used and experimented with various
frontends (FOSS and proprietary) to multiple foundation models
(mostly proprietary)  trying to keep up with the state of the art.
I've come to strongly believe in a few things:

- Agentic AI for coding needs strongly sandboxed, reproducible environments
- It makes sense to run multiple agents at once
- AI output definitely needs human review

## Why human review is necessary

### Prompt injection is a serious risk at scale

All AI is at risk of [prompt injection](https://simonwillison.net/2025/Jun/13/prompt-injection-design-patterns/)
to some degree, but it's particularly dangerous with agentic coding. All the state of the art
today knows how to do is mitigate it at best. I don't think it's a reason
to avoid AI, but it's one of the top reasons to use AI thoughtfully and
carefully for products that have any level of criticality.

[OpenAI's Codex documentation](https://developers.openai.com/codex/cloud/internet-access#risks-of-agent-internet-access)
has a simple and good example of this.

### Disabling the tests and claiming success

Beyond that, I've experienced multiple times different models happily
disabling the tests or adding a `println!("TODO add testing here")` and
claim success. At least this one is easier to mitigate with a second
agent doing code review before it gets to human review.

## Sandboxing

The "can I do X" prompting model that various interfaces default to is
seriously flawed. Anthropic has a [recent blog post on Claude Code changes](https://www.anthropic.com/engineering/claude-code-sandboxing)
in this area.

My take here is that sandboxing is only part of the problem; the
other part is ensuring the agent has a reproducible environment,
and especially one that can be run in IaaS environments. I think
[devcontainers](https://containers.dev/) are a good fit.

I don't agree with the statement from Anthropic's blog

> without the overhead of spinning up and managing a container. 

I don't think this is overhead for most projects.
Where it feels like it has overhead,
we should be working to mitigate it.

### Running code as separate login users

In fact, one thing I think we should popularize more on Linux
is the concept of running multiple unprivileged login users.
Personally for the tasks *I* work on, it often involves building
containers or launching local VMs, and isolating that works
really well with a full separate "user" identity. An experiment
I did was basically `useradd ai` and running delegated tasks
there instead. To log in I added

```
%wheel  ALL=NOPASSWD: /usr/bin/machinectl shell ai@
```

to `/etc/sudoers.d/ai-login` so that my regular human
user could easily get a shell in the `ai` user's context.

I haven't truly "operationalized" this one as juggling separate
git repository clones was a bit painful, but I think I could
automate it more. I'm interested in hearing from folks
who are doing something similar.

## Parallel, IaaS-ready agents...with review

I'm today often running 2-3 agents in parallel on different tasks
(with different levels of success, but that's its own story).

It makes total sense to support delegating some of these agents
to work off my local system and into cloud infrastructure.

In looking around in this space, there's quite a lot of stuff.
One of them is [Ona](https://ona.com/) (formerly Gitpod). I
gave it a quick try and I like where they're going, but more on this
below.

[Github Copilot](https://github.com/features/copilot) can also do something similar to this, but
what I don't like about it is that it pushes a model
where all of one's interaction is in the PR. That's going
to be seriously noisy for some repositories, and interaction
with LLMs can feel too "personal" sometimes to have permanently
recorded.

## Credentials should be on demand and fine grained for tasks

To me a huge flaw with Ona and one shared with other things like
[Langchain Open-SWE](https://github.com/langchain-ai/open-swe) is
basically this:

![Ona permissions](/ona-permissions.png)

Sorry but: no way I'm clicking OK on that button. I need a strong and clearly
delineated barrier between tooling/AI agents acting "as me"
and *my* ability to approve and push code
or even do basic things like edit existing pull requests.

Github's Copilot gets this more right because its bot runs as
a distinct identity. I haven't dug into what it's authorized
to do. I may play with it more, but I also want to use agents
outside of Github and I also am not a fan of deepening dependence
on a single proprietary forge either.

So I think a key thing agent frontends should help do here
is in granting fine-grained ephemeral credentials for dedicated write access
as an agent is working on a task. This "credential handling"
should be a clearly distinct component. (This goes beyond just
git forges of course but also other issue trackers or data
sources that may be in context).

## Conclusion

There's so much out there on this, I can barely keep track
while trying to do my real job. I'm sure I'm not alone -
but I'm interested in others' thoughts on this! Feel
free to comment in an issue on this site.
