-- Switched from tokyonight-night to catppuccin-mocha: tokyonight's deliberately
-- dim comments (#565f89) sit at only ~2.3:1 contrast on markview.nvim's code-block
-- background, making comments illegible. Catppuccin Mocha's comments are far more
-- readable and it ships markview / render-markdown integrations.
return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false,
        priority = 1000,
        config = function()
            require("catppuccin").setup {
                flavour = "mocha",
                integrations = {
                    -- Only keys with a matching module under
                    -- catppuccin/groups/integrations/ are valid. "markdown" has no
                    -- module in this version, so it is intentionally omitted.
                    render_markdown = true,
                    markview = true,
                },
            }
            vim.cmd [[colorscheme catppuccin-mocha]]
        end,
    },
}
