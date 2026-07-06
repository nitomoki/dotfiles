-- markview.nvim: in-editor Markdown rendering (headings, lists, checkboxes,
-- code blocks, tables, etc.). Minimal starting config using upstream defaults;
-- extend by passing options to setup {} once you know which keys you want.
-- Toggle rendering with :Markview (or :Markview toggle).
--
-- NOTE: lazy = false is intentional and recommended by the maintainer --
-- markview lazy-loads itself, so do NOT add ft/event lazy-loading.
return {
    "OXY2DEV/markview.nvim",
    lazy = false,
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        require("markview").setup {}
    end,
}
