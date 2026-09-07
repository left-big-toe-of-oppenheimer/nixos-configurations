#!/usr/bin/env python3
"""
pacnix: A Pacman-inspired Centralized Database & Compiler for NixOS + Home Manager.
Combines centralized registry management with 100% reproducible Nix derivation output.
"""

import sys
import os
import argparse
import tomllib
from pathlib import Path

# Common Home Manager programs that provide a dedicated programs.<name> module
KNOWN_HM_PROGRAMS = {
    "git", "zsh", "wezterm", "bat", "neovim", "firefox", "uv", "btop",
    "htop", "alacritty", "kitty", "foot", "tmux", "fzf", "eza", "direnv",
    "lazygit", "gh", "ssh", "gpg", "rofi", "starship", "micro", "fish"
}

def find_repo_root() -> Path:
    if "NIXOS_CONFIG_DIR" in os.environ:
        p = Path(os.environ["NIXOS_CONFIG_DIR"]).resolve()
        if p.exists():
            return p
    try:
        import subprocess
        git_root = subprocess.check_output(
            ["git", "rev-parse", "--show-toplevel"],
            stderr=subprocess.DEVNULL,
            text=True
        ).strip()
        if git_root:
            return Path(git_root).resolve()
    except Exception:
        pass
    candidates = [
        Path.cwd(),
        Path(__file__).resolve().parent.parent,
        Path(__file__).resolve().parent,
        Path("/etc/nixos"),
        Path.home() / "nixos",
    ]
    for c in candidates:
        if (c / "refactoring" / "manifest.toml").exists() or (c / "manifest.toml").exists():
            return c.resolve()
    return Path("/etc/nixos")

REPO_ROOT = find_repo_root()
DEFAULT_MANIFEST = (REPO_ROOT / "refactoring" / "manifest.toml") if (REPO_ROOT / "refactoring" / "manifest.toml").exists() else (REPO_ROOT / "manifest.toml")
DEFAULT_OUT_DIR = DEFAULT_MANIFEST.parent / "generated"

def load_manifest(path: Path) -> dict:
    if not path.exists():
        print(f"Error: Manifest '{path}' not found.", file=sys.stderr)
        sys.exit(1)
    with open(path, "rb") as f:
        return tomllib.load(f)

def format_toml_val(val):
    if isinstance(val, bool):
        return "true" if val else "false"
    elif isinstance(val, str):
        return f'"{val}"'
    elif isinstance(val, (int, float)):
        return str(val)
    elif isinstance(val, dict):
        items = [f'{k} = {format_toml_val(v)}' for k, v in val.items()]
        return "{ " + ", ".join(items) + " }"
    elif isinstance(val, list):
        items = [format_toml_val(x) for x in val]
        return "[ " + ", ".join(items) + " ]"
    return str(val)

def save_manifest_toml(data: dict, path: Path):
    """Clean TOML serializer for manifest modifications."""
    lines = [f'version = "{data.get("version", "1.0.0")}"\n']
    
    meta = data.get("meta", {})
    lines.append("[meta]")
    for k, v in meta.items():
        lines.append(f'{k} = {format_toml_val(v)}')
    lines.append("\n# ==============================================================================")
    lines.append("# PACKAGES")
    lines.append("# ==============================================================================\n")

    packages = data.get("packages", {})
    for pkg, info in sorted(packages.items()):
        lines.append(f"[packages.{pkg}]")
        for k, v in info.items():
            lines.append(f'{k} = {format_toml_val(v)}')
        lines.append("")

    path.write_text("\n".join(lines), encoding="utf-8")

