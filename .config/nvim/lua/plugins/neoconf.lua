return {
	{ 'folke/neoconf.nvim',
		config = function ()
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
		end
	}
}
