return {
    "neovim/nvim-lspconfig",
    lazy = true,
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        { "folke/lazydev.nvim", ft = "lua", opts = {} },
    },
    config = function()
        require "plugins.lsp.config"
    end,
}
