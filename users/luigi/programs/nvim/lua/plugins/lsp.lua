return {
  -- Disable Mason entirely to ensure Neovim exclusively uses
  -- the native, properly wrapped NixOS system LSPs and compilers.
  { "williamboman/mason.nvim", enabled = false },
  { "williamboman/mason-lspconfig.nvim", enabled = false },
}
