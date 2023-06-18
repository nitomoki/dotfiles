_G.utils = require "utils"
_G.put = vim.pretty_print

if vim.fn.has "wsl" then
    vim.g.WSL_HOME = "/mnt/c/Users/nitom/"
end
