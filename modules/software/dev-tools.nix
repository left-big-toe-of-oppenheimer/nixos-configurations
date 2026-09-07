{ config, lib, pkgs, ... }:

{
  # -------------------------------------------------------------------------
  # Development Tools & Scripting Runtimes
  # -------------------------------------------------------------------------
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    # AI & Nix Language Tooling
    nil                 # Nix Language Server
    alejandra           # Nix code formatter
    claude-code
    antigravity-cli

    # Core build & C/C++ toolchain
    gcc
    clang
    clang-tools         # clangd (C/C++ LSP) & clang-format
    gnumake
    cmake
    ninja
    pkg-config
    tree-sitter
    gdb
    valgrind

    # Language Servers (LSPs), Linters & Formatters
    pyright             # Python LSP
    ruff                # Python linter & formatter
    rust-analyzer       # Rust LSP
    lua-language-server # Lua LSP
    stylua              # Lua formatter
    shfmt               # Shell formatter
    shellcheck          # Shell linter
    taplo               # TOML LSP & formatter
    marksman            # Markdown LSP
    yaml-language-server# YAML LSP
    vscode-langservers-extracted # JSON / HTML / CSS LSPs

    # Version control (git is managed via Home Manager in users/luigi/programs/git.nix)
    gh

    # Standard runtimes & Python Data Analysis Stack
    (python3.withPackages (ps: with ps; [
      # Core utilities & I/O
      pypdf
      requests
      rich
      pillow
      tqdm
      openpyxl          # Excel (.xlsx) support
      pyarrow           # Parquet / Arrow data formats

      # Data manipulation & Analytics
      pandas            # DataFrame library
      polars            # High-performance multi-threaded DataFrames
      duckdb            # In-process SQL OLAP database

      # Numerical & Scientific Computing
      numpy             # Fast array math
      scipy             # Scientific algorithms & statistics
      scikit-learn      # Machine learning models & metrics
      statsmodels       # Statistical modeling & econometrics

      # Data Visualization
      matplotlib        # Core 2D/3D plotting
      seaborn           # Statistical visualization
      plotly            # Interactive web-based charts

      # Interactive Analysis
      ipython           # Enhanced interactive shell
    ]))
    nodejs
    rustc
    cargo
    yt-dlp
  ];
}
