return {
    "neovim/nvim-lspconfig",
    lazy = true,
    event = { "BufReadPre", "BufNewFile" },
    cmd = "Mason",
    dependencies = {
        { "williamboman/mason.nvim" },
        { "williamboman/mason-lspconfig.nvim" },
        {
            "nvimtools/none-ls.nvim",
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
        { "folke/lazydev.nvim", ft = "lua", opts = {} },
    },
    config = function()
        require "plugins.lsp.config"
    end,
}