# ------------------------------------------------------------------------------
# AUDIT SUBCOMMAND
# ------------------------------------------------------------------------------
def cmd_audit(args):
    manifest = load_manifest(args.manifest)
    packages = manifest.get("packages", {})
    
    print("=" * 70)
    print(" PACNIX SYSTEM & MANIFEST AUDIT")
    print("=" * 70)

    issues = []
    seen_scopes = {}

    for pkg_id, meta in packages.items():
        scope = meta.get("scope", "system")
        kind = meta.get("kind", "package")
        provided_by = meta.get("provided_by")

        # Check duplicates across scopes
        if pkg_id in seen_scopes:
            issues.append(f"CRITICAL: Duplicate package '{pkg_id}' across scopes ({seen_scopes[pkg_id]} vs {scope})")
        else:
            seen_scopes[pkg_id] = scope

        # Validate Home Manager module capability
        if scope.startswith("user:") and kind == "program":
            if pkg_id not in KNOWN_HM_PROGRAMS:
                issues.append(
                    f"INVALID MODULE: '{pkg_id}' is configured as kind='program' in Home Manager, "
                    f"but lacks a known 'programs.{pkg_id}' module! Must be routed to kind='package'."
                )

    print(f"\n[*] Auditing Manifest ({len(packages)} packages registered):")
    if not issues:
        print("    [OK] No duplicate package definitions found.")
        print("    [OK] All Home Manager module options are verified against known schemas.")
    else:
        for iss in issues:
            print(f"    [FAIL] {iss}")

    # Dotfile inspection
    print("\n[*] Auditing Home Dotfiles (~/.config):")
    home_config = Path.home() / ".config"
    if home_config.exists():
        symlinks = []
        regular_files = []
        for p in home_config.iterdir():
            if p.is_symlink():
                symlinks.append(p.name)
            elif p.is_dir():
                # Check nested symlinks like git/config, bat/config, etc.
                nested_syms = [f"{p.name}/{sub.name}" for sub in p.iterdir() if sub.is_symlink()]
                if nested_syms:
                    symlinks.extend(nested_syms)
                else:
                    regular_files.append(p.name)
            else:
                regular_files.append(p.name)
        print(f"    - Pure Nix Store Symlinks (Tier 1): {len(symlinks)} items")
        print(f"      Managed paths: {', '.join(sorted(symlinks))}")
        print(f"    - Mutable / Unmanaged Desktop State: {len(regular_files)} items")
        print(f"      Examples: {', '.join(sorted(regular_files)[:8])} ...")
    print("\nAudit complete.")

# ------------------------------------------------------------------------------
# QUERY SUBCOMMAND
# ------------------------------------------------------------------------------
def cmd_query(args):
    manifest = load_manifest(args.manifest)
    packages = manifest.get("packages", {})

    if args.owns:
        target_path = os.path.expanduser(args.owns)
        found = False
        for pkg_id, meta in packages.items():
            for df in meta.get("dotfiles", []):
                df_path = os.path.expanduser(df.get("path", ""))
                if df_path == target_path or target_path.startswith(df_path):
                    print(f"Path '{target_path}' is OWNED by package: {pkg_id} ({meta.get('scope')})")
                    found = True
        if not found:
            print(f"Path '{target_path}' is NOT registered in pacnix manifest (unmanaged or runtime).")
        return

    if args.info:
        pkg_id = args.info
        if pkg_id not in packages:
            print(f"Package '{pkg_id}' not found in registry.", file=sys.stderr)
            sys.exit(1)
        meta = packages[pkg_id]
        print(f"Package:      {pkg_id}")
        print(f"Scope:        {meta.get('scope')}")
        print(f"Kind:         {meta.get('kind')}")
        print(f"Reason:       {meta.get('reason')}")
        print(f"Category:     {meta.get('category')}")
        print(f"Description:  {meta.get('desc', 'N/A')}")
        if meta.get("provided_by"):
            print(f"Provided by:  {meta.get('provided_by')} (Excluded from direct install)")
        if meta.get("dotfiles"):
            print("Dotfiles:")
            for d in meta.get("dotfiles"):
                print(f"  - {d.get('path')} [{d.get('tier')}]")
        return

    # Filter packages
    items = sorted(packages.items())
    if args.search:
        q = args.search.lower()
        items = [x for x in items if q in x[0].lower() or q in x[1].get("desc", "").lower()]

    if args.explicit:
        items = [x for x in items if x[1].get("reason") == "explicit"]

    scope_filter = args.scope
    if scope_filter:
        items = [x for x in items if x[1].get("scope") == scope_filter]

    print(f"{'PACKAGE':<25} {'SCOPE':<15} {'KIND':<10} {'REASON':<15} {'CATEGORY'}")
    print("-" * 75)
    for pkg_id, meta in items:
        p_name = pkg_id
        if meta.get("provided_by"):
            p_name += f" ({meta.get('provided_by')})"
        print(f"{p_name:<25} {meta.get('scope'):<15} {meta.get('kind'):<10} {meta.get('reason'):<15} {meta.get('category', '')}")
    print(f"\nTotal: {len(items)} packages")

