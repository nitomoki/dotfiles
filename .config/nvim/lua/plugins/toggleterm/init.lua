return {
    "akinsho/toggleterm.nvim",
    lazy = true,
    cmd = "ToggleTerm",
    init = function()
        local opts = { noremap = true, silent = true }
        vim.keymap.set("n", "<C-t>", function() vim.cmd("ToggleTerm direction=float") end, opts)
        vim.keymap.set("t", "<C-t>", function() vim.cmd.ToggleTerm() end, opts)
    end,
    config = function()
        require "plugins.toggleterm.config"
    end,
}
