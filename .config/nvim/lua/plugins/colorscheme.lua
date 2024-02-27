return {
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000,
	config = function()
			require('catppuccin').setup({
				term_colors = false,
				transparent_background = true,
				styles = {
					comments = {},
					conditionals = {},
					loops = {},
					functions = {},
					keywords = {},
					strings = {},
					variables = {},
					numbers = {},
					booleans = {},
					properties = {},
					types = {},
				},
			})

			-- set the colorscheme
			vim.cmd('colorscheme catppuccin')
			-- Do i need those?
			vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
			vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
		end
	},
}
