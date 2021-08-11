local o = vim.o
local w = vim.wo
local b = vim.bo
local g = vim.g
local fn = vim.fn
local cmd = vim.cmd
local utils = require('utils')

local M
M = {
    netrw = function()
    end,

    run = function()
        local ft = vim.fn.expand'<sfile>:t:r'
        if ft == '' then
            error'cannot detect filetype from <sfile>'
        elseif not M[ft] then
            error('unknown filetype: '..ft..' in ftplugins.lua')
        end
        M[ft]()
    end,
}

return M

