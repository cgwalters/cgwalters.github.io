---
marp: true
theme: default
paginate: true
title: Hardening Operating System Distribution: Verifiable and sealed OS with bootc and composefs
---

# Hardening Operating System Distribution: Verifiable and sealed OS with bootc and composefs

Devconf.cz 2026
Colin Walters, Red Hat

---

## Background

- OSTree -> composefs!
- Integrity is important
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
- And impedance mismatch between dm-verity and containers

## composefs

- EROFS
- overlayfs
- fsverity
- Any backing Linux filesystem you want with whatever block device you want (plain ext4, btrfs, XFS on LUKS, dm-crypt, RAID, ...)

## Architecture

```mermaid
flowchart TD
    subgraph Mount_Point [mount point]
        
        subgraph EROFS [EROFS with metadata]
            usr --> bin
            bin --> bash["bash 🔒"]
        end

        subgraph OverlayFS [overlayfs data only layer]
            O_Root["/"] --> O_Dir[a3]
            O_Dir --> O_File1["002183fb91... 🔒"]
            O_Dir --> O_File2["ff9d7bd692... 🔒"]
        end
        
    end

    subgraph ComposeFS_Repo [composefs repository]
        RepoID["a3002183fb91..."]
        Objects[objects]
        Images["/composefs/images"]
        
        RepoID --- Objects
        Objects --- Images
        
        Images --> I_Root["/"]
        I_Root --> I_Dir[a3]
        I_Dir --> I_File1["002183fb91... 🔒"]
        I_Dir --> I_File2["ff9d7bd692... 🔒"]
    end

    bash -.->|"trusted.overlay.redirect\n(extended attribute)"| O_File1
    O_File1 -.->|"fs-verity digest in\ntrusted.overlay.metacopy\nextended attribute 🔒"| I_File1

    classDef locked fill:#f9f9f9,stroke:#333,stroke-width:2px;
    class bash,O_File1,O_File2,I_File1,I_File2 locked;
```

---

## Building your own

- <https://github.com/redhat-cop/rhel-bootc-examples/tree/main/sealing>

## Demo!

- Walkthrough of build and booted system

---

## Understanding use cases and security

- Full disk LUKS *just works*
- Can also use dm-integrity

---

## What's next?

- composefs-rs 1.0
- Reimplementing composefs v1 format in Rust: predictable digests
- On disk format stable
- Eventually replacing the C composefs implementation
- varlink APIs