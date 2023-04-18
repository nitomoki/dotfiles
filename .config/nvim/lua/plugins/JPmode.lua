local _, dev = require("utils").local_plugins_path()

return {
    "nitomoki/JPmode.nvim",
    dev = dev,
    lazy = true,
    init = function()
        vim.keymap.set({ "i", "c" }, "<C-Space>", require("JPmode").toggle, { silent = true, noremap = true })
        vim.keymap.set("n", "<C-Space>", require("JPmode").off, { silent = true, noremap = true })
    end,
    config = function()
        require("JPmode").setup {
            jp = "/usr/local/bin/swim use com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese",
            en = "/usr/local/bin/swim use com.apple.keylayout.ABC",
        }
        vim.api.nvim_create_autocmd("User", { pattern = "TelescopeKeymap", callback = require("JPmode").off })
    end,
}