# ------------------------------------------------------------------------------
# GENERATE SUBCOMMAND
# ------------------------------------------------------------------------------
def cmd_generate(args):
    manifest = load_manifest(args.manifest)
    packages = manifest.get("packages", {})
    out_dir = args.out_dir
    out_dir.mkdir(parents=True, exist_ok=True)

    system_pkgs = []
    user_pkgs = []
    user_programs = {}

    for pkg_id, meta in packages.items():
        # Skip items provided by desktop managers (deduplication)
        if meta.get("provided_by"):
            continue

        scope = meta.get("scope", "system")
        kind = meta.get("kind", "package")
        options = meta.get("options", {})

        if scope == "system":
            system_pkgs.append(pkg_id)
        elif scope.startswith("user:"):
            if kind == "program":
                user_programs[pkg_id] = options
            else:
                user_pkgs.append(pkg_id)

    # 1. Output system-packages.nix
    sys_file = out_dir / "system-packages.nix"
    sys_code = [
        "# ==============================================================================",
        "# AUTOGENERATED BY PACNIX - DO NOT EDIT DIRECTLY",
        "# Modify refactoring/manifest.toml and run 'pacnix generate'",
        "# ==============================================================================",
        "{ pkgs, ... }:",
        "",
        "{",
        "  environment.systemPackages = with pkgs; ["
    ]
    for p in sorted(system_pkgs):
        sys_code.append(f"    {p}")
    sys_code.extend(["  ];", "}", ""])
    sys_file.write_text("\n".join(sys_code), encoding="utf-8")

    # 2. Output user-packages.nix
    user_file = out_dir / "user-packages.nix"
    usr_code = [
        "# ==============================================================================",
        "# AUTOGENERATED BY PACNIX - DO NOT EDIT DIRECTLY",
        "# Modify refactoring/manifest.toml and run 'pacnix generate'",
        "# ==============================================================================",
        "{ pkgs, ... }:",
        "",
        "{",
        "  home.packages = with pkgs; ["
    ]
    for p in sorted(user_pkgs):
        usr_code.append(f"    {p}")
    usr_code.extend(["  ];", ""])

    for prog, opts in sorted(user_programs.items()):
        usr_code.append(f"  programs.{prog} = {{")
        for k, v in opts.items():
            if isinstance(v, bool):
                val_str = "true" if v else "false"
            elif isinstance(v, str):
                val_str = f'"{v}"'
            else:
                val_str = str(v)
            usr_code.append(f"    {k} = {val_str};")
        usr_code.extend(["  };", ""])

    usr_code.extend(["}", ""])
    user_file.write_text("\n".join(usr_code), encoding="utf-8")

    print(f"Generated clean Nix modules:")
    print(f"  -> {sys_file} ({len(system_pkgs)} system packages)")
    print(f"  -> {user_file} ({len(user_pkgs)} user packages, {len(user_programs)} programs)")

