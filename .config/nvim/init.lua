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
vim.opt.runtimepath:prepend(lazypath)

local lazy_opt = {
    dev = {
        path = require("utils").local_plugins_path(),
    },
}
require("lazy").setup("plugins", lazy_opt)
