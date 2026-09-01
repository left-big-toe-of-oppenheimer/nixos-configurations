return {
  -- Disable Mason entirely to ensure Neovim exclusively uses
  -- the native, properly wrapped NixOS system LSPs and compilers.
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },
  { "williamboman/mason.nvim", enabled = false },
  { "williamboman/mason-lspconfig.nvim", enabled = false },
}
