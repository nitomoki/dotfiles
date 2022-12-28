return {
    {
        "norcalli/nvim-colorizer.lua",
        lazy = true,
        event = "BufReadPost",
        config = function()
            require("colorizer").setup()
        end,
    },
    {
        "goolord/alpha-nvim",
        event = "VimEnter",
        dependencies = { "kyazdani42/nvim-web-devicons" },
        config = function()
            require("alpha").setup(require("alpha.themes.startify").config)
        end,
    },
}
