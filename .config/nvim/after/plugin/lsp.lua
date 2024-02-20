-- custom lsp per project
require("neoconf").setup({
  -- override any of the default settings here
  plugins = {
    -- configures lsp clients with settings in the following order:
    -- - lua settings passed in lspconfig setup
    -- - global json settings
    -- - local json settings
    lspconfig = {
      enabled = true,
    },
    -- configures jsonls to get completion in .nvim.settings.json files
    jsonls = {
      enabled = true,
      -- only show completion in json settings for configured lsp servers
      configured_servers_only = false,
    },
    -- configures lua_ls to get completion of lspconfig server settings
    lua_ls = {
      -- by default, lua_ls annotations are only enabled in your neovim config directory
      enabled_for_neovim_config = true,
      -- explicitely enable adding annotations. Mostly relevant to put in your local .nvim.settings.json file
      enabled = false,
    },
  },
})

local lsp = require('lsp-zero')

lsp.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.extend_cmp()
require('mason').setup({})
require('mason-lspconfig').setup({
  -- Replace the language servers listed here
  -- with the ones you want to install
  ensure_installed = {'eslint', 'tsserver', 'rust_analyzer', 'lua_ls', 'clangd',
						'volar', 'pylsp'},
 -- handlers = {
 --   lsp.default_setup,
 --   lua_ls = function()
 --     -- (Optional) Configure lua language server for neovim
 --     require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())
 --   end,
 -- },
})

require('mason-lspconfig').setup_handlers({
  function(server_name)
    local server_config = {}
    if require("neoconf").get(server_name .. ".disable") then
      return
    end
    if server_name == "volar" then
        server_config.filetypes = { 'vue', 'typescript', 'javascript' }
    end
    require('lspconfig')[server_name].setup(server_config)
  end,
})

local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

cmp.setup({
  mapping = {
    -- `Enter` key to confirm completion
    ['<CR>'] = cmp.mapping.confirm({select = false}),

    -- Alt+Space to trigger completion menu
    ['<M-Space>'] = cmp.mapping.complete(),

	-- Tab to change item in completion menu
	['<Tab>'] = cmp_action.tab_complete(),
	-- Shift+Tab goes to the previus item in the completion menu
	['<S-Tab>'] = cmp_action.select_prev_or_fallback(),

    -- Navigate between documentation
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-r>'] = cmp.mapping.scroll_docs(-4),
  }
})

lsp.set_preferences({
	sign_icons = {}
})
