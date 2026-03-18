---
title: "LLMs and core software: human driven"
date: 2026-03-18
draft: false
summary: Agentic AI should be controlled by humans
---

It's clear LLMs are one of the biggest changes in technology ever. The rate
of progress is astounding: recently due to a configuration mistake
I accidentally used Claude Sonnet 3.5 (released ~2 years ago)
instead of Opus 4.6 for a task and looked at the output and thought "what is
this garbage"? 

But daily now: Opus 4.6 is able to generate reasonable PoC level Rust
code for complex tasks for me. It's not perfect - it's a combination
of exhausting and exhilarating to find the 10% absolutely bonkers/broken
code that still makes it past subagents.

So yes I use LLMs every day, but I will be clear: if I could push a button
to "un-invent" them I *absolutely* would because I think the long term
issues in larger society (not being able to trust any media, and many
of the things from [Dario's recent blog](https://www.darioamodei.com/essay/the-adolescence-of-technology) etc.)
will outweigh the benefits.

But since we can't un-invent them: here's my opinion on how they should be
used. As a baseline, I agree with a lot from [this doc from Oxide about LLMs](https://rfd.shared.oxide.computer/rfd/0576).
What I want to talk about is especially around some of the norms/tools
that I see as important for LLM use, following principles similar to those.

On framing: there's "core" software vs "bespoke". An entirely new
capability of course is for e.g. a nontechnical restaurant owner to
use an LLM to generate ("vibe code") a website (excepting hopefully online
orderings and payments!). I'm not overly concerned about this.

Whereas "core" software is what organizations/businesses provide/maintain
for others. I work for a company (Red Hat) that produces a lot of this.
I am sure no one would want to run for real an operating system, cluster filesystem,
web browser, monitoring system etc. that was primarily "vibe coded".

And while I respect people and groups that are trying to entirely ban LLM
use, I don't think that's viable for at least my space.

Hence the subject of this blog is my perspective on how LLMs should be used
for "core" software: not vibe coding, but using LLMs responsibly and
intelligently - and always under human control and review.

## Agents should amplify and be controlled by humans

I think most of the industry would agree we can't give responsibility
to LLMs. That means they must be overseen by humans. If they're
overseen by a human, then I think they should be *amplifying*
what that human thinks/does as a baseline - intersected with
the constraints of the task of course.

On "amplification": Everyone using a LLM to generate content should inject their own
system prompt (e.g. [AGENTS.md](https://agents.md/)) or equivalent.
[Here's mine](https://github.com/cgwalters/homegit/blob/main/dotfiles/.config/AGENTS.md) - notice
I turn off all the emoji etc. and try hard to tune down bulleted lists
because that's not my style. This is a truly baseline thing to do.

Now most LLM generated content targeted for core software is
still going to need review, but just ensuring that the baseline
matches what the human does helps ensure alignment.

## Pull request reviews

Let's focus on a very classic problem: pull request reviews. Many
projects have wired up a flow such that when a PR comes in,
it gets reviewed by a model automatically. Many projects and
tools pitch this. We use one on some of my projects.

But I want to get away from this because in my experience these
reviews are a combination of:

- Extremely insightful and correct things (there's some amazing
  fine-tuning and tool use that must have happened to find some
  issues pointed out by some of these)
- Annoying nitpicks that no one cares about (not handling spaces
  in a filename in a shell script used for tests)
- Broken stuff like getting confused by things that happened after its training cutoff
  (e.g. Gemini especially seems to get confused by referencing
   the current date, and also is unaware of newer Rust features, etc)

In practice, we just want the first of course.

How I think it should work:

- A pull request comes in
- It gets auto-assigned to a human on the team for review
- A human contributing to that project is running their own agents
  (wherever: could be local or in the cloud) *using their own configuration* (but of course
  still honoring the project's default development setup and the
  project's AGENTS.md etc)
- A new containerized/sandboxed agent may be spawned automatically,
  or perhaps the human needs to click a button to do so - or
  perhaps the human sees the PR come in and thinks "this one needs
  a deeper review, didn't we hit a perf issue with the database before?"
  and adds that to a prompt for the agent.
- The agent prepares a *draft* review that only the human can see.
- The human reviews/edits the draft PR review, and has the opportunity
  to remove confabulations, add their own content etc. And to send the agent back to look more closely
  at some code (i.e. this part can be a loop)
- When the human is happy they click the "submit review" button.
- Goal: it is 100% clear what parts are LLM generated vs human generated for the reader.

I wrote [this agent skill](https://github.com/bootc-dev/agent-skills/tree/main/perform-forge-review)
to try to make this work well, and if you search you can see it in action
in a few places, though I haven't truly tried to scale this up.

I think the above matches the vision of LLMs amplifying humans.

## Code Generation

There's no doubt that LLMs can be amazing code generators, and I use
them every day for that. But for any "core" software I work on,
I absolutely review all of the output - not just superficially,
and changes to core algorithms very closely.

At least in my experience the reality is still there's that percentage
of the time when the agent decided to reimplement base64 encoding
for no reason, or disable the tests claiming "the environment didn't support it"
etc.

And to me it's still a baseline for "core" software to require
another human review to merge (per above!) with their own customized
LLM assisting them (ideally a different model, etc).

## FOSS vs closed

Of course, my position here is biased a bit by working on FOSS - I
still very much believe in that, and working in a FOSS context can
be quite different than working in a "closed environment" where
a company/organization may reasonably want to (and be able to)
apply uniform rules across a codebase.

While for sure LLMs *allow* organizations to create their own
Linux kernel filesystems or bespoke Kubernetes forks or virtual
machine runtime or whatever - it's not clear to me that it
is a good idea for most to do so. I think shared (FOSS) infrastructure
that is productized by various companies, provided as a service
and maintained by human experts in that problem domain still makes sense.
And how we develop that matters a lot.


