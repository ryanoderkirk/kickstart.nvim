return {
  {
    'mason-org/mason.nvim',
    opts = {},
  },
  {
    'mason-org/mason-lspconfig.nvim',
    opts = {
      ensure_installed = { 'lua_ls', 'clangd' },
    },
    dependencies = {
      { 'mason-org/mason.nvim' },
      'neovim/nvim-lspconfig',
    },
  },
  {
    'neovim/nvim-lspconfig',
    config = function()
      vim.lsp.enable 'clangd'
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'goto definition' })

      vim.lsp.config('clangd', {
        -- Server-specific settings. See `:help lsp-quickstart`
        settings = {
          ['clangd'] = {},
        },
      })
    end,
  },
}
