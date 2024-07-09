return {
	{
		'neovim/nvim-lspconfig',
		dependencies = {
			'williamboman/mason.nvim',
			'williamboman/mason-lspconfig.nvim',
			'folke/neoconf.nvim',
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-path',
			'hrsh7th/cmp-cmdline',
			'hrsh7th/nvim-cmp',
			'L3MON4D3/LuaSnip',
			'saadparwaiz1/cmp_luasnip',
			{ 'j-hui/fidget.nvim', tag = 'v1.4.0' },
		},

		config = function()
			local cmp = require('cmp')
			local cmp_lsp = require('cmp_nvim_lsp')
			local capabilities = cmp_lsp.default_capabilities()
			require('fidget').setup({})
			require('mason').setup()
			require('mason-lspconfig').setup({
				ensure_installed = { 'eslint', 'tsserver', 'rust_analyzer', 'lua_ls', 'clangd', 'volar', 'pylsp' },
			})

			require("mason-lspconfig").setup_handlers {
				-- The first entry (without a key) will be the default handler
				-- and will be called for each installed server that doesn't have
				-- a dedicated handler.
				function(server_name) -- default handler (optional)
					local server_config = {
						capabilities = capabilities,
					}
					if require("neoconf").get(server_name .. ".disable") then -- disable servers with neoconfg
						return
					end
					if server_name == "volar" then -- TODO: fix for tsserver should i keep this can i just uninstall tsserver and use only volar?
						server_config.filetypes = { 'vue', 'typescript', 'javascript' }
					end
					require("lspconfig")[server_name].setup(server_config)
				end,

				-- Next, you can provide a dedicated handler for specific servers.
				-- For example, a handler override for the `rust_analyzer`:
				-- ["rust_analyzer"] = function ()
				--	require("rust-tools").setup {}
				-- end

				-- configure lua server to fix vim warning
				["lua_ls"] = function()
					local lspconfig = require("lspconfig")
					lspconfig.lua_ls.setup {
						capabilities = capabilities,
						settings = {
							Lua = {
								diagnostics = {
									globals = { "vim" }
								}
							}
						}
					}
				end,
			}
			-- end mason_lspconfig setup handlers
			-- setup keymaps:
			-- Global mappings.
			-- See `:help vim.diagnostic.*` for documentation on any of the below functions
			vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
			vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
			vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
			vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

			-- Use LspAttach autocommand to only map the following keys
			-- after the language server attaches to the current buffer
			vim.api.nvim_create_autocmd('LspAttach', {
				group = vim.api.nvim_create_augroup('UserLspConfig', {}),
				callback = function(ev)
					-- Buffer local mappings.
					-- See `:help vim.lsp.*` for documentation on any of the below functions
					local opts = { buffer = ev.buf }
					vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
					vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
					vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
					vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
					vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, opts)
					vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
					vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
					vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
					vim.keymap.set('n', '<space>wl', function()
						print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
					end, opts)
					vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
					vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
					vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
					vim.keymap.set('n', '<leader>f', function()
						vim.lsp.buf.format { async = true }
					end, opts)
				end,
			})


			local cmp_select_behavior = { behavior = cmp.SelectBehavior.Select }

			cmp.setup({
				preselect = cmp.PreselectMode.None,
				snippet = {
					-- REQUIRED - you must specify a snippet engine
					expand = function(args)
						require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
					end,
				},
				mapping = cmp.mapping.preset.insert({
					-- `Enter` key to confirm completion
					['<CR>'] = cmp.mapping({
						i = function(fallback)
							if cmp.visible() and cmp.get_active_entry() then
								cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
							else
								fallback()
							end
						end,
						s = cmp.mapping.confirm({ select = true }),
						c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
					}),
					-- Alt+Space to trigger completion menu
					['<M-Space>'] = cmp.mapping.complete(),

					-- Tab to change item in completion menu
					['<Tab>'] = cmp.mapping.select_next_item(cmp_select_behavior),
					-- Shift+Tab goes to the previus item in the completion menu
					['<S-Tab>'] = cmp.mapping.select_prev_item(cmp_select_behavior),

					-- Navigate between documentation
					['<C-f>'] = cmp.mapping.scroll_docs(4),
					['<C-d>'] = cmp.mapping.scroll_docs(-4),
				}),
				sources = cmp.config.sources({
						{ name = 'nvim_lsp' },
						{ name = 'luasnip' }, -- For luasnip users.
						-- Copilot Source
						{ name = "copilot", group_index = 2 },
					},
					{
						{ name = 'buffer' },
					})
			})

			-- end cmp setup

			vim.diagnostic.config({
				float = {
					focusable = false,
					style = 'minimal',
					border = 'rounded',
					source = 'always',
					header = '',
					prefix = '',
				}
			})
		end
	}
}
