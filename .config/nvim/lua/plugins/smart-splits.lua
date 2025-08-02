return {
    'mrjones2014/smart-splits.nvim',
    lazy = false,
    opts = {
        disable_multiplexer_nav_when_zoomed = false,
    },
    keys = {
        { "<C-h>", function() require("smart-splits").move_cursor_left() end },
        { "<C-j>", function() require("smart-splits").move_cursor_down() end },
        { "<C-k>", function() require("smart-splits").move_cursor_up() end },
        { "<C-l>", function() require("smart-splits").move_cursor_right() end },
        { "<C-S-h>", function() require("smart-splits").resize_left(5) end },
        { "<C-S-J>", function() require("smart-splits").resize_down(5) end },
        { "<C-S-K>", function() require("smart-splits").resize_up(5) end },
        { "<C-S-L>", function() require("smart-splits").resize_right(5) end },
    }
}
