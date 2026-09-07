# TICKET-001: Audit: System vs. User Package Placement, Duplicate Records & Conflicting Profiles

| Metadata | Details |
| :--- | :--- |
| **Ticket ID** | TICKET-001 |
| **Component** | Package Management / System & Home-Manager Configuration |
| **Severity** | High |
| **Impact** | Split-brain package locations, redundant store paths, CLI shadowing, and broken dependencies |
| **Status** | Resolved & Verified |

---

## 1. Problem Description

In the current NixOS repository, package declarations are fragmented across at least 6 distinct files:
- [modules/software/cli-tools.nix](file:///home/luigi/nixos/modules/software/cli-tools.nix)
- [modules/software/desktop-apps.nix](file:///home/luigi/nixos/modules/software/desktop-apps.nix)
- [modules/software/dev-tools.nix](file:///home/luigi/nixos/modules/software/dev-tools.nix)
- [modules/desktop/desktop.nix](file:///home/luigi/nixos/modules/desktop/desktop.nix)
- [users/luigi/home.nix](file:///home/luigi/nixos/users/luigi/home.nix)
- [users/luigi/programs/](file:///home/luigi/nixos/users/luigi/programs/)

This fragmentation has produced three critical failure modes:
1. **Split-Brain Placement**: Arbitrary distribution of packages between `environment.systemPackages` and `home-manager.users.luigi`.
2. **Duplicate Records & Store Paths**: Redundant package installations between explicit lists and desktop environment meta-packages.
3. **Shadowing and Asymmetric Environments**: CLI conflicts between system root and user shells.

---

## 2. In-Depth Audit Findings

### A. Split-Brain Software Placement
The official documentation in [docs/architecture-guide.md:41-42](file:///home/luigi/nixos/docs/architecture-guide.md#L41-L42) asserts:
> *"I programmi per l'utente finale non vengono installati globalmente, ma tramite Home Manager."*

However, actual inspection shows the exact opposite:
- **GUI applications** like `mpv`, `kcalc`, `falkon`, `spectacle`, `wofi`, and `wl-clipboard` are placed in [modules/software/desktop-apps.nix](file:///home/luigi/nixos/modules/software/desktop-apps.nix#L7-L15) under `environment.systemPackages`.
- **End-user terminal utilities** like `btop`, `eza`, `fzf`, `procs`, and `rename` are placed in [modules/software/cli-tools.nix](file:///home/luigi/nixos/modules/software/cli-tools.nix#L21-L30) under `environment.systemPackages`.
- Meanwhile, other user utilities like `bat` are isolated inside [users/luigi/programs/bat.nix](file:///home/luigi/nixos/users/luigi/programs/bat.nix) in Home Manager.
- Heavy developer tools (`nil`, `pyright`, `gcc`, `clang`, `rustc`, `cargo`, `nodejs`) are placed in [modules/software/dev-tools.nix](file:///home/luigi/nixos/modules/software/dev-tools.nix#L9-L77) under `environment.systemPackages`.

**Root Cause**: There is no authoritative registry or validation step enforcing where a package belongs. Decisions are made ad-hoc based on which file was opened by the user or script.

### B. Duplicate Package Installations & Redundant Declarations
When evaluating the full configuration closure, multiple packages appear repeatedly:
1. **`spectacle` and `bluedevil`**:
   - Explicitly listed in [modules/software/desktop-apps.nix:11,14](file:///home/luigi/nixos/modules/software/desktop-apps.nix#L11-L14).
   - Also automatically imported by `services.desktopManager.plasma6.enable = true` in [modules/desktop/desktop.nix:11](file:///home/luigi/nixos/modules/desktop/desktop.nix#L11).
2. **`zsh` and completions**:
   - Declared globally via `programs.zsh.enable = true;` in [modules/software/cli-tools.nix:49](file:///home/luigi/nixos/modules/software/cli-tools.nix#L49).
   - Declared in Home Manager via `programs.zsh.enable = true;` in [users/luigi/programs/zsh.nix:8](file:///home/luigi/nixos/users/luigi/programs/zsh.nix#L8).
   - Result: `zsh` and `nix-zsh-completions` exist both in the system profile and in the user profile closure.
3. **`man-db`**:
   - Pulled into systemPackages by NixOS core documentation settings.
   - Pulled into Home Manager profile by default user session settings.

### C. Shadowing & Profile Conflicts: The `vim` vs `neovim` Dilemma
- In [modules/software/cli-tools.nix:22](file:///home/luigi/nixos/modules/software/cli-tools.nix#L22): `pkgs.vim` is installed in `environment.systemPackages`.
- In [users/luigi/programs/neovim.nix:10-11](file:///home/luigi/nixos/users/luigi/programs/neovim.nix#L10-L11): `programs.neovim` is enabled with `viAlias = true; vimAlias = true;`.
- **Consequence**:
  - For user `luigi`, typing `vim` calls Neovim wrapper from `~/.nix-profile/bin`.
  - For user `root` (or in emergency rescue shells), typing `vim` calls classic Vim from `/run/current-system/sw/bin`.
  - Config files, plugins, and keybindings are completely divergent between the two.

### D. Asymmetric Developer Runtimes (`git` vs `gh` and `python` vs `uv`)
- `git` is managed exclusively in Home Manager in [users/luigi/programs/git.nix](file:///home/luigi/nixos/users/luigi/programs/git.nix).
- `gh` (GitHub CLI) is installed in `environment.systemPackages` in [modules/software/dev-tools.nix:42](file:///home/luigi/nixos/modules/software/dev-tools.nix#L42).
  - *Result*: The root user and any system services have access to `gh`, but do not have `git` in their `$PATH`!
- In [modules/software/dev-tools.nix:45-73](file:///home/luigi/nixos/modules/software/dev-tools.nix#L45-L73), a 28-package monolithic Python data stack (`numpy`, `pandas`, `scipy`, `scikit-learn`, `matplotlib`, `plotly`, `duckdb`, `polars`) is forced into `environment.systemPackages`.
  - Meanwhile, [users/luigi/programs/uv.nix](file:///home/luigi/nixos/users/luigi/programs/uv.nix) installs `uv` for modern ephemeral virtual environments.
  - *Result*: System-wide Python packages conflict with local virtualenvs created by `uv` or poetry, violating standard development isolation.

---

## 3. Proposed Architecture & Target State

```mermaid
graph LR
    subgraph Registry ["Unified Software Registry (SSOT)"]
        SYS["system-essential<br/>(curl, git, coreutils, zsh)"]
        DEV["developer-tools<br/>(compilers, LSPs, uv)"]
        GUI["desktop-apps<br/>(falkon, mpv, spectacle)"]
        USER["user-tools<br/>(wezterm, neovim, bat)"]
    end

    subgraph Evaluation ["Nix Generator / Evaluator"]
        DEDUP{"Deduplication & Scope Resolver"}
    end

    subgraph Targets ["System & Home Profiles"]
        SP["environment.systemPackages<br/>(Strictly Minimal & System-wide)"]
        HM["home-manager.users.<user>.home.packages<br/>(Personal CLI & User Apps)"]
        HMP["programs.<name><br/>(Configured User Modules)"]
    end

    SYS --> DEDUP
    DEV --> DEDUP
    GUI --> DEDUP
    USER --> DEDUP

    DEDUP -->|Scope: System| SP
    DEDUP -->|Scope: User (Raw)| HM
    DEDUP -->|Scope: User (Module)| HMP
```

### Proposed Rules:
1. **Single Source of Truth (SSOT)**: Every package must be recorded in a single database/manifest with explicit metadata:
   - `scope`: `system` (strictly essential utilities + hardware helpers) vs `user:<username>` (desktop apps, personal CLI, dev environments).
   - `reason`: `explicit` (manually chosen) vs `dependency` (infrastructural requirement).
2. **System Minimalism**: `environment.systemPackages` must only contain emergency rescue tools (`coreutils`, `pciutils`, `curl`, `git`, minimal editor), hardware/Wayland glue, and systemd unit utilities.
3. **No Redundant Plasma Tools**: Do not declare packages in `systemPackages` if they are already provided by `services.desktopManager.plasma6`.
4. **Isolated Development Stacks**: Migrate monolithic `python3.withPackages` out of system packages into user environments or project-level `flake.nix` / `shell.nix` environments with `direnv`.

---

## 4. Acceptance Criteria

- [x] `spectacle` and `bluedevil` are removed from [desktop-apps.nix](file:///home/luigi/nixos/modules/software/desktop-apps.nix) to eliminate duplication with KDE Plasma 6.
- [x] `git` is added to system essentials so `root` and system scripts have access to Git.
- [x] `vim` and `neovim` role ambiguity is resolved (e.g. `vim` removed from systemPackages to prevent shadowing Neovim).
- [x] Monolithic Python environment is cataloged with clear scope boundary in `manifest.toml`.
- [x] Automated check via `pacnix audit` verifies zero duplicate package names across evaluated `systemPackages` and `home.packages`.