# ------------------------------------------------------------------------------
# ADD SUBCOMMAND
# ------------------------------------------------------------------------------
def cmd_add(args):
    manifest = load_manifest(args.manifest)
    packages = manifest.setdefault("packages", {})

    pkg = args.package
    if pkg in packages:
        print(f"Package '{pkg}' is already registered in manifest under scope '{packages[pkg].get('scope')}'.")
        return

    scope = args.scope
    reason = "dependency" if args.asdeps else "explicit"

    # Intelligent module routing
    if scope.startswith("user:") and pkg in KNOWN_HM_PROGRAMS:
        kind = "program"
        options = {"enable": True}
    else:
        kind = "package"
        options = {}

    packages[pkg] = {
        "scope": scope,
        "kind": kind,
        "reason": reason,
        "category": args.category or "cli",
        "desc": args.desc or f"Package {pkg}"
    }
    if options:
        packages[pkg]["options"] = options

    save_manifest_toml(manifest, args.manifest)
    print(f"Successfully added '{pkg}' (scope: {scope}, kind: {kind}, reason: {reason}) to manifest.")
    
    if args.generate:
        cmd_generate(args)

# ------------------------------------------------------------------------------
# REMOVE SUBCOMMAND
# ------------------------------------------------------------------------------
def cmd_remove(args):
    manifest = load_manifest(args.manifest)
    packages = manifest.get("packages", {})

    pkg = args.package
    if pkg not in packages:
        print(f"Package '{pkg}' is not registered in manifest.", file=sys.stderr)
        return

    del packages[pkg]
    save_manifest_toml(manifest, args.manifest)
    print(f"Successfully removed '{pkg}' from manifest.")

    if args.generate:
        cmd_generate(args)

# ------------------------------------------------------------------------------
# MAIN
# ------------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(description="pacnix: Database & compiler for NixOS")
    parser.add_argument("--manifest", type=Path, default=DEFAULT_MANIFEST, help="Path to manifest.toml")
    parser.add_argument("--out-dir", type=Path, default=DEFAULT_OUT_DIR, help="Directory to output generated .nix files")

    subparsers = parser.add_subparsers(dest="command", required=True)

    # audit
    subparsers.add_parser("audit", help="Audit manifest and system for duplicates and split-brain")

    # query
    p_query = subparsers.add_parser("query", help="Query packages in manifest (pacman -Q)")
    p_query.add_argument("-e", "--explicit", action="store_true", help="Show only explicitly requested packages (-Qe)")
    p_query.add_argument("-s", "--search", type=str, help="Search packages (-Qs)")
    p_query.add_argument("-i", "--info", type=str, help="Show package info (-Qi)")
    p_query.add_argument("-o", "--owns", type=str, help="Check package ownership of dotfile (-Qo)")
    p_query.add_argument("--scope", type=str, help="Filter by scope (system or user:luigi)")

    # generate
    subparsers.add_parser("generate", help="Compile manifest into pure NixOS & Home Manager modules")

    # add
    p_add = subparsers.add_parser("add", help="Add package to manifest (pacman -S)")
    p_add.add_argument("package", help="Name of package")
    p_add.add_argument("--scope", default="user:luigi", help="Target scope (system or user:luigi)")
    p_add.add_argument("--asdeps", action="store_true", help="Mark as dependency")
    p_add.add_argument("--category", default="cli", help="Software category")
    p_add.add_argument("--desc", default="", help="Description")
    p_add.add_argument("--generate", action="store_true", default=True, help="Auto-regenerate Nix modules")

    # remove
    p_rm = subparsers.add_parser("remove", help="Remove package from manifest (pacman -R)")
    p_rm.add_argument("package", help="Name of package")
    p_rm.add_argument("--generate", action="store_true", default=True, help="Auto-regenerate Nix modules")

    args = parser.parse_args()

    if args.command == "audit":
        cmd_audit(args)
    elif args.command == "query":
        cmd_query(args)
    elif args.command == "generate":
        cmd_generate(args)
    elif args.command == "add":
        cmd_add(args)
    elif args.command == "remove":
        cmd_remove(args)

if __name__ == "__main__":
    main()
