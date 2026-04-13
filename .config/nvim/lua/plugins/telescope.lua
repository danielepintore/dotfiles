return {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    opts = {
        defaults = {
            mappings = {
                i = {
                    ['<Tab>'] = 'move_selection_previous',
                    ['<S-Tab>'] = 'move_selection_next',
                    ['<C-f>'] = 'preview_scrolling_up',
                }
            }
        }
    },
    keys = {
        { "<leader>pf", function() require("telescope.builtin").find_files() end },
        { "<leader>ps", function() require("telescope.builtin").grep_string({ search = vim.fn.input("Grep > ") }) end },
        { "<leader>gf", function() require("telescope.builtin").git_files() end },
        { "<leader>gr", function() require("telescope.builtin").lsp_references() end },
    },
    dependencies = { "nvim-lua/plenary.nvim" }
}
