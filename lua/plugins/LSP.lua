return {
  {
    'mason-org/mason.nvim',
    opts = {},
  },
  {
    'mason-org/mason-lspconfig.nvim',
    dependencies = {
      { 'mason-org/mason.nvim' },
      'neovim/nvim-lspconfig',
    },
    opts = {
      ensure_installed = { 'lua_ls', 'clangd' },
      automatic_installation = true,
      handlers = {
        function(server_name)
          require('lspconfig')[server_name].setup {
            on_attach = require('plugins.lsp-keymaps').on_attach,
            capabilities = require('cmp_nvim_lsp').default_capabilities(),
          }
        end,
        lua_ls = function()
          require('lspconfig').lua_ls.setup {
            on_attach = require('plugins.lsp-keymaps').on_attach,
            capabilities = require('cmp_nvim_lsp').default_capabilities(),
            settings = {
              Lua = {
                runtime = { version = 'LuaJIT' },
                diagnostics = {
                  globals = { 'vim' },
                },
              },
            },
          }
        end,
        clangd = function()
          require('lspconfig').clangd.setup {
            on_attach = require('plugins.lsp-keymaps').on_attach,
            capabilities = require('cmp_nvim_lsp').default_capabilities(),
          }
        end,
      },
    },
  },
}
