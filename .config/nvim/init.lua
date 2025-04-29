require "options"
require "keymaps"
require "augroups"
require "global"

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
        "git",
        "clone",
        "--filter=blob:none",
        "--single-branch",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    }
end
vim.opt.rtp:prepend(lazypath)
-- vim.opt.runtimepath:prepend(lazypath)

local lazy_opt = {
    spec = {
        { import = "plugins" },
    },
    change_detection = { notify = false },
    defaults = { lazy = true },
    dev = {
        path = require("utils").local_plugins_path(),
    },
}
require("lazy").setup(lazy_opt)
