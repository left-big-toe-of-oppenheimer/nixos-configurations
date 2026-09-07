# TICKET-002: Criticality: Destructive Regex Scripts & Broken Module Assumptions

| Metadata | Details |
| :--- | :--- |
| **Ticket ID** | TICKET-002 |
| **Component** | Scaffolding Scripts (`scripts/add-program.sh`, `scripts/remove-program.sh`, etc.) |
| **Severity** | Critical |
| **Impact** | Syntax corruption, invalid Nix module options, broken system builds, and unverified git commits |
| **Status** | Resolved & Verified |

---

## 1. Problem Description

The repository includes four shell scripts in the [scripts/](file:///home/luigi/nixos/scripts/) directory designed to act as an ad-hoc package management interface:
- [scripts/add-program.sh](file:///home/luigi/nixos/scripts/add-program.sh)
- [scripts/remove-program.sh](file:///home/luigi/nixos/scripts/remove-program.sh)
- [scripts/add-service.sh](file:///home/luigi/nixos/scripts/add-service.sh)
- [scripts/remove-service.sh](file:///home/luigi/nixos/scripts/remove-service.sh)

While intended to automate package lifecycle management, an architectural audit reveals fatal design flaws that can corrupt the configuration, generate invalid Nix code, and break `nixos-rebuild switch`.

---

## 2. Detailed Technical Flaws

### A. The False `programs.<name>` Assumption
In [scripts/add-program.sh:21-30](file:///home/luigi/nixos/scripts/add-program.sh#L21-L30), the script generates every program using this fixed template:
```nix
cat <<EOF > "$TARGET_FILE"
{ config, pkgs, ... }:

{
  programs.$PROGRAM = {
    enable = true;
    # Add your configuration here
  };
}
EOF
```

#### The Fatal Flaw:
- In Home Manager, **only a small fraction** of Nixpkgs packages have a corresponding `programs.<name>` module (usually those requiring specialized shell hooks or configuration files, like `git`, `zsh`, `wezterm`, `firefox`).
- For the vast majority of packages (e.g. `ripgrep`, `fd`, `gimp`, `libreoffice`, `vlc`, `ffmpeg`, `inkscape`, `tree`, `jq`, `unzip`), **no such module exists**.
- If a user runs:
  ```bash
  add-program ripgrep
  ```
  The script successfully generates `users/luigi/programs/ripgrep.nix`, registers it in `default.nix`, and commits to git.
  However, running `rebuild` (`nixos-rebuild switch`) immediately **crashes with a fatal evaluation error**:
  ```text
  error: The option 'programs.ripgrep' does not exist.
  ```
- To install such packages in Home Manager, they must instead be placed in `home.packages = with pkgs; [ ripgrep ];`. The script provides no mechanism for this distinction.

### B. Code Mutation via Fragile Regex (`sed -i`)
In [scripts/add-program.sh:42-48](file:///home/luigi/nixos/scripts/add-program.sh#L42-L48), the script attempts "automatic deduplication" by scanning and modifying other Nix files using regex:
```bash
for file in /etc/nixos/modules/software/*.nix; do
  if grep -qE "^[[:space:]]*(\([[:space:]]*)?([a-zA-Z0-9_.-]+\.)*$PROGRAM([[:space:]]+.*|[.)].*)?$" "$file"; then
    sed -i -E "/^[[:space:]]*(\([[:space:]]*)?([a-zA-Z0-9_.-]+\.)*$PROGRAM([[:space:]]+.*|[.)].*)?$/d" "$file"
    echo "Automagic: Removed duplicate '$PROGRAM' from $file"
    git add "$file"
  fi
done
```

#### Hazards:
1. **Multi-line Derivation Destruction**: If a package is configured across multiple lines (e.g. `tesseract.override { enableLanguages = [ ... ]; }` in [modules/software/cli-tools.nix:32-34](file:///home/luigi/nixos/modules/software/cli-tools.nix#L32-L34)), deleting lines via regex will leave unmatched braces or parentheses, completely corrupting the Nix file AST.
2. **False Positive Substring Deletions**: Short package names (e.g. `fd`, `jq`, `entr`, `tree`) risk matching comments, variable names, or other package attributes.
3. **No AST Awareness**: Text-based line deletions disregard Nix scoping, comments, and formatting.

### C. Premature & Dirty Git Commits
In both [add-program.sh:51-53](file:///home/luigi/nixos/scripts/add-program.sh#L51-L53) and [add-service.sh:40-42](file:///home/luigi/nixos/scripts/add-service.sh#L40-L42):
```bash
cd /etc/nixos || exit 1
git add "$TARGET_FILE" "$DEFAULT_FILE"
git commit -m "feat(home): auto-scaffold $PROGRAM"
```
- The scripts commit directly to Git **before** running `nix flake check` or `nixos-rebuild build`.
- If the generated code is invalid (as shown with `ripgrep`), broken code is recorded into Git history.
- Git working tree becomes dirty without any rollback mechanism.

### D. Hardcoded Paths
All 4 scripts hardcode:
```bash
DIR="/etc/nixos/users/luigi/programs"
```
and:
```bash
cd /etc/nixos || exit 1
```
This breaks whenever the repository is checked out in a user directory (such as `/home/luigi/nixos`), executed in CI, or used on a machine with a different user name.

---

## 3. Comparison: Fragile Scripts vs. Modern Package DB Model

```
+------------------------------------+-------------------------------------------+
| Current Script Approach            | Target Database / Pacman-Like Architecture |
+------------------------------------+-------------------------------------------+
| Direct regex mutation of .nix files | Read/Write to structured manifest (DB)     |
| Blindly assumes programs.<name>    | Validates against Nixpkgs & HM option tree |
| Auto-commits broken files to Git   | Validates & dry-runs before committing     |
| Silently corrupts multi-line code  | AST-safe or pure data-driven generation   |
| Hardcoded paths (/etc/nixos)       | Flake-root discovery via git root         |
+------------------------------------+-------------------------------------------+
```

---

## 4. Remediation Plan & Acceptance Criteria

### Remediation Steps:
1. **Deprecate Regex-Based Scaffolding**: Cease using `sed -i` to mutate Nix source code.
2. **Implement Option Awareness**: The replacement tool must verify whether a package has a `programs.<name>` module in Home Manager or must be added to `home.packages`.
3. **Atomic Evaluation Guard**: Before staging or committing any change, the tool must run:
   ```bash
   nix flake check --no-build
   ```
   If evaluation fails, the transaction is automatically aborted and changes rolled back.
4. **Dynamic Repository Root**: Resolve repository root using `git rev-parse --show-toplevel` instead of hardcoded `/etc/nixos`.

### Acceptance Criteria:
- [x] Running package installation for standard tools (e.g. `ripgrep`, `btop`) never generates invalid `programs.<name>` options (handled via `pacnix add` intelligent routing).
- [x] No Nix source code is mutated via string/regex replacement (`scripts/*.sh` archived to `scripts/deprecated/`).
- [x] Git commits are only created after a successful Nix evaluation check.
- [x] All commands work identically when executed from `/home/luigi/nixos` or any other checkout location.
