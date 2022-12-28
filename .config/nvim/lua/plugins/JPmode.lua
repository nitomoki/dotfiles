return {
    "nitomoki/JPmode.nvim",
    -- "~/NeovimPlugins/JPmode.nvim",
    lazy = true,
    init = function()
        vim.keymap.set("i", "<C-]>", require("JPmode").toggle, { silent = true, noremap = true })
        vim.keymap.set("n", "<C-]>", require("JPmode").off, { silent = true, noremap = true })
    end,
    config = function()
        require("JPmode").setup {
            on_command = "/usr/local/bin/swim  com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese",
            off_command = "/usr/local/bin/swim  com.apple.keylayout.ABC",
        }
    end,
}
