local _, dev = require("utils").local_plugins_path()

local opt = {
    enable = false,
    IME = {
        jp = nil,
        en = nil,
    },
}
if vim.fn.has "mac" == 1 then
    local swim = "/usr/local/bin/swim"
    if vim.fn.executable(swim) ~= 1 then
        opt.enable = true
        opt.IME.jp = {
            cmd = swim,
            args = { "use", "com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese" },
        }
        opt.IME.en = {
            cmd = swim,
            args = { "use", "com.apple.keylayout.ABC" },
        }
    end
end
if vim.fn.has "wsl" == 1 then
    local zenhan = vim.g.WSL_HOME .. "scoop/apps/zenhan/current/zenhan.exe"
    if vim.fn.executable(zenhan) == 1 then
        opt.enable = true
        opt.IME.jp = {
            cmd = zenhan,
            args = { "1" },
        }
        opt.IME.en = {
            cmd = zenhan,
            args = { "0" },
        }
    end
end

return {
    "nitomoki/JPmode.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    dev = dev,
    lazy = true,
    init = function()
        if not opt.enable then
            return
        end
        local keymap = nil
        if vim.fn.has "wsl" == 1 then
            keymap = "<C-Space>"
        end
        if vim.fn.has "mac" == 1 then
            keymap = "<C-M-Space>"
        end
        vim.keymap.set({ "i", "c" }, keymap, require("JPmode").toggle, { silent = true, noremap = true })
        vim.keymap.set("n", keymap, require("JPmode").off, { silent = true, noremap = true })
    end,
    config = function()
        if not opt.enable then
            return
        end
        require("JPmode").setup(opt)
        vim.api.nvim_create_autocmd("User", { pattern = "TelescopeKeymap", callback = require("JPmode").off })
    end,
}
