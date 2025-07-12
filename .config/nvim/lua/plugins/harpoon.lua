return {
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        opts = {
            settings = {
                save_on_toggle = true
            }
        },
        keys = {
            { "<leader>a", function() require("harpoon"):list():add() end,    desc = "Add file" },
            {
                "<C-e>",
                function()
                    require("harpoon").ui:toggle_quick_menu(require("harpoon"):list(), {
                        border = "rounded",
                        title_pos = "center",
                        ui_width_ratio = 0.40,
                    })
                end,
                desc = "Toggle quick menu"
            },
            { "<C-u>",     function() require("harpoon"):list():select(1) end },
            { "<C-i>",     function() require("harpoon"):list():select(2) end },
            { "<C-o>",     function() require("harpoon"):list():select(3) end },
            { "<C-p>",     function() require("harpoon"):list():select(4) end },
        },
        dependencies = { "nvim-lua/plenary.nvim" }
    },
}
