---
marp: true
theme: gaia
paginate: true
title: Hardening Operating System Distribution: Verifiable and sealed OS with bootc and composefs
---

# Hardening Operating System Distribution: Verifiable and sealed OS with bootc and composefs

Devconf.cz 2026
Colin Walters, Red Hat

---

## Agenda

- Why: Operating system security
- What is composefs, the last ~year of development
- Demo of RHEL 10.2 as sealed "only state you want" system
- What's next?

---

## Computers: oops

- We invented computers, now we need to keep them updated and secure
- Operating system is at the nexus
  - OS vs 3rd party apps, major versions, attack surface
  - Mutable vs "immutable" (controlled state)

---

## Threat scenarios

- Attacker with physical access to block device of non-booted (or locked) system ("Evil maid")
- Confidental computing (can change live block device)

---

## Why composefs

- Verified storage is hard
- partition dm-verity has logistical issues, loopback-mounted dm-verity is not efficient
- And impedance mismatch between dm-verity and OCI containers
- composefs: Shared storage on disk and in page cache, automatic dedup

---

## composefs ingredients

- 3 big parts: (metadata-only) EROFS + overlayfs + fsverity
- Any backing Linux filesystem you want with whatever block device you want (plain ext4, btrfs, XFS on LUKS, dm-crypt, RAID, ...)
- In a nutshell: verified storage independent of (lower) filesystem and block

---

## Architecture of a composefs image + repo

<img src="assets/composefs.svg"/>

## Architecture of a composefs repo

- Holds multiple images (metadata EROFS)
- Object store for shared backing files named by fsverity digest

---

## composefs implementations and ecosystem

- <https://github.com/composefs/composefs> is C impl, <https://github.com/composefs/composefs-rs> is Rust (taking over C impl)
- Rust impl also much higher level, has opinionated OCI, also initramfs handling.
- Also part of CNCF

---

## Where is composefs used?

- bootc
- [rauc.io](https://rauc.io)
- podman (optionally, ~experimental)
- Lots of custom/private things we mainly see because of bug reports/features
  - e.g. I realized we need a build of bootc without ostree support
---

## Building your own sealed UKI RHEL Image Mode

- <https://github.com/redhat-cop/rhel-bootc-examples/tree/main/sealing>
- Let's dive in!
- (Quick shell command)

---

## Ingredient: Your own Secure Boot keys

- `just keygen` wraps python script running openssl; some small tweaks here
- Standin for e.g. HSM in production
- Stock general purpose OS boot chain: Microsoft signs shim, which trusts other keys for Fedora, Debian, RHEL etc.
- *Important*: Firmware must have your key enrolled (out of band or interactively via e.g. systemd-boot)
- That said, we are also working to support shim-based flows

---

## Ingredient: Multi-stage container build

- Uses stock rhel-bootc container image as builder
- Generate "from scratch" rootfs (your arbitrary content)
- Also takes Secure Boot keys as input to sign systemd-boot and a UKI
- And all of that together is placed into a single OCI image

---

## Ingredient: UKI and bootc+composefs

- Unified Kernel Images are a standard created by systemd project
- `bootc container ukify`: Wraps `ukify` to handle composefs digest injection
- But that mostly defers to composefs
- 🆕 This computation is a lot faster and more efficient now!

---

## Aside: Wait how does this work

- A container image that has its own digest? Is it a "Hashquine"?

<img src="assets/rogdham_gif_md5_hashquine.gif"/>

- No, the trick is: `bootc container ukify` omits `/boot` where the UKI goes

---

## Ingredient: bootc

- `bootc` wraps composefs-rs for both install and upgrade
- OCI image is fetched, we convert tar layers into composefs object store and synthesize the EROFS
- Note: exact reproducible mapping from OCI tar -> EROFS is required!
- `bootc install to-filesystem` and `bootc upgrade` copies the embedded UKI to ESP

---

## Ingredient: Configuring bootc state

Achieve: "Stateless except OS upgrades"

```
$ cat /usr/lib/composefs/setup-root-conf.toml
[etc]
mount = "transient"
[var]
mount = "none"
$ cat /usr/lib/bootc/kargs.d/50-var-volatile.toml
kargs = ["systemd.volatile=state"]
$
```

---

## Ingredient: bcvk - local qemu+libvirt with bootable containers

- Neato tool if I do say so myself (and I just did!)
- `bcvk ephemeral` helps bootstrap persistent installs
- `bcvk libvirt run` conveniently wraps `bootc install` to qcow2 + launch libvirt
- Supports being passed secure boot keys

---

## More Demo

- bootctl + looking at composefs repo etc

---

## You want more?

- ✅ Reimplementing composefs v1 format in Rust: predictable digests
- ✅ On disk format stable
- varlink APIs (in progress)
- Eventually replacing the C composefs implementation
- composefs-rs 1.0 (soon!)

---

## And even more?

- bootc: Unified storage
- 🆒 Generic sealed (non-bootable) container images

---

## Links and thanks!

- <https://github.com/redhat-cop/rhel-bootc-examples>
- <https://github.com/composefs/composefs-rs/>
- <https://bootc.dev>
- Thank you!