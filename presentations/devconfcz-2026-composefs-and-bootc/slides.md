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

- Security
- OSTree -> composefs!
- Control of local mutable state

---

## Threat scenarios

- Attacker with physical access to block device of non-booted (or locked) system ("Evil maid")
- Confidental computing (can change live block device)

---

## composefs

- Verified storage is hard
- partition dm-verity has logistic constraints
- loopback-mounted dm-verity is not efficient
- And impedance mismatch between dm-verity and OCI containers

---

## composefs ecosystem

- 3 big parts: (metadata-only) EROFS + overlayfs + fsverity
- Any backing Linux filesystem you want with whatever block device you want (plain ext4, btrfs, XFS on LUKS, dm-crypt, RAID, ...)
- github.com/composefs is C impl, github.com/composefs/composefs-rs is Rust (taking over C impl)
- Rust impl also much higher level, has opinionated OCI, also initramfs handling.
- Also part of CNCF

---

## Architecture of a composefs image

<img src="assets/composefs.svg"/>

## Architecture of a composefs repo

- Holds multiple images (metadata EROFS)
- Object store for shared backing files named by fsverity digest

---

## Building your own sealed UKI RHEL Image Mode

- <https://github.com/redhat-cop/rhel-bootc-examples/tree/main/sealing>
- Let's dive in!

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
- This computation is faster and more efficient now!

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

## Ingredient: bcvk - local qemu+libvirt with bootable containers

- Neato tool if I do say so myself (and I just did!)
- `bcvk libvirt run` conveniently wraps `bootc install` to qcow2 + launch libvirt
- Supports being passed secure boot keys

---

## Demo!

- Walkthrough of build and booted system

---

## What's next?

- ✅ Reimplementing composefs v1 format in Rust: predictable digests
- ✅ On disk format stable
- varlink APIs (in progress)
- Eventually replacing the C composefs implementation
- composefs-rs 1.0 (soon!)
- bootc: Unified storage
- 🆒 Generic sealed (non-bootable) container images
