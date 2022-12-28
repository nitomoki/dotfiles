return {
    "nvim-treesitter/nvim-treesitter",
    lazy = true,
    event = "BufReadPost",
    build = function()
        require("nvim-treesitter.install").update { with_sunc = true }
    end,
    config = function()
        require "plugins.treesitter.config"
    end,
}
