return {
	{
		'neovim/nvim-lspconfig',
		keys = {
			{ "<space>e", vim.diagnostic.open_float, mode = "n", desc = "Open diagnostic float" },
			{ "[d",       vim.diagnostic.goto_prev,  mode = "n", desc = "Go to previous diagnostic" },
			{ "]d",       vim.diagnostic.goto_next,  mode = "n", desc = "Go to next diagnostic" },
			{ "<space>q", vim.diagnostic.setloclist, mode = "n", desc = "Set location list with diagnostics" },
		},
		config = function()
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
					vim.keymap.set('n', '<leader>f', function()
						vim.lsp.buf.format { async = true }
					end, opts)
				end,
			})

			-- Set up diagnostics
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

			-- Set up cmp
			local cmp = require('cmp')
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
					{ name = 'path' },
					{ name = 'luasnip' },
					{ name = 'buffer' },
					-- Copilot Source
					{ name = "copilot", group_index = 2 },
				}),
			})
		end,
		dependencies = {
			'L3MON4D3/LuaSnip',
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-cmdline',
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-path',
			'hrsh7th/nvim-cmp',
			'saadparwaiz1/cmp_luasnip',
			{ 'j-hui/fidget.nvim', opts = {} },
		},
	},

	{
		'mason-org/mason-lspconfig.nvim',
		dependencies = {
			{ 'mason-org/mason.nvim', opts = {} },
			'neovim/nvim-lspconfig',
		},

		opts = {
			ensure_installed = { 'eslint', 'ts_ls', 'rust_analyzer', 'lua_ls', 'clangd', 'pylsp' },
		},
	},

	{
		"L3MON4D3/LuaSnip", -- Snippet engine
		keys = {
			-- Move up in snippet fields
			{
				"<C-k>",
				function()
					local ls = require("luasnip")
					if ls.jumpable(-1) then
						ls.jump(-1)
					end
				end,
				mode = { "i", "s" },
				desc = "Jump to the previous snippet field",
				silent = true,
			},
			-- Move down in snippet fields
			{
				"<C-j>",
				function()
					local ls = require("luasnip")
					if ls.expand_or_jumpable() then
						ls.expand_or_jump()
					end
				end,
				mode = { "i", "s" },
				desc = "Expand or jump to the next snippet field",
				silent = true,
			},
		},
	},
}
