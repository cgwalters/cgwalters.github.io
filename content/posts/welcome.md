---
title: "Why bootc doesn't require \"/usr merge\""
date: 2024-10-22
draft: false
summary: "How bootc provides a practical approach to immutability without requiring /usr merge"
---

*Originally posted at [blog.verbum.org](https://blog.verbum.org/2024/10/22/why-bootc-doesnt-require-usr-merge/)*

The systemd docs talk about [UsrMerge](https://systemd.io/THE_CASE_FOR_THE_USR_MERGE/), and while [bootc](https://github.com/containers/bootc) works nicely with this, it does not require it and never will. In this blog we'll touch on the rationale for that a bit.

The first stumbling block is pretty simple: For many people shipping "/usr merge" systems, a lot of backwards compatibility symlinks are required, like `/bin` → `/usr/bin` etc. Those symbolic links are pretty load bearing, and we really want them to also not just be sitting there as random mutable state.

This problem domain really scope creeps into "how does / (aka the root filesystem)" work?

There are multiple valid models; one that is viable for many use cases is where it's ephemeral (i.e. a `tmpfs`) as encouraged by things like `systemd-volatile-root`. One thing I don't like about that is that `/` is just sitting there mutable, given how important those symlinks are. It clashes a bit with things like wanting to ensure all read files are only from verity-protected paths and things like that. These things are closer to quibbles though, and I'm sure some folks are successfully shipping systems where they don't have those compatibility symlinks at all.

The bigger problem though is all the things that never did "/usr move", such as `/opt`. And for many things in there we actually really do want it to be read-only at runtime (and more generally, versioned with the operating system content).

Finally, `/opt` is just a symptom of a much larger issue that there's no "/usr merge" requirement for building application containers (docker/podman/kube style) and a toplevel, explicit goal of bootc is to be compatible with that world.

It's for these reasons that while historically the [ostree project](https://github.com/ostreedev/ostree/) encouraged "/usr merge", it never required it and in fact the default `/` is versioned with the operating system – defining `/etc` and `/var` as the places to have persistent machine-local state.

With bootc, using [composefs](https://github.com/containers/composefs) we have a strong and consistent story for immutability that applies to the whole root, whether it's `/usr` or `/opt` or other toplevel directories. I hope it will make it easier for people to adopt image-based systems!
