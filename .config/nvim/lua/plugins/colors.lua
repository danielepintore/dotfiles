-- Custom colorscheme application function that disables background colors for
-- Normal and NormalFloat highlights
function ApplyColorscheme(color)
    color = color or "default"
    vim.cmd.colorscheme(color)

    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

return {
    {
        "catppuccin/nvim",
        enabled = false,
        lazy = false,
        name = "catppuccin",
        priority = 1000,
        opts = {
            transparent_background = true,
        },
        config = function(_, opts)
            require("catppuccin").setup(opts)
            vim.cmd("colorscheme catppuccin")
        end
    },
    {
        "rose-pine/neovim",
        enabled = true,
        lazy = false,
        name = "rose-pine",
        priority = 1000,
        opts = {
            styles = {
                transparency = true
            },
        },
        config = function(_, opts)
            require("rose-pine").setup(opts)
            vim.cmd("colorscheme rose-pine")
        end
    },
}
