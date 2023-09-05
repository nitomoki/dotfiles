return {
    "rebelot/heirline.nvim",
    lazy = true,
    event = "VimEnter",
    cond = function()
        if vim.opt.laststatus == 0 then
            return false
        end
        return true
    end,
    dependencies = {
        "folke/tokyonight.nvim",
    },
    init = function()
        --
    end,
    config = function()
        require "plugins.statusline.config"
    end,
}
