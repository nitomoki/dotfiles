local _, dev = require("utils").local_plugins_path()

return {
    "nitomoki/JPmode.nvim",
    dev = dev,
    lazy = true,
    init = function()
        vim.keymap.set({ "i", "c" }, "<C-]>", require("JPmode").toggle, { silent = true, noremap = true })
        vim.keymap.set("n", "<C-]>", require("JPmode").off, { silent = true, noremap = true })
    end,
    config = function()
        require("JPmode").setup {
            jp = "/usr/local/bin/swim use com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese",
            en = "/usr/local/bin/swim use com.apple.keylayout.ABC",
        }
    end,
}
