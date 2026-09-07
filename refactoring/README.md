# NixOS Architecture Refactoring & Database-Driven Framework Roadmap

## 1. Executive Summary

This directory contains the in-depth architectural audit, criticality analysis, and engineering tickets for modernizing this NixOS configuration.

The ultimate objective is to combine:
1. **The benefits of a centralized, transactional database** (inspired by package managers like Arch Linux's `pacman` / ALPM):
   - A single source of truth (SSOT).
   - Clear distinction between explicitly installed packages (`--asexplicit`) and dependencies/system infrastructure (`--asdeps`).
   - Zero duplication and zero split-brain ambiguity across targets (system vs. user).
   - Fast, unified inspection and querying (`pacman -Qe`, `pacman -Qi`).
2. **The reproducibility and isolation of NixOS and Home Manager**:
   - Pure declarative configuration and atomic generational rollbacks.
   - Derivation hashing and store isolation.
   - Protection of mutable user dotfiles (`~/.config`) from uncoordinated clobbering.

---

## 2. Taxonomy of Identified Criticalities

A comprehensive audit of the active repository (`/etc/nixos` / `/home/luigi/nixos`) revealed 6 primary areas of criticality:

```mermaid
graph TD
    subgraph Criticalities ["Identified Criticalities"]
        C1["Split-Brain Package Placement<br/>(System vs Home Manager)"]
        C2["Fragile Regex Scripts<br/>(sed-based mutation, broken HM assumptions)"]
        C3["Hardcoded Paths & Portability<br/>(/etc/nixos, /home/luigi, sessionPath)"]
        C4["Theming Split-Brain & Out-of-Band State<br/>(theme.nix vs KDE/GTK & LazyVim cloning)"]
        C5["Dotfile Conflicts & Mutable State Leakage<br/>(backup collisions, KDE Plasma runtime files)"]
        C6["Lack of Unified Registry<br/>(Scattered lists across 6+ files)"]
    end

    subgraph Solution ["The Proposed 'Pacman-Like' Framework (pacnix / nix-db)"]
        DB[("Centralized Database / Manifest<br/>(SSOT: Packages, Scopes, Metadata)")]
        CLI["pacnix CLI<br/>(Query, Audit, Add, Remove)"]
        GEN["Generator / Pure Nix Evaluator<br/>(Deduplication & Validation Engine)"]
        OUT["Compiled NixOS & Home Manager Configuration"]
    end

    C1 & C2 & C3 & C4 & C5 & C6 --> DB
    DB --> CLI
    CLI --> GEN
    GEN --> OUT
```

| Area | Severity | Core Issue | Real-world Impact |
| :--- | :---: | :--- | :--- |
| **Package Placement & Deduplication** | **HIGH** | Packages are arbitrarily split between `environment.systemPackages` (in 3 different files) and Home Manager (`home.packages` and `programs.*`). | Ghost packages, duplicate package instances in evaluation (`spectacle`, `bluedevil`, `man-db`, `zsh`), and missing tools in root (e.g., `git` missing while `gh` is installed). |
| **Imperative Scaffolding Scripts** | **CRITICAL** | `add-program.sh` uses regex `sed -i` to mutate files and assumes *every* package is a `programs.<name>` Home Manager module. | Running `add-program ripgrep` or `add-program gimp` corrupts Nix files or creates non-existent options, breaking `nixos-rebuild switch`. |
| **Path Hardcoding & Portability** | **MEDIUM-HIGH** | Absolute paths (`/etc/nixos`, `/home/luigi`) hardcoded across 8 different files and shell aliases. | Repository cannot be evaluated in alternative directories, on other machines, or during automated test/CI pipelines. |
| **Theming & Out-of-Band State** | **MEDIUM** | `theme.nix` is an untyped ad-hoc import affecting only 4 terminal tools. Neovim's LazyVim imperatively downloads plugins at runtime. | Switching themes desynchronizes the desktop (Plasma stays light/dark while terminal switches); Neovim violates Nix purity and breaks offline. |
| **Home Dotfiles & Mutable State** | **HIGH** | Home Manager's `.backup` strategy collides with KDE Plasma 6 writing directly to `~/.config`. | Risk of rebuild failures, clobbered runtime settings, or runaway `.backup` files. |
| **Centralization & Queryability** | **HIGH** | No unified way to inspect installed software, reason for installation, or ownership. | Configuration drift, lost visibility of system state, and lack of dependency hygiene. |

---

## 3. Index of Refactoring Tickets

The tickets in this directory are organized as self-contained engineering specifications:

| Ticket ID | Title | Focus Area | Status |
| :--- | :--- | :--- | :---: |
| [**TICKET-001**](./TICKET-001-audit-split-brain-and-package-duplication.md) | **Audit: System vs. User Package Placement & Record Duplication** | Eliminating package overlap, resolving `vim`/`neovim` shadowing, and establishing clear target boundaries. | **RESOLVED** |
| [**TICKET-002**](./TICKET-002-fragile-scripting-and-sed-mutation.md) | **Criticality: Destructive Regex Scripts & Broken Module Assumptions** | Decommissioning `sed -i` bash scripts, fixing the invalid `programs.<name>` assumption, and preventing dirty git commits. | **RESOLVED** |
| [**TICKET-003**](./TICKET-003-hardcoded-paths-and-portability.md) | **Criticality: Hardcoded Paths, Shell Aliases & Scalability** | Replacing hardcoded `/etc/nixos` with relative flake paths, dynamic environment variables, and multi-host readiness. | **RESOLVED** |
| [**TICKET-004**](./TICKET-004-split-brain-theming-and-desktop-state.md) | **Criticality: Theming Split-Brain & Neovim Out-of-Band State** | Unifying system and desktop theming with Stylix / Nix modules, and removing phantom Lua configs and runtime git cloning. | **RESOLVED** |
| [**TICKET-005**](./TICKET-005-home-managed-dotfiles-and-mutable-leakage.md) | **Criticality: Home Dotfile Management & Plasma 6 State Leakage** | Establishing clear boundaries between immutable Nix store links, managed mutable defaults, and unmanaged runtime caches. | **RESOLVED** |
| [**TICKET-006**](./TICKET-006-unified-database-architecture-rfc.md) | **RFC: The "Pacman Database" Architecture for NixOS** | Full architectural specification for a centralized registry, schema definitions, deduplication engine, and compiler pipeline. | **ADOPTED** |
| [**TICKET-007**](./TICKET-007-prototype-cli-and-migration-path.md) | **Framework Specification: `pacnix` CLI & Phased Migration Plan** | Detailed CLI design (`pacnix add`, `remove`, `query`, `audit`, `sync`), Python/Rust generator prototype, and 4-phase rollout plan. | **OPERATIONAL** |

---

## 4. Phased Implementation Roadmap

```mermaid
gantt
    title NixOS Modernization & Framework Implementation Roadmap
    dateFormat  YYYY-MM-DD
    section Phase 1: Stabilization & Sanitation
    Decommission sed scripts (TICKET-002)         :done,    p1_1, 2026-09-07, 3d
    Purge duplicate packages & fix vim (TICKET-001) :active,  p1_2, after p1_1, 3d
    Parameterize paths & flake root (TICKET-003)    :         p1_3, after p1_2, 2d
    section Phase 2: Dotfiles & Theming
    Formalize theme module (TICKET-004)            :         p2_1, after p1_3, 4d
    Isolate Plasma 6 state & HM dotfiles (TICKET-005):       p2_2, after p2_1, 4d
    section Phase 3: Database & Engine
    Define SSOT Manifest Schema (TICKET-006)        :         p3_1, after p2_2, 5d
    Build pacnix CLI & Generator (TICKET-007)       :         p3_2, after p3_1, 7d
    section Phase 4: Full Cutover
    Migrate software modules into DB (TICKET-007)   :         p4_1, after p3_2, 4d
    Verify multi-host & multi-user builds           :         p4_2, after p4_1, 3d
```

To begin reviewing, proceed to [TICKET-001](./TICKET-001-audit-split-brain-and-package-duplication.md).
