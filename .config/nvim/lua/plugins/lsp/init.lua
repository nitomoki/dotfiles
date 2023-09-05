return {
    "neovim/nvim-lspconfig",
    lazy = true,
    event = "BufReadPost",
    cmd = "Mason",
    dependencies = {
        { "williamboman/mason.nvim" },
        { "williamboman/mason-lspconfig.nvim" },
        {
            "jose-elias-alvarez/null-ls.nvim",
            dependencies = {
                "nvim-lua/plenary.nvim",
            },
        },
        {
            "jay-babu/mason-null-ls.nvim",
            dependencies = {
                "williamboman/mason.nvim",
                "williamboman/mason-lspconfig.nvim",
            },
        },
        { "folke/neodev.nvim", opts = {} },
    },
    config = function()
        require "plugins.lsp.config"
    end,
}
