return {
	{
		"ThePrimeagen/git-worktree.nvim",
		opt = {},
		config = function()
			require("telescope").load_extension("git_worktree")
		end,
		keys = {
			{
				"<leader>gw",
				function()
					require("telescope").extensions.git_worktree.git_worktrees()
				end,
				desc = "Git Worktree switch",
			},
			{
				"<leader>gn",
				function()
					require("telescope").extensions.git_worktree.create_git_worktree()
				end,
				desc = "Git Worktree create",
			},
		},
		dependencies = {
			"nvim-telescope/telescope.nvim",
		}
	}
}
