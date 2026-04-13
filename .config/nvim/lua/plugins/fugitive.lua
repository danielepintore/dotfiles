return {
	{ 'tpope/vim-fugitive',
        keys = {
            { "<leader>gs", vim.cmd.Git, desc = "Open Vim Fugitive" },
        },
        dependencies = { "nvim-lua/plenary.nvim" }
    },
}
