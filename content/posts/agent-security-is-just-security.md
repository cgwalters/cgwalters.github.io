---
title: "Agent security is just security"
date: 2026-03-23
draft: false
summary: Don't use or invent new things specific to agents
---

Suddenly I have been hearing the term Landlock more in (agent) security
circles. To me this is a bit weird because while [Landlock](https://landlock.io)
is absolutely a useful Linux security tool, it's been a bit obscure
and that's for good reason. It feels to me a lot like the how weird
[prevalence of the word delve](https://arxiv.org/html/2412.11385v1)
became a clear tipoff that LLMs were the ones writing, not a human.

Here's my opinion: *Agentic LLM AI security is just security* 

We do not need to reinvent any fundamental technologies for this. Most uses of
agents one hears about provide the ability to execute arbitrary code as a feature.
It's how OpenCode, Claude Code, Cursor, OpenClaw and many more work.

Especially let me emphasize since OpenClaw is popular for some reason
right now: You should *absolutely not* give any LLM tool blanket read *and write*
access to your full user account on your computer. There are many issues with that, but
everyone using an LLM needs to understand just how dangerous
[prompt injection](https://simonwillison.net/tags/prompt-injection/) can be.
[This post](https://simonwillison.net/2026/Mar/18/) is just one of many
examples. Even global read access is dangerous because an attacker
could exfiltrate your browser cookies or other files.

Let's go back to Landlock - one prominent place I've seen it
mentioned is in this project `nono.sh` pitches itself as a new sandbox for agents.
It's not the only one, but indeed it heavily leans on Landlock on Linux.
Let's dig into [this blog post](https://alwaysfurther.ai/blog/why-i-built-nono)
from the author. First of all, I'm glad they are working on agentic
security. We both agree: unsandboxed OpenClaw (and other tools!) is a bad idea.

Here's where we disagree:

> With AI agents, the core issue is access without boundaries. We give agents our full filesystem permissions because that's how Unix works. We give them network access because they need to call APIs. We give them access to our SSH keys, our cloud credentials, our shell history, our browser cookies - not because they need any of that, but because we haven't built the tooling to say "you can have this, but not that."

No. We have had usable tooling for "you can have this, but not that"
for well over a decade. Docker kicked off a revolution for a reason:
`docker run <app>` is "reasonably completely isolated" from the host system.
Since then of course, there's many OCI runtime implementations,
from [podman](https://podman.io) to [apple/container](https://github.com/apple/container) on MacOS
and more.

If you want to provide the app some credentials, you can just
use bind mounts to provide them like `docker|podman|ctr -v ~/.config/somecred.json:/etc/cred.json:ro`.
Notice there the `ro` which makes it readonly. Yes, it's
that straightforward to have "this but not that".

Other tools like [Flatpak](https://flatpak.org) on Linux
have leveraged Linux kernel namespacing similar to this
to streamline running GUI apps in an isolated way
from the host. For a decade.

There's far more sophisticated tooling built on top
of similar container runtimes since then, from
having them transparently backed by virtual machines,
Kubernetes and similar projects are all about running
containers at scale with lots of built up security
knowledge.

That doesn't need reinventing. It's generic workload
technology, and agentic AI is just another workload
from the perspective of kernel/host level isolation.
There absolutely are some new, novel risks and issues
of course: but again the core principle here is
we don't need to reinvent anything from the kernel level up.

Security here really needs to start from defaulting
to *fully* isolating (from the host and other apps),
and then only allow-listing in what is needed. That's again how
`docker run` worked from the start. Also on this topic,
[Flatpak portals](https://docs.flatpak.org/en/latest/basic-concepts.html#portals)
are a cool technology for dynamic resource access on a single
host system.

So why do I think Landlock is obscure? Basically
because *most* workloads should already be isolated already
per above, and Landlock has *heavy* overlap with the wide
variety of Linux kernel security mechanisms already in
use in containers.

The primary pitch of Landlock is more for an *application* to
further isolate itself - it's at its best when it's a *complement*
coarse-grained isolation techniques like virtualization or containers.
One way to think of it is that often container runtimes don't
grant privileges needed for an application to further spawn
its own sub-containers (for kernel attack surface reasons), but
Landlock is absolutely a reasonable thing for an app to use
to e.g. disable networking from a sub-process that doesn't need
it, etc.

Of course the challenge is that not every app is easy to run
in a container or virtual machine. Some workloads are most
convenient with that "ambient access" to all of your data
(like an IDE or just a file browser).

But giving that ambient access by default to agentic AI is a terrible
idea. So don't do it: use (OCI) containers and allowlist in
what you need.

(There's other things nono is doing here that I find
 dubious/duplicative; for example I don't see the need for
 a new filesystem snapshotting system when we have both git and OCI)

But I'm not specifially trying to pick on nono - just in the last
two weeks I had to point out similar problems in *two* different projects
I saw go by also pitched for AI security. One used bubblewrap,
but with insufficient sandboxing, and the other was also trying
to use Landlock.

On the other hand, I do think the credential problem (that nono and others are
trying to address in differnet ways) is somewhat specific
to agentic AI, and likely does need new tooling.
When deploying a typical containerized
app usually one just provisions a few relatively static
credentials. In contrast, developer/user agentic AI is often a lot
more freeform and dynamic, and while it's hard to
get most apps to leak credentials without completely compromising
it, it's much easier with agentic AI and prompt injection.
I have thoughts on credentials, and absolutely more work
here is needed.

It's great that people want to work on FOSS security, and AI
could certainly use more people thinking about security.
But I don't think we need "next generation" security here:
we should build on top of the "previous generation".
I actually use plain separate Unix users for isolation for some things, which
works quite well! Running OpenShell in a *secondary* user account
where one only logs into a select few things (i.e. not your email and online banking)
is much more reasonable, although clearly a lot of care is still needed.
Landlock is a fine technology but is just not there as
a *replacement* for other sandboxing techniques. So just use 
containers and virtual machines because these are proven technologies. 
And if you take one message away from this: absolutely don't wire up an LLM
via OpenShell or a similar unsandboxed tool to your complete digital life with
no sandboxing.
