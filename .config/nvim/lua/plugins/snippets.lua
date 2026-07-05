return {
    {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
        version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        enabled = false,
        -- install jsregexp (optional!).
        build = "make install_jsregexp",
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
        end
    },
    {
        -- An empty name block tells lazy.nvim this config handles built-in core features
        dir = vim.fn.stdpath("config"),
        name = "native_snippets",
        keys = {
            {
                "<Tab>",
                function()
                    if vim.snippet.active({ direction = 1 }) then
                        vim.snippet.jump(1)
                    else
                        -- Sends a literal Tab character to the buffer if no snippet is active
                        local esc = vim.api.nvim_replace_termcodes("<Tab>", true, false, true)
                        vim.api.nvim_feedkeys(esc, "n", false)
                    end
                end,
                mode = { "i", "s" },
                desc = "Snippet jump forward",
            },
            {
                "<S-Tab>",
                function()
                    if vim.snippet.active({ direction = -1 }) then
                        vim.snippet.jump(-1)
                    else
                        local esc = vim.api.nvim_replace_termcodes("<S-Tab>", true, false, true)
                        vim.api.nvim_feedkeys(esc, "n", false)
                    end
                end,
                mode = { "i", "s" },
                desc = "Snippet jump backward",
            },
            {
                "<CR>",
                function()
                    if vim.fn.pumvisible() ~= 0 then
                        -- Clear menu selection, then feed a real Enter carriage return
                        local esc = vim.api.nvim_replace_termcodes("<C-e><CR>", true, false, true)
                        vim.api.nvim_feedkeys(esc, "n", false)
                    else
                        local esc = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
                        vim.api.nvim_feedkeys(esc, "n", false)
                    end
                end,
                mode = "i",
                desc = "Prevent Enter from accepting completion",
            },
        },
    },
}
