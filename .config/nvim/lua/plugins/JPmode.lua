local _, dev = require("utils").local_plugins_path()

return {
    "nitomoki/JPmode.nvim",
    dev = dev,
    lazy = true,
    init = function()
        if vim.fn.executable "/usr/local/bin/swim" ~= 1 then
            return
        end
        vim.keymap.set({ "i", "c" }, "<C-M-Space>", require("JPmode").toggle, { silent = true, noremap = true })
        vim.keymap.set("n", "<C-M-Space>", require("JPmode").off, { silent = true, noremap = true })
    end,
    config = function()
        if vim.fn.executable "/usr/local/bin/swim" ~= 1 then
            return
        end
        require("JPmode").setup {
            jp = "/usr/local/bin/swim use com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese",
            en = "/usr/local/bin/swim use com.apple.keylayout.ABC",
        }
        vim.api.nvim_create_autocmd("User", { pattern = "TelescopeKeymap", callback = require("JPmode").off })
    end,
}
