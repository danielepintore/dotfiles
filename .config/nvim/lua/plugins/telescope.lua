return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.5",
	config = function()
		require('telescope').setup({
			defaults = {
				mappings = {
					i = {
						['<Tab>'] = 'move_selection_previous',
						['<S-Tab>'] = 'move_selection_next',
						['<C-f>'] = 'preview_scrolling_up',
					}
				}
			}
		})
		local builtin = require('telescope.builtin')
		vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
		vim.keymap.set('n', '<leader>ps', function()
			builtin.grep_string({ search = vim.fn.input("Grep > ") });
		end)
		vim.keymap.set('n', '<leader>gf', builtin.git_files, {})
		vim.keymap.set('n', 'gr', builtin.lsp_references)
	end,
	dependencies = { "nvim-lua/plenary.nvim" }
}
