---@diagnostic disable: undefined-global
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
    -- mason-lspconfig v2 has no `handlers`; it auto-enables installed servers via vim.lsp.enable().
    -- Per-server settings go through vim.lsp.config() and keymaps through LspAttach.
    config = function()
      vim.lsp.config('*', {
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
      })

      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            diagnostics = { globals = { 'vim' } },
          },
        },
      })

      -- Prefer the project's own pyright/ruff (matches CI/pyproject); fall back to the one on PATH (mason)
      local function venv_server(exe, fallback, args)
        return function(dispatchers, config)
          local root = config.root_dir or vim.fn.getcwd()
          local venv_exe = vim.fs.joinpath(root, '.venv', 'Scripts', exe)
          local cmd = vim.uv.fs_stat(venv_exe) and venv_exe or fallback
          return vim.lsp.rpc.start(vim.list_extend({ cmd }, args), dispatchers, { cwd = config.cmd_cwd })
        end
      end
      vim.lsp.config('pyright', { cmd = venv_server('pyright-langserver.exe', 'pyright-langserver', { '--stdio' }) })
      vim.lsp.config('ruff', { cmd = venv_server('ruff.exe', 'ruff', { 'server' }) })

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('user-lsp-attach', { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == 'ruff' then
            -- pyright provides hover; avoid duplicate popups
            client.server_capabilities.hoverProvider = false
          end
          require('plugins.lsp-keymaps').on_attach(client, args.buf)
        end,
      })

      require('mason-lspconfig').setup {
        ensure_installed = { 'lua_ls', 'clangd', 'pyright', 'ruff' },
        automatic_enable = true,
      }
    end,
  },
}
