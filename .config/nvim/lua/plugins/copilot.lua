return {
  "zbirenbaum/copilot-cmp",
  cmd = "Copilot",
  event = "InsertEnter",
	dependencies = {
		'zbirenbaum/copilot.lua',
	},
  config = function()
		-- Disable inline suggestions and panel
		require('copilot').setup({
			suggestion = { enabled = false },
			panel = { enabled = false },
		})
		-- enable suggesions via cmp panel
		require('copilot_cmp').setup({})
  end,
}
