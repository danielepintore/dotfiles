return {
	{ 'github/copilot.vim',
		config = function ()
			-- Disable copilot by default
			vim.g.copilot_enabled = false
		end
	}
}
