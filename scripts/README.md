# NixOS Automation Scripts

The previous text-mutation scripts (`add-program.sh`, `remove-program.sh`, etc.) that performed destructive `sed -i` operations on Nix source files have been decommissioned and archived in `scripts/deprecated/` (see [TICKET-002](../refactoring/TICKET-002-fragile-scripting-and-sed-mutation.md)).

All package management, deduplication, and inspection is now handled centrally by **`pacnix`** via [refactoring/manifest.toml](../refactoring/manifest.toml).

### Common Commands:
- `pacnix add <pkg>`: Add a package (auto-routes to module or raw package).
- `pacnix remove <pkg>`: Remove a package from the manifest.
- `pacnix query`: Query installed packages (`-e` for explicit, `-i` for info, `-o` for dotfile ownership).
- `pacnix audit`: Audit configuration for duplicates, split-brain, and dotfiles.
- `pacnix generate`: Compile manifest into pure NixOS & Home Manager modules.
